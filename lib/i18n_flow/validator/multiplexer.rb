require 'pathname'
require_relative 'errors'
require_relative 'single'
require_relative 'symmetry'
require_relative '../parser'

module I18nFlow::Validator
  class Multiplexer
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

    def validate!
      @errors = nil

      trees.each do |path, tree|
        single = Single.new(tree, filepath: path)
        single.validate!
        single.errors.each do |err|
          errors[err.file][err.key] = err
        end
      end

      trees_by_scope.each do |scope, locale_trees|
        master_tree = locale_trees[@master_locale]
        next unless master_tree

        foreign_locales = locale_trees.keys - [@master_locale]
        foreign_trees = locale_trees.values_at(*foreign_locales)

        foreign_locales.zip(foreign_trees).each do |(locale, foreign_tree)|
          symmetry = Symmetry.new(master_tree.content[@master_locale], foreign_tree.content[locale])
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

    def file_paths
      @file_paths ||= @glob_patterns
        .flat_map { |pattern| Dir.glob(@base_path.join(pattern)) }
    end

    def trees
      @trees ||= file_paths
        .map { |path|
          rel_path = Pathname.new(path).relative_path_from(@base_path).to_s
          parser = I18nFlow::Parser.new(File.read(path), file_path: rel_path)
          parser.parse!
          [rel_path, parser.tree]
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
end
