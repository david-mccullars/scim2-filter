Gem::Specification.new do |s|
  s.name = 'scim2-filter'
  s.version = '0.1.0'
  s.summary = 'Parser for SCIM query filters'
  s.description = <<~DESCRIPTION
    RFC7643 SCIM(System for Cross-domain Identity Management) 2.0 filter parser.
    See https://tools.ietf.org/html/rfc7644#section-3.4.2.2

    This gem implements a filter syntax parser as well as an optional integration
    for integrating the filter with an Arel table.
  DESCRIPTION
  s.license = 'MIT'
  s.email = 'david.mccullars@gmail.com'
  s.homepage = 'https://github.com/david-mccullars/scim2-filter'

  s.authors = ['David McCullars']

  s.files = Dir["{lib}/**/*", 'README.md']
  s.test_files = Dir["spec/**/*"]

  s.add_development_dependency 'arel', '>= 9.0'
  s.add_development_dependency 'racc', '>= 1.5'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rexical', '>= 1.0'
  s.add_development_dependency 'rspec', '>= 3.0'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'yard'
end
