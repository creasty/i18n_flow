require_relative 'command_base'

class I18nFlow::CLI
  class VersionCommand < CommandBase
    def invoke!
      puts 'i18n_flow v%s' % I18nFlow::VERSION
    end
  end
end
