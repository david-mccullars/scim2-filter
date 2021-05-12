require_relative 'lexer.rex'

module Scim2
  module Filter
    ##
    # Implements a SCIM2 compliant lexer for query filters.
    # This class is responsible for producing and emitting
    # tokens for consumption by a parser.  It is not
    # intended to use directly.
    ##
    class Lexer < ::Racc::Parser

    end
  end
end
