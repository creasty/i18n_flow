require_relative 'single'
require_relative 'symmetry'
require_relative '../parser'

module I18nFlow::Validator
  class Multiplexer
    attr_reader :repository
    attr_reader :valid_locales
    attr_reader :master_locale

    def initialize(
      repository:,
      valid_locales:,
      master_locale:
    )
      @repository    = repository
      @valid_locales = valid_locales.to_a
      @master_locale = master_locale.to_s
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
        master_tree = locale_trees[master_locale]
        next unless master_tree

        foreign_locales = locale_trees.keys - [master_locale]
        foreign_trees = locale_trees.values_at(*foreign_locales)

        foreign_locales.zip(foreign_trees).each do |(locale, foreign_tree)|
          symmetry = Symmetry.new(master_tree[master_locale], foreign_tree[locale])
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
