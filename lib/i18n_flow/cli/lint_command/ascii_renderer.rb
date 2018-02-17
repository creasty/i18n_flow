require 'erb'
require_relative '../../validator/errors'

class I18nFlow::CLI::LintCommand
  class AsciiRenderer
    COLORS = {
      black:   30,
      red:     31,
      green:   32,
      yellow:  33,
      blue:    34,
      magenta: 35,
      cyan:    36,
      white:   37,
    }.freeze

    FILE = __dir__ + '/ascii.erb'

    attr_reader :errors

    def initialize(errors, color: true)
      @errors = errors
      @color_enabled = !!color
    end

    def render
      with_color(erb.result(binding))
    end

    def color_enabled?
      @color_enabled
    end

    def file_count
      @file_count ||= errors.size
    end

    def error_count
      @error_count ||= errors.sum { |_, errs| errs.size }
    end

    def summary_line
      @summary_line ||= 'Found %d %s in %d %s' % [
        error_count,
        error_count == 1 ? 'violation' : 'violations',
        file_count,
        file_count == 1 ? 'file' : 'files',
      ]
    end

  private

    def with_color(str)
      return str unless color_enabled?

      str = str.gsub(/^(=== )(.+)$/) { $1 + color($2, :yellow) }
      str = str.gsub(/(#\d+)$/) { color($1, :yellow) }
      str = str.gsub(/^([ ]{8})(.+)$/) { $1 + color($2, :red) }
      str
    end

    def color(str, c)
      "\e[1;#{COLORS[c]}m#{str}\e[0m"
    end

    def erb
      @erb ||= ERB.new(File.read(FILE), 0, '-')
    end
  end
end
