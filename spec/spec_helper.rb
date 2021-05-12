# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path('support/**/*.rb', __dir__)].each do |f|
  require f
end

require 'scim2'
