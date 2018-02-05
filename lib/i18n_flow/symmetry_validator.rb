require_relative 'validation_error'
require_relative 'util'

class I18nFlow::SymmetryValidator
  def validate(t1, t2)
    @errors = nil
    validate_content(t1, t2)
  end

  def errors
    @errors ||= []
  end

private

  def validate_content(t1, t2)
    keys = t1.content.keys | t2.content.keys

    keys.each do |k|
      validate_node(t1, t2, k)
    end
  end

  def validate_node(t1, t2, key)
    n1 = t1.content[key]
    n2 = t2.content[key]

    return if n1&.ignored? || n2&.ignored?

    check_only_tag(n1, n2)&.tap do |err|
      errors << err if err
      return
    end

    check_only_tag(n2, n1)&.tap do |err|
      errors << err if err
      return
    end

    check_asymmetric_key(n1, n2, t2)&.tap do |err|
      errors << err
      return
    end

    check_type(n1, n2)&.tap do |err|
      errors << err
      return
    end

    if n1.value?
      check_args(n1, n2)&.tap do |err|
        errors << err
      end
    else
      validate_content(n1, n2)
    end
  end

  def check_only_tag(n1, n2)
    return unless n1&.has_only?

    if !n1.valid_locale?
      I18nFlow::InvalidLocaleError.new(n1.full_key,
        expect: n1.valid_locales,
        actual: n1.locale,
      ).set_location(n1)
    elsif n2&.locale && !n1.valid_locales.include?(n2.locale)
      I18nFlow::InvalidLocaleError.new(n2.full_key,
        expect: n1.valid_locales,
        actual: n2.locale,
      ).set_location(n2)
    else
      false
    end
  end

  def check_type(n1, n2)
    return unless n1 && n2
    return if n1.value? == n2.value?

    I18nFlow::InvalidTypeError.new(n2.full_key).set_location(n2)
  end

  def check_asymmetric_key(n1, n2, t2)
    return if n1 && n2

    if n1
      I18nFlow::MissingKeyError.new(n1.full_key(locale: t2.locale)).set_location(t2)
    else
      I18nFlow::ExtraKeyError.new(n2.full_key).set_location(n2)
    end
  end

  def check_args(n1, n2)
    args_1 = I18nFlow::Util.extract_args(n1.value)
    args_2 = I18nFlow::Util.extract_args(n2.value)

    return if args_1 == args_2

    I18nFlow::AsymmetricArgsError.new(n2.full_key,
      expect: args_1,
      actual: args_2,
    ).set_location(n2)
  end
end
