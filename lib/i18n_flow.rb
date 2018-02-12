module I18nFlow
  extend self

  def config
    @config ||= Configuration.new.tap do |c|
      c.auto_configure!
    end
  end

  def configure(&block)
    config.update(&block)
  end
end

require_relative 'i18n_flow/version'
require_relative 'i18n_flow/configuration'
require_relative 'i18n_flow/validator'
