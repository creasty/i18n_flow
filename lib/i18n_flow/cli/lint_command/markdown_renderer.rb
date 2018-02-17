require 'erb'
require_relative '../../validator/errors'

class I18nFlow::CLI::LintCommand
  class MarkdownRenderer
    FILE = __dir__ + '/markdown.erb'

    attr_reader :errors
    attr_reader :url_formatter

    def initialize(errors, url_formatter:)
      @errors = errors
      @url_formatter = url_formatter
    end

    def render
      with_link(erb.result(binding))
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

    def with_link(str)
      str.gsub(/\[(([^\]:]+)(?::(\d+))?)\]\(\)/) do
        '[%s](%s)' % [$1, link($2, $3)]
      end
    end

    def link(path, line)
      url = url_formatter
      url = url.gsub(/%f\b/, path)
      url = url.gsub(/%l\b/, line.to_s)
      url
    end

    def erb
      @erb ||= ERB.new(File.read(FILE), 0, '-')
    end
  end
end
