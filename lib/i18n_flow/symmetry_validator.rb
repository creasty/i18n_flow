require_relative 'validation_error'
require_relative 'util'

class I18nFlow::SymmetryValidator
  def validate(t1, t2)
    @errors = nil
    validate_hash(t1.hash, t2.hash)
  end

  def errors
    @errors ||= {}
  end

private

  def validate_hash(h1, h2)
    keys = h1.keys | h2.keys

    keys.each do |k|
      validate_node(h1[k], h2[k])
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

    check_asymmetric_key(n1, n2)&.tap do |(key, err)|
      errors[key] = err
      return
    end

    check_type(n1, n2)&.tap do |(key, err)|
      errors[key] = err
      return
    end

    if n1.value?
      check_args(n1, n2)&.tap do |(key, err)|
        errors[key] = err
      end
    else
      validate_hash(n1.hash, n2.hash)
    end
  end

  def check_only_tag(n1, n2)
    return unless n1&.has_only?

    if !n1.valid_locale?
      [n1.full_key] << I18nFlow::InvalidLocaleError.new(
        expect: n1.valid_locales,
        actual: n1.locale,
      )
    elsif n2&.locale && !n1.valid_locales.include?(n2.locale)
      [n2.full_key] << I18nFlow::InvalidLocaleError.new(
        expect: n1.valid_locales,
        actual: n2.locale,
      )
    else
      [n1.full_key, nil]
    end
  end

  def check_type(n1, n2)
    return unless n1 && n2
    return if n1.value? == n2.value?

    [n2.full_key] << I18nFlow::TypeMismatchError.new
  end

  def check_asymmetric_key(n1, n2)
    return if n1 && n2

    either = n1 || n2
    [either.full_key] << I18nFlow::AsymmetricKeyError.new
  end

  def check_args(n1, n2)
    args_1 = I18nFlow::Util.extract_args(n1.value)
    args_2 = I18nFlow::Util.extract_args(n2.value)

    return if args_1 == args_2

    [n2.full_key] << I18nFlow::AsymmetricArgsError.new(
      expect: args_1,
      actual: args_2,
    )
  end
end
