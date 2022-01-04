Gem::Specification.new do |s|
  s.name = 'scim2-filter'
  s.version = '0.2.1'
  s.summary = 'Parser for SCIM query filters'
  s.description = <<~DESCRIPTION
    RFC7644 SCIM (System for Cross-domain Identity Management) 2.0 filter parser.
    See https://tools.ietf.org/html/rfc7644#section-3.4.2.2

    This gem implements a filter syntax parser as well as an optional integration
    for integrating the filter with an Arel table.
  DESCRIPTION
  s.license = 'MIT'
  s.email = 'david.mccullars@gmail.com'
  s.homepage = 'https://github.com/david-mccullars/scim2-filter'

  s.authors = ['David McCullars']

  s.files = Dir['{lib}/**/*', 'README.md']

  s.required_ruby_version = '>= 3.0.0'
  s.add_runtime_dependency 'racc', '>= 1.5'

  s.add_development_dependency 'activerecord', '~> 6.1' # Used for testing arel handler but not otherwise required by the gem
  s.add_development_dependency 'rake'
  s.add_development_dependency 'redcarpet'
  s.add_development_dependency 'rexical', '>= 1.0'
  s.add_development_dependency 'rspec', '>= 3.0'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-rake'
  s.add_development_dependency 'rubocop-rspec'
  s.add_development_dependency 'sqlite3', '~> 1.4' # Used for testing arel handler but not otherwise required by the gem
  s.add_development_dependency 'yard'
end
