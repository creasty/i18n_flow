require_relative 'command_base'

class I18nFlow::CLI
  class CopyCommand < CommandBase
    def invoke!
      exit_with_message(1, 'not implemented')
    end
  end
end
