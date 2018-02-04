class I18nFlow::ValidationError; end

class I18nFlow::TypeMismatchError < I18nFlow::ValidationError
  def ==(other)
    other.is_a?(self.class)
  end
end

class I18nFlow::InvalidLocaleError < I18nFlow::ValidationError
  attr_reader :expect
  attr_reader :actual
  attr_reader :tag

  def initialize(expect:, actual:, tag:)
    @expect = expect
    @actual = actual
    @tag    = tag
  end

  def ==(other)
    return false unless other.is_a?(self.class)
    [expect, actual, tag] == [other.expect, other.actual, other.tag]
  end
end

class I18nFlow::AsymmetricKeyError < I18nFlow::ValidationError
  def ==(other)
    other.is_a?(self.class)
  end
end
