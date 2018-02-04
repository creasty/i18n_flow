$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'i18n_flow'
require 'rspec'
require 'fakefs/spec_helpers'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers
  config.include UtilMacro
end
