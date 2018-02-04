require 'pathname'
require_relative 'validation_error'
require_relative 'single_validator'
require_relative 'symmetry_validator'
require_relative 'parser'

class I18nFlow::Validator
  def initialize(
    base_path:,
    glob_patterns:,
    valid_locales:,
    master_locale:
  )
    @base_path     = Pathname.new(base_path)
    @glob_patterns = glob_patterns.to_a
    @valid_locales = valid_locales.to_a
    @master_locale = master_locale.to_s
  end

  def validate
    @errors = nil

    trees.each do |path, tree|
      single.validate(tree, filepath: path)
      errors[path].merge!(single.errors) if single.errors.any?
    end

    trees_by_scope.each do |scope, locale_trees|
      master_tree = locale_trees[@master_locale]
      next unless master_tree

      foreign_locales = locale_trees.keys - [@master_locale]
      foreign_trees = locale_trees.values_at(*foreign_locales)

      foreign_locales.zip(foreign_trees).each do |(locale, foreign_tree)|
        symmetry.validate(master_tree[@master_locale], foreign_tree[locale])
        errors[scope].merge!(symmetry.errors) if symmetry.errors.any?
      end
    end
  end

  def errors
    @errors ||= Hash.new { |h, k| h[k] = {} }
  end

  def single
    @single ||= I18nFlow::SingleValidator.new
  end

  def symmetry
    @symmetry ||= I18nFlow::SymmetryValidator.new
  end

  def parser
    @parser ||= I18nFlow::Parser.new
  end

  def file_paths
    @file_paths ||= @glob_patterns
      .flat_map { |pattern| Dir.glob(@base_path.join(pattern)) }
  end

  def trees
    @trees ||= file_paths
      .map { |path|
        File.open(path) { |f| parser.parse(f.read) }
        rel_path = Pathname.new(path).relative_path_from(@base_path)
        [rel_path.to_s, parser.tree]
      }
      .to_h
  end

  def trees_by_scope
    @trees_by_scope ||= Hash.new { |h, k| h[k] = {} }
      .tap { |h|
        trees.each { |path, tree|
          locale, *scopes = I18nFlow::Util.filepath_to_scope(path)
          h[scopes.join('.')][locale] = tree
        }
      }
  end
end
