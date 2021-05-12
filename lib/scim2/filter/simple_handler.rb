module Scim2
  module Filter
    ##
    # Reference implementation of parser handler which captures parsed filters into a deeply nested Hash structure.
    #
    # @example
    #   # userName sw "J"
    #
    #   {
    #     sw: {
    #       path:   [:userName],
    #       schema: nil,
    #       value:  'J',
    #     },
    #   }
    #
    # @example
    #   # urn:ietf:params:scim:schemas:core:2.0:User:userType ne "Employee" and not (emails.value co "example.com" or emails.value co "example.org")
    #
    #   {
    #     and: [
    #       {
    #         ne: {
    #           path:   [:userType],
    #           schema: 'urn:ietf:params:scim:schemas:core:2.0:User',
    #           value:  'Employee',
    #         },
    #       },
    #       {
    #         not: {
    #           or: [
    #             {
    #               co: {
    #                 path:   %i[emails value],
    #                 schema: nil,
    #                 value:  'example.com',
    #               },
    #             },
    #             {
    #               co: {
    #                 path:   %i[emails value],
    #                 schema: nil,
    #                 value:  'example.org',
    #               },
    #             },
    #           ],
    #         },
    #       },
    #     ],
    #   }
    #
    # @example
    #   # emails[type eq "work"]
    #
    #   {
    #     path:   [:emails],
    #     schema: nil,
    #     nested: {
    #       eq: {
    #         path:   [:type],
    #         schema: nil,
    #         value:  'work',
    #       },
    #     },
    #   }
    #
    # @note This handler is intended only as a reference implementation for custom
    #       handlers and is otherwise not designed for production use.
    ##
    class SimpleHandler

      # Handle NOT filters (e.g. `not (color eq "red")`)
      # @param filter [Hash<Symbol, Object>] the internal filter being NOT'ed
      # @return [Hash<Symbol, Object>]
      def on_not_filter(filter, context:)
        { not: filter }
      end

      # Handle basic attribute comparison filters (e.g. `preference.color eq "red"`)
      # @param attribute_path [Array<Symbol>] the attribute name(s) being filtered on, split by `.`
      # @param value [Object] the value being compared against
      # @param op [Object] the comparison operator (e.g. `:eq`)
      # @param schema [String] schema namespace of the attribute
      # @return [Hash<Symbol, Object>]
      def on_attribute_filter(attribute_path, value, context:, op:, schema: nil)
        { op => { path: attribute_path, value: value, schema: schema } }
      end

      # Handle logical filters (e.g. `name.givenName sw "D" AND title co "VP"`)
      # @param filter1 [Hash<Symbol, Object>] the left-hand side filter
      # @param filter2 [Hash<Symbol, Object>] the right-hand side filter
      # @param op [Object] the logical operator (e.g. `AND`)
      # @return [Hash<Symbol, Object>]
      def on_logical_filter(filter1, filter2, context:, op:)
        { op => [filter1, filter2] }
      end

      # Handle nested filters (e.g. `emails[type eq "work"]`)
      # @param attribute_path [Array<Symbol>] the attribute name(s) being filtered on, split by `.`
      # @param filter [Hash<Symbol, Object>] the nested-filter inside the backets
      # @param schema [String] schema namespace of the attribute
      # @return [Hash<Symbol, Object>]
      def on_nested_filter(attribute_path, filter, context:, schema: nil)
        { path: attribute_path, nested: filter, schema: schema }
      end

    end
  end
end
