require_relative 'command_base'

class I18nFlow::CLI
  class ReadConfigCommand < CommandBase
    def invoke!
      unless key
        exit_with_message(1, 'usage: i18n_flow read_config KEY')
      end

      case key
      when 'base_path'
        puts I18nFlow.config.base_path
      end
    end

    def key
      args[0]
    end
  end
end
