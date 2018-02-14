require_relative 'command_base'
require_relative '../repository'
require_relative '../splitter'

class I18nFlow::CLI
  class SplitCommand < CommandBase
    def invoke!
      exit_with_message(1, 'not implemented')
    end

  private

    def repository
      @repository ||= I18nFlow::Repository.new(
        base_path:     I18nFlow.config.base_path,
        glob_patterns: I18nFlow.config.glob_patterns,
      )
    end
  end
end
