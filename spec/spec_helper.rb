$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'rspec'
require 'i18n_flow'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include UtilMacro
end
