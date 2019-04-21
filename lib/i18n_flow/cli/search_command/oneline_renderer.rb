require 'erb'
require_relative '../../validator/errors'
require_relative '../color'

class I18nFlow::CLI::SearchCommand
  class OnelineRenderer
    include I18nFlow::CLI::Color

    FILE = __dir__ + '/oneline.erb'

    attr_reader :results

    def initialize(results, color: true)
      @results = results
      @color_enabled = !!color
    end

    def render
      with_color(erb.result(binding))
    end

    def color_enabled?
      @color_enabled
    end

  private

    def with_color(str)
      return str unless color_enabled?

      str.gsub!(/^(\S+)( \[)([^\]]+)(\] \([^\)]+\))(.*)/) { color($1, :yellow) + $2 + color($3, :blue) + $4 + color($5, :green) }
      str
    end

    def erb
      @erb ||= ERB.new(File.read(FILE), 0, '-')
    end
  end
end
