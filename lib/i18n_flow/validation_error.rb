class I18nFlow::ValidationError
  def ==(other)
    return false unless other.is_a?(self.class)
    data == other.data
  end

  def data
  end
end

class I18nFlow::TypeMismatchError < I18nFlow::ValidationError
  def ==(other)
    other.is_a?(self.class)
  end
end

class I18nFlow::InvalidLocaleError < I18nFlow::ValidationError
  attr_reader :expect
  attr_reader :actual

  def initialize(expect:, actual:)
    @expect = expect
    @actual = actual
  end

  def data
    [expect, actual]
  end
end

class I18nFlow::AsymmetricKeyError < I18nFlow::ValidationError
  def ==(other)
    other.is_a?(self.class)
  end
end

class I18nFlow::AsymmetricArgsError < I18nFlow::ValidationError
  attr_reader :expect
  attr_reader :actual

  def initialize(expect:, actual:)
    @expect = expect
    @actual = actual
  end

  def data
    [expect, actual]
  end
end
