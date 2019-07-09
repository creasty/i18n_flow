require_relative 'command_base'
require_relative '../repository'
require_relative '../formatter'

class I18nFlow::CLI
  class FormatCommand < CommandBase
    def invoke!
      repository.asts_by_scope.each do |scope, locale_trees|
        locale_pairs.each do |(master, slave)|
          master_tree = locale_trees[master]
          slave_tree = locale_trees[slave]
          next unless master_tree && slave_tree

          formatter = I18nFlow::Formatter.new(slave_tree, master_tree)
          formatter.format!
          output_path = I18nFlow.config.base_path.join(slave_tree.file_path)
          File.write(output_path, slave_tree.to_yaml)
        end
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
  end
end
