require_relative 'command_base'
require_relative 'color'
require_relative '../repository'
require_relative '../search'

class I18nFlow::CLI
  class SearchCommand < CommandBase
    include I18nFlow::CLI::Color

    def invoke!
      unless pattern
        exit_with_message(1, 'usage: i18n_flow search PATTERN')
      end

      search.search!

      search.results.each do |key, matches|
        puts '=== %s' % [color(key, :yellow)]

        matches.each do |m|
          puts '    %s (%s:%s)' % [color(m.locale, :blue), m.file, m.line]
          if m.value
            puts color(m.value, :green).gsub(/^/, '    ')
          end
        end

        puts
      end

      puts '%d %s' % [result_size, result_size == 1 ? 'hit' : 'hits']
    end

    def pattern
      args[0]
    end

    def include_all?
      !!(options['all'] || options['a'])
    end

    def result_size
      @result_size ||= search.results.size
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
