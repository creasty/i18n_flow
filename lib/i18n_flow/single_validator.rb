require_relative 'validation_error'
require_relative 'util'

class I18nFlow::SingleValidator
  def validate(tree, filepath:)
    @errors = nil
    scopes = I18nFlow::Util.filepath_to_scope(filepath)
    validate_scope(tree, scopes: scopes)
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
        errors << I18nFlow::MissingKeyError.new(full_key).set_location(tree)
        break
      end

      if tree.content.size > 1
        parent_scopes = scopes[0...i]
        (tree.content.keys - [scope]).each do |key|
          full_key = [*parent_scopes, key].join('.')
          errors << I18nFlow::ExtraKeyError.new(full_key).set_location(node)
        end
        break
      end

      if node.value?
        full_key = scopes[0..i].join('.')
        errors << I18nFlow::InvalidTypeError.new(full_key).set_location(node)
        break
      end

      tree = node
    end
  end
end
