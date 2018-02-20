require_relative 'command_base'
require_relative '../repository'
require_relative '../search'

class I18nFlow::CLI
  class SearchCommand < CommandBase
    def invoke!
      unless pattern
        exit_with_message(1, 'usage: i18n_flow search PATTERN')
      end

      search.search!

      search.results.each do |r|
        p r
      end
    end

    def pattern
      args[0]
    end

  private

    def repository
      @repository ||= I18nFlow::Repository.new(
        base_path:     I18nFlow.config.base_path,
        glob_patterns: I18nFlow.config.glob_patterns,
      )
    end

    def search
      @search ||= I18nFlow::Search.new(
        repository: repository,
        pattern:    pattern,
      )
    end
  end
end
