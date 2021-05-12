require_relative 'parser.tab'

module Scim2
  module Filter
    ##
    # Implements a SCIM2 compliant event-based parser for query filters.  The parser
    # will emit four different events to a handler implemention as it encounters
    # various components within the filter.  For reference, see:
    #
    # * {SimpleHandler#on_not_filter}
    # * {SimpleHandler#on_attribute_filter}
    # * {SimpleHandler#on_logical_filter}
    # * {SimpleHandler#on_nested_filter}
    ##
    class Parser < ::Racc::Parser

      attr_reader :handler

      # @param handler <Handler> a handler object that responds to all four events
      def initialize(handler = SimpleHandler.new)
        super()
        @handler = handler
      end

      # Required by {::Racc::Parser} to emit the next token to the parser.  This
      # method should generally not be called directly.
      # @return <String> the next token
      def next_token
        @lexer.next_token
      end

      # Parses a given string input
      # @param string <String> the filter to parse
      # @return <Object> returns the last object emitted by the handler
      def parse(string)
        @lexer = Lexer.new
        @lexer.scan_setup(string)
        do_parse
      end

    end
  end
end
