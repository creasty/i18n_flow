require_relative 'validation_error'

class I18nFlow::SymmetryValidator
  def validate(t1, t2)
    @errors = nil
    validate_hash(t1.hash, t2.hash)
  end

  def errors
    @errors ||= {}
  end

private

  def validate_hash(t1, t2)
    keys = t1.keys | t2.keys

    keys.each do |k|
      validate_node(t1[k], t2[k])
    end
  end

  def validate_node(n1, n2)
    return if n2&.ignored?

    if n1 && n2
      if n1.value? != n2.value?
        errors[n2.full_key] = I18nFlow::TypeMismatchError.new
      elsif n1.value?
        # TODO
      else
        validate_hash(n1.hash, n2.hash)
      end

      return
    end

    either = n1 || n2
    return if either.ignored?

    if either.has_only?
      if either.only != either.locale
        errors[either.full_key] = I18nFlow::InvalidLocaleError.new(
          expect: either.only,
          actual: either.locale,
          tag:    :only,
        )
      end

      return
    end

    errors[either.full_key] = I18nFlow::AsymmetricKeyError.new
  end
end
