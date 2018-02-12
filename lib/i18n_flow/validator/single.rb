require_relative 'errors'
require_relative '../util'

module I18nFlow::Validator
  class Single
    attr_reader :ast
    attr_reader :filepath

    def initialize(ast, filepath:)
      @ast = ast
      @filepath = filepath
    end

    def filepath_scopes
      @filepath_scopes ||= I18nFlow::Util.filepath_to_scope(filepath)
    end

    def validate!
      @errors = nil
      validate_scope(ast, scopes: filepath_scopes)
    end

    def errors
      @errors ||= []
    end

  private

    def validate_scope(tree, scopes:)
      scopes.each_with_index do |scope, i|
        node = tree.content[scope]

        if node.nil?
          full_key = scopes[0..i].join('.')
          errors << MissingKeyError.new(full_key).set_location(tree)
          break
        end

        if tree.content.size > 1
          parent_scopes = scopes[0...i]
          (tree.content.keys - [scope]).each do |key|
            full_key = [*parent_scopes, key].join('.')
            errors << ExtraKeyError.new(full_key).set_location(node)
          end
          break
        end

        if node.value?
          full_key = scopes[0..i].join('.')
          errors << InvalidTypeError.new(full_key).set_location(node)
          break
        end

        tree = node
      end
    end
  end
end
