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
    return if n1&.ignored? || n2&.ignored?

    check_only_tag(n1, n2)&.tap do |(key, err)|
      errors[key] = err if err
      return
    end

    check_only_tag(n2, n1)&.tap do |(key, err)|
      errors[key] = err if err
      return
    end

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
    errors[either.full_key] = I18nFlow::AsymmetricKeyError.new
  end

  def check_only_tag(n1, n2)
    return unless n1&.has_only?

    if !n1.valid_locale?
      [n1.full_key] << I18nFlow::InvalidLocaleError.new(
        expect: n1.valid_locales,
        actual: n1.locale,
        tag:    :only,
      )
    elsif n2&.locale && !n1.valid_locales.include?(n2.locale)
      [n2.full_key] << I18nFlow::InvalidLocaleError.new(
        expect: n1.valid_locales,
        actual: n2.locale,
        tag:    :only,
      )
    else
      [n1.full_key, nil]
    end
  end
end
