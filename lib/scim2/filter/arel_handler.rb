module Scim2
  module Filter
    ##
    # Implementation of parser handler which translates SCIM 2.0 filters into AREL.
    # In order to do this, instances of this class will need to be passed the mapping
    # of attribute names to columns/AREL.
    #
    # @example
    #   # userName sw "J"
    #
    #   mapping = {
    #     userName: User.arel_table[:name],
    #   }
    #
    #   # "users"."name" LIKE 'J%'
    #
    # @example
    #   # urn:ietf:params:scim:schemas:core:2.0:User:userType ne "Employee" and not (name.familyName.value co "ab" or name.familyName.value co "xy")
    #
    #   mapping = {
    #     userType: User.arel_table[:type],
    #     name: {
    #       familyName: User.arel_table[:family_name],
    #     },
    #   }
    #
    #   # "users"."type" != 'Employee' AND NOT ("users"."family_name" LIKE '%ab%' OR "users"."family_name" LIKE '%xy%')
    #
    # @example
    #   # emails[type eq "work" and value ew "example.com"]
    #
    #   mapping = {
    #     emails: ->(path, op, value) {
    #       case path
    #       when [:type]
    #         User.arel_table[:email_type]
    #       when [:value]
    #         User.arel_table[:email]
    #       end
    #     },
    #   }
    #
    #   # "users"."email_type" = 'work' AND "users"."email" LIKE '%example.com'
    ##
    class ArelHandler

      attr_reader :arel_mapping

      def initialize(arel_mapping)
        @arel_mapping = arel_mapping
      end

      # Handle NOT filters (e.g. `not (color eq "red")`)
      # @param filter [Hash<Symbol, Object>] the internal filter being NOT'ed
      # @return [Hash<Symbol, Object>]
      def on_not_filter(filter, context:)
        filter.not
      end

      # Handle basic attribute comparison filters (e.g. `preference.color eq "red"`)
      # @param attribute_path [Array<Symbol>] the attribute name(s) being filtered on, split by `.`
      # @param value [Object] the value being compared against
      # @param op [Object] the comparison operator (e.g. `:eq`)
      # @param schema [String] schema namespace of the attribute
      # @return [Hash<Symbol, Object>]
      def on_attribute_filter(attribute_path, value, context:, op:, schema: nil)
        arel = lookup_arel(attribute_path)
        arel = arel.call(attribute_path, op, value) if arel.is_a?(Proc)
        apply_arel_operation(arel, op, value) or raise Racc::ParseError, "invalid attribute operand #{op.inspect} with argument #{value.inspect}"
      end

      # Handle logical filters (e.g. `name.givenName sw "D" AND title co "VP"`)
      # @param filter1 [Hash<Symbol, Object>] the left-hand side filter
      # @param filter2 [Hash<Symbol, Object>] the right-hand side filter
      # @param op [Object] the logical operator (e.g. `AND`)
      # @return [Hash<Symbol, Object>]
      def on_logical_filter(filter1, filter2, context:, op:)
        case op
        when :and
          filter1.and(filter2)
        when :or
          filter1.or(filter2)
        else
          raise Racc::ParseError, "invalid logical operand #{op.inspect}"
        end
      end

      # Begins capturing nested filter conditions inside a SimpleHandler
      # @return nil
      def before_nested_filter(*ignored)
        @nested_filter_handler = SimpleHandler.new
        nil
      end

      # Handle nested filters (e.g. `emails[type eq "work"]`)
      # @param attribute_path [Array<Symbol>] the attribute name(s) being filtered on, split by `.`
      # @param filter [Hash<Symbol, Object>] the nested filter inside the backets
      # @param schema [String] schema namespace of the attribute
      # @return [Hash<Symbol, Object>]
      def on_nested_filter(attribute_path, filter, context:, schema: nil)
        @nested_filter_handler = nil
        arel = lookup_arel(attribute_path)
        recursively_handle_nested_filter(arel, *filter.first)
      end

      # Wrap the following methods with logic that delegates to nested_filter_handler
      # if it responds to the method.
      %i[on_not_filter on_attribute_filter on_logical_filter].each do |name|
        orig = "___#{name}".to_sym
        define_method(orig, instance_method(name))
        send(:private, orig)

        define_method(name) do |*args, **opts|
          if @nested_filter_handler.respond_to?(name)
            @nested_filter_handler.send(name, *args, **opts)
          else
            send(orig, *args, **opts)
          end
        end
      end

      protected

      def apply_arel_operation(arel, op, value)
        case op
        when :eq
          arel.eq(value)
        when :ne
          arel.not_eq(value)
        when :co
          arel.matches("%#{value}%")
        when :sw
          arel.matches("#{value}%")
        when :ew
          arel.matches("%#{value}")
        when :gt
          arel.gt(value)
        when :ge
          arel.gteq(value)
        when :lt
          arel.lt(value)
        when :le
          arel.lteq(value)
        when :pr
          arel.not_eq(nil)
        end
      end

      # Looks up the arel object from the mapping according to the given attribute path
      # @param attribute_path [Array<Symbol>] the attribute name(s) being filtered on, split by `.`
      # @return [Object] the object returned by the mapping
      def lookup_arel(attribute_path)
        arel = arel_mapping.dig(*attribute_path)

        case arel
        when NilClass
          raise ArgumentError, "Attribute #{attribute_path.join(',').inspect} not found in mapping"
        when Arel::Predications, Proc
          arel
        else
          raise ArgumentError, "Mapping for attribute #{attribute_path.join(',').inspect} is not a valid arel object"
        end
      end

      def recursively_handle_nested_filter(arel, op, condition)
        case op
        when :not
          recursively_handle_nested_filter(arel, *condition.first).not
        when :and, :or
          condition.map do |c|
            recursively_handle_nested_filter(arel, *c.first)
          end.reduce(op)
        else
          path, value = condition.values_at(:path, :value)
          arel = arel.call(path, op, value) if arel.is_a?(Proc)
          arel = apply_arel_operation(arel, op, value) if arel && !arel.is_a?(Arel::Nodes::Node)
          arel || Arel::Nodes::False.new
        end
      end

    end
  end
end
