module Scim2
  module Filter
    ##
    # A no-op handler implementation which does nothing with parse events.  Its
    # primary is for validation where the parsed data is not needed.
    ##
    class NoOpHandler

      # Handle NOT filters (e.g. `not (color eq "red")`)
      # @return [NilClass]
      def on_not_filter(filter, context:); end

      # Handle basic attribute comparison filters (e.g. `preference.color eq "red"`)
      # @return [NilClass]
      def on_attribute_filter(attribute_path, value, context:, op:, schema: nil); end

      # Handle logical filters (e.g. `name.givenName sw "D" AND title co "VP"`)
      # @return [NilClass]
      def on_logical_filter(filter1, filter2, context:, op:); end

      # Handle sub filters (e.g. `emails[type eq "work"]`)
      # @return [NilClass]
      def on_nested_filter(attribute_path, filter, context:, schema: nil); end

    end
  end
end
