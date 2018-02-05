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
        key = scopes[0..i].join('.')
        errors << I18nFlow::MissingKeyError.new(key)
        break
      end

      if tree.content.size > 1
        key = scopes[0...i].join('.')
        errors << I18nFlow::ExtraKeysError.new(key,
          extra_keys: tree.content.keys - [scope],
        ).set_location(node)
        break
      end

      if node.value?
        key = scopes[0..i].join('.')
        errors << I18nFlow::InvalidTypeError.new(key).set_location(node)
        break
      end

      tree = node
    end
  end
end
