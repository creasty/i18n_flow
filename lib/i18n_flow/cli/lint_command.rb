require_relative 'command_base'
require_relative '../repository'
require_relative '../validator/errors'
require_relative '../validator/multiplexer'

class I18nFlow::CLI
  class LintCommand < CommandBase
    def invoke!
      validator.validate!
      print_errors
    end

    def print_errors
      file_count  = 0
      error_count = 0

      validator.errors.each do |file, errors|
        file_count += 1
        puts '=== %s' % [color(file, :yellow)]

        errors.each do |full_key, err|
          error_count += 1
          puts print_key(full_key, err.line)
          print color(format_error(err), :red)
        end

        puts
      end

      summary = 'Found %d %s in %d %s' % [
        error_count,
        error_count == 1 ? 'violation' : 'violations',
        file_count,
        file_count == 1 ? 'file' : 'files',
      ]

      exit_with_message(error_count.zero? ? 0 : 1, summary)
    end

  private

    def print_key(full_key, line)
      line = '#%d' % [line]
      '    %s  %s' % [full_key, color(line, :yellow)]
    end

    def format_error(err)
      case err
      when I18nFlow::Validator::InvalidTypeError
        if err.single?
          <<-MESSAGE
        the top-level scope must match with the file path
        reason: unexpected structure
          MESSAGE
        else
          <<-MESSAGE
        the structure mismatches with the master file
          MESSAGE
        end
      when I18nFlow::Validator::MissingKeyError
        if err.single?
          <<-MESSAGE
        the top-level scope must match with the file path
        reason: missing key
          MESSAGE
        else
          <<-MESSAGE
        missing key
          MESSAGE
        end
      when I18nFlow::Validator::ExtraKeyError
        if err.single?
          <<-MESSAGE
        the top-level scope must match with the file path
        reason: extra key
          MESSAGE
        else
          <<-MESSAGE
        extra key
          MESSAGE
        end
      when I18nFlow::Validator::InvalidTodoError
        <<-MESSAGE
        todo cannot be tagged on mapping/sequence
        MESSAGE
      when I18nFlow::Validator::TodoContentError
        <<-MESSAGE
        has "todo" but the content diverges from the master file
        master: #{err.expect}
        got:    #{err.actual}
        MESSAGE
      when I18nFlow::Validator::InvalidLocaleError
        <<-MESSAGE
        has "only" but the locale is invalid
        valid: [#{err.expect.join(', ')}]
        got:   #{err.actual}
        MESSAGE
      when I18nFlow::Validator::AsymmetricArgsError
        <<-MESSAGE
        interpolation arguments diverge from the master file
        master: [#{err.expect.join(', ')}]
        got:    [#{err.actual.join(', ')}]
        MESSAGE
      end
    end

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
        master_locale: I18nFlow.config.master_locale,
      )
    end
  end
end
