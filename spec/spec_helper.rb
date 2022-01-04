$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '.tab.rb'
  add_filter '.rex.rb'
end

require 'scim2-filter'
# Ensure all files get loaded (for coverage sake)
Dir[File.expand_path('../lib/**/*.rb', __dir__)].each do |f|
  require f[%r{lib/(.*)\.rb$}, 1]
end
