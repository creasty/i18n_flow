require_relative 'validation_error'
require_relative 'util'

class I18nFlow::SingleValidator
  def validate(hash, filepath:)
    @errors = nil

    scopes = I18nFlow::Util.filepath_to_scope(filepath)

    scopes.each_with_index do |scope, i|
      current_scopes = scopes[0..i]

      node = hash[scope]
      if node.nil?
        errors[current_scopes.join('.')] = I18nFlow::MissingKeyError.new
        break
      end

      if hash.size > 1
        errors[current_scopes[0...-1].join('.')] = I18nFlow::ExtraKeysError.new(
          extra_keys: hash.keys - [scope],
        )
        break
      end

      if node.value?
        errors[current_scopes.join('.')] = I18nFlow::InvalidTypeError.new
        break
      end

      hash = node.hash
    end
  end

  def errors
    @errors ||= {}
  end
end
