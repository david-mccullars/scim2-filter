module Scim2
  ##
  #
  # RFC7644 SCIM (System for Cross-domain Identity Management) 2.0 defines
  # mechanisms to query resources.  This includes an optional `filter` parameter
  # which allows for comprehensive filtering of resources based on various
  # criteria.  The structure and syntax for the `filter` parameter is defined in
  # Section 3.4.2.2 of RFC7644.  This module contains classes to support the
  # validation and parsing of the `filter` parameter as well as its translation
  # into Arel nodes for use in querying a database.
  #
  # @see https://tools.ietf.org/html/rfc7644#section-3.4.2.2
  ##
  module Filter

    autoload :ArelHandler,        'scim2/filter/arel_handler'
    autoload :Lexer,              'scim2/filter/lexer'
    autoload :NoOpHandler,        'scim2/filter/no_op_handler'
    autoload :Parser,             'scim2/filter/parser'
    autoload :SimpleHandler,      'scim2/filter/simple_handler'

  end
end
