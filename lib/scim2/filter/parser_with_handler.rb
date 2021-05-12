module Scim2
  module Filter
    module ParserWithHandler

      attr_reader :handler

      def initialize(handler = BaseHandler.new)
        @handler = handler
      end

      def next_token
        @lexer.next_token
      end

      def parse(string)
        @lexer = Lexer.new
        @lexer.scan_setup(string)
        do_parse
      end

    end
  end
end
