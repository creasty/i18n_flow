require_relative 'command_base'
require_relative '../repository'
require_relative '../validator/multiplexer'

class I18nFlow::CLI
  class LintCommand < CommandBase
    require_relative 'lint_command/ascii_renderer'

    def invoke!
      validator.validate!

      case output_format
      when 'ascii', nil
        puts AsciiRenderer.new(validator.errors).render
      else
        exit_with_message(1, 'Unsupported format: %s' % [output_format])
      end

      exit validator.errors.size.zero? ? 0 : 1
    end

    def output_format
      return @output_format if defined?(@output_format)
      @output_format = options['format'] || options['f']
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
