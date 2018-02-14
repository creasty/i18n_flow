require_relative 'file_scope'
require_relative 'symmetry'
require_relative '../parser'

module I18nFlow::Validator
  class Multiplexer
    attr_reader :repository
    attr_reader :valid_locales
    attr_reader :locale_pairs
    attr_reader :linters

    def initialize(
      repository:,
      valid_locales:,
      locale_pairs:,
      linters: %i[file_scope symmetry]
    )
      @repository    = repository
      @valid_locales = valid_locales
      @locale_pairs  = locale_pairs
      @linters       = linters
    end

    def validate!
      @errors = nil

      if linters.include?(:file_scope)
        repository.asts_by_path.each do |path, tree|
          validator = FileScope.new(tree, filepath: path)
          validator.validate!
          validator.errors.each do |err|
            errors[err.file][err.key] = err
          end
        end
      end

      if linters.include?(:symmetry)
        repository.asts_by_scope.each do |scope, locale_trees|
          locale_pairs.each do |(master, slave)|
            master_tree = locale_trees[master]
            slave_tree = locale_trees[slave]
            next unless master_tree && slave_tree

            validator = Symmetry.new(master_tree[master], slave_tree[slave])
            validator.validate!
            validator.errors.each do |err|
              errors[err.file][err.key] = err
            end
          end
        end
      end
    end

    def errors
      @errors ||= Hash.new { |h, k| h[k] = {} }
    end
  end
end
