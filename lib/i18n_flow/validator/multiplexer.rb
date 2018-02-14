require_relative 'single'
require_relative 'symmetry'
require_relative '../parser'

module I18nFlow::Validator
  class Multiplexer
    attr_reader :repository
    attr_reader :valid_locales
    attr_reader :locale_pairs

    def initialize(
      repository:,
      valid_locales:,
      locale_pairs:
    )
      @repository    = repository
      @valid_locales = valid_locales
      @locale_pairs  = locale_pairs
    end

    def validate!
      @errors = nil

      repository.asts_by_path.each do |path, tree|
        single = Single.new(tree, filepath: path)
        single.validate!
        single.errors.each do |err|
          errors[err.file][err.key] = err
        end
      end

      repository.asts_by_scope.each do |scope, locale_trees|
        locale_pairs.each do |(master, slave)|
          master_tree = locale_trees[master]
          slave_tree = locale_trees[slave]
          next unless master_tree && slave_tree

          symmetry = Symmetry.new(master_tree[master], slave_tree[slave])
          symmetry.validate!
          symmetry.errors.each do |err|
            errors[err.file][err.key] = err
          end
        end
      end
    end

    def errors
      @errors ||= Hash.new { |h, k| h[k] = {} }
    end
  end
end
