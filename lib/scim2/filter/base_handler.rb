module Scim2
  module Filter
    class BaseHandler

      def initialize(logger = nil)
        @logger = logger
      end

      def on_grouped_filter(filter, context:)
        @logger&.debug { "GROUPED FILTER: filter1=#{filter.inspect}" }
        { group: filter }
      end

      def on_not_filter(filter, context:)
        @logger&.debug { "NOT FILTER: filter=#{filter.inspect}" }
        { not: filter.fetch(:group) }
      end

      def on_attribute_filter(attribute_path, value, context:, op:, schema: nil)
        @logger&.debug { "ATTRIBUTE FILTER: attribute_path=#{attribute_path.join('.')} op=#{op} value=#{value.inspect}" }
        { op => { path: attribute_path, value: value, schema: schema } }
      end

      def on_logical_filter(filter1, filter2, context:, op:)
        @logger&.debug { "LOGICAL FILTER: filter1=#{filter1.inspect} op=#{op} filter2=#{filter2.inspect}" }
        if op == :and && filter1[:or]
          filter1a, filter1b = filter1[:or]
          { or: [filter1a, { and: [filter1b, filter2] }] }
        else
          { op => [filter1, filter2] }
        end
      end

      def on_sub_filter(attribute_path, filter, context:, schema: nil)
        { path: attribute_path, sub: filter, schema: schema }
      end

    end
  end
end
