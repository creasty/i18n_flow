$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'i18n_flow'
require 'rspec'
require 'fakefs/spec_helpers'
require 'pry'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

Pry.config.history.should_load = false
Pry.config.history.should_save = false

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers
  config.include UtilMacro
end
