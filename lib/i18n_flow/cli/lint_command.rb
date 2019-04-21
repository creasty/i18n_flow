require_relative 'command_base'
require_relative '../repository'
require_relative '../validator/multiplexer'

class I18nFlow::CLI
  class LintCommand < CommandBase
    require_relative 'lint_command/ascii_renderer'
    require_relative 'lint_command/markdown_renderer'

    DEFAULT_FORMAT = 'ascii'

    def invoke!
      validator.validate!

      case output_format
      when 'ascii'
        puts AsciiRenderer.new(validator.errors, color: color_enabled?).render
      when 'markdown'
        puts MarkdownRenderer.new(validator.errors, url_formatter: url_formatter).render
      else
        exit_with_message(1, 'Unsupported format: %s' % [output_format])
      end

      exit validator.errors.size.zero? ? 0 : 1
    end

    def output_format
      @output_format ||= options['format'] || DEFAULT_FORMAT
    end

    def url_formatter
      return @url_formatter if @url_formatter
      @url_formatter = options['url-formatter']
      @url_formatter ||= "file://#{I18nFlow.config.base_path}/%f#%l"
    end

  private

    def repository
      @repository ||= I18nFlow::Repository.new(
        base_path:     I18nFlow.config.base_path,
        glob_patterns: I18nFlow.config.glob_patterns,
      )
    end

    def validator
      @validator ||= I18nFlow::Validator::Multiplexer.new(
        repository:    repository,
        valid_locales: I18nFlow.config.valid_locales,
        locale_pairs:  I18nFlow.config.locale_pairs,
        linters:       I18nFlow.config.linters,
      )
    end
  end
end
