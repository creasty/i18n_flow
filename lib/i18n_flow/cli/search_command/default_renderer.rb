require 'erb'
require_relative '../../validator/errors'
require_relative '../color'

class I18nFlow::CLI::SearchCommand
  class DefaultRenderer
    include I18nFlow::CLI::Color

    FILE = __dir__ + '/default.erb'

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

      state = nil

      str.each_line.map do |l|
        case l
        when /^(=== )(.+)$/
          state = :header if state == nil
        when /^(    )([^\s]+)( \(.+:\d+\))$/
          state = :location if %i[header content].include?(state)
        when /^(    )(.+)/
          state = :content if %i[location content].include?(state)
        else
          state = nil
        end

        case state
        when :header
          l = $~[1]
          l << color($~[2], :yellow)
          l << "\n"
        when :location
          l = $~[1]
          l << color($~[2], :blue)
          l << $~[3]
          l << "\n"
        when :content
          l = color(l, :green)
        end

        l
      end.join
    end

    def erb
      @erb ||= ERB.new(File.read(FILE), 0, '-')
    end
  end
end
