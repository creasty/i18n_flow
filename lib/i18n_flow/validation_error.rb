class I18nFlow::ValidationError
  attr_reader :key
  attr_reader :file
  attr_reader :line

  def initialize(key)
    @key = key
  end

  def ==(other)
    return false unless other.is_a?(self.class)
    data == other.data
  end

  def data
    [key]
  end

  def set_location(node)
    @file = node.file_path
    @line = node.start_line
    self
  end
end

class I18nFlow::TypeMismatchError < I18nFlow::ValidationError
end

class I18nFlow::InvalidLocaleError < I18nFlow::ValidationError
  attr_reader :expect
  attr_reader :actual

  def initialize(key, expect:, actual:)
    super(key)
    @expect = expect
    @actual = actual
  end

  def data
    super + [expect, actual]
  end
end

class I18nFlow::AsymmetricKeyError < I18nFlow::ValidationError
end

class I18nFlow::AsymmetricArgsError < I18nFlow::ValidationError
  attr_reader :expect
  attr_reader :actual

  def initialize(key, expect:, actual:)
    super(key)
    @expect = expect
    @actual = actual
  end

  def data
    super + [expect, actual]
  end
end

class I18nFlow::InvalidTypeError < I18nFlow::ValidationError
end

class I18nFlow::MissingKeyError < I18nFlow::ValidationError
end

class I18nFlow::ExtraKeyError < I18nFlow::ValidationError
end
