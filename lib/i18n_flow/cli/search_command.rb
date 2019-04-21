require_relative 'command_base'
require_relative 'color'
require_relative '../repository'
require_relative '../search'

class I18nFlow::CLI
  class SearchCommand < CommandBase
    require_relative 'search_command/default_renderer'

    DEFAULT_FORMAT = 'default'

    def invoke!
      unless pattern
        exit_with_message(1, 'usage: i18n_flow search PATTERN')
      end

      search.search!

      case output_format
      when 'default'
        puts DefaultRenderer.new(search.results).render
      else
        exit_with_message(1, 'Unsupported format: %s' % [output_format])
      end
    end

    def pattern
      args[0]
    end

    def output_format
      @output_format ||= options['format'] || DEFAULT_FORMAT
    end

    def include_all?
      !!(options['all'] || options['a'])
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
        repository:  repository,
        pattern:     pattern,
        include_all: include_all?,
      )
    end
  end
end
