require_relative 'command_base'
require_relative 'color'
require_relative '../repository'
require_relative '../formatter'
require_relative '../corrector'

class I18nFlow::CLI
  class FormatCommand < CommandBase
    include I18nFlow::CLI::Color

    def invoke!
      puts color('==> Correcting', :yellow)
      repository.asts_by_scope.each do |scope, locale_trees|
        locale_pairs.each do |(master, slave)|
          master_tree = locale_trees[master]
          slave_tree = locale_trees[slave]
          next unless master_tree && slave_tree

          puts slave_tree.file_path
          correct(slave_tree, master_tree)
        end
      end

      puts
      puts color('==> Formatting', :yellow)
      repository.asts_by_path.each do |path, tree|
        puts path

        format(tree)

        output_path = I18nFlow.config.base_path.join(tree.file_path)
        File.write(output_path, tree.to_yaml)
      end
    end

  private

    def locale_pairs
      I18nFlow.config.locale_pairs
    end

    def repository
      @repository ||= I18nFlow::Repository.new(
        base_path:     I18nFlow.config.base_path,
        glob_patterns: I18nFlow.config.glob_patterns,
      )
    end

    def correct(slave_tree, master_tree)
      I18nFlow::Corrector.new(slave_tree, master_tree).correct!
    end

    def format(tree)
      I18nFlow::Formatter.new(tree).format!
    end
  end
end
