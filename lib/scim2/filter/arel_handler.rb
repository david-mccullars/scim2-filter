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
    #   # urn:ietf:params:scim:schemas:core:2.0:User:userType ne "Employee" and not (emails.value co "example.com" or emails.value co "example.org")
    #
    #   mapping = {
    #     userType: User.arel_table[:type],
    #     emails: {
    #       value: User.arel_table[:email],
    #     },
    #   }
    #
    #   # "users"."type" != 'Employee' AND NOT ("users"."email" LIKE '%example.com' OR "users"."email" LIKE '%example.org%')
    #
    # @note Nested filters (e.g. `emails[type eq "work"]` are not supported at this
    #       time and will result in an `ArgumentError`
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
        else
          raise Racc::ParseError, "invalid attribute operand #{op.inspect} with argument #{value.inspect}"
        end
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

      # Handle nested filters (e.g. `emails[type eq "work"]`)
      # @param attribute_path [Array<Symbol>] the attribute name(s) being filtered on, split by `.`
      # @param filter [Hash<Symbol, Object>] the nested filter inside the backets
      # @param schema [String] schema namespace of the attribute
      # @return [Hash<Symbol, Object>]
      def on_nested_filter(attribute_path, filter, context:, schema: nil)
        raise ArgumentError, 'Nested attributes are not currently supported for AREL'
      end

      protected

      # Looks up the arel object from the mapping according to the given attribute path
      # @param attribute_path [Array<Symbol>] the attribute name(s) being filtered on, split by `.`
      # @return [Object] the object returned by the mapping
      def lookup_arel(attribute_path)
        arel = arel_mapping.dig(*attribute_path)
        case arel
        when NilClass
          raise ArgumentError, "Attribute #{attribute_path.join(',').inspect} not found in mapping"
        when Arel::Predications
          arel
        else
          raise ArgumentError, "Mapping for attribute #{attribute_path.join(',').inspect} is not a valid arel object"
        end
      end
    end
  end
end
