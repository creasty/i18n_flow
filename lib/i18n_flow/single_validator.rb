require_relative 'validation_error'
require_relative 'util'

class I18nFlow::SingleValidator
  def validate(hash, filepath:)
    @errors = nil
    scopes = I18nFlow::Util.filepath_to_scope(filepath)
    validate_scope(hash, scopes: scopes)
  end

  def errors
    @errors ||= {}
  end

private

  def validate_scope(hash, scopes:)
    scopes.each_with_index do |scope, i|
      node = hash[scope]

      if node.nil?
        key = scopes[0..i].join('.')
        errors[key] = I18nFlow::MissingKeyError.new
        break
      end

      if hash.size > 1
        key = scopes[0...i].join('.')
        errors[key] = I18nFlow::ExtraKeysError.new(
          extra_keys: hash.keys - [scope],
        )
        break
      end

      if node.value?
        key = scopes[0..i].join('.')
        errors[key] = I18nFlow::InvalidTypeError.new
        break
      end

      hash = node.hash
    end
  end
end
