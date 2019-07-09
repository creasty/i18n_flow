module I18nFlow::Validator
  class Error
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

    def single?
      !!@single
    end

    def set_location(node)
      @file = node.file_path
      @line = node.start_line
      self
    end
  end

  class InvalidTypeError < Error
    def initialize(key, single: false)
      super(key)
      @single = single
    end
  end

  class MissingKeyError < Error
    attr_reader :dest_node
    attr_reader :dest_key
    attr_reader :src_node

    def initialize(key, single: false)
      super(key)
      @single = single
    end

    def set_correction_context(dest_node:, dest_key:, src_node:)
      @dest_node, @dest_key, @src_node = dest_node, dest_key, src_node
      self
    end
  end

  class ExtraKeyError < Error
    def initialize(key, single: false)
      super(key)
      @single = single
    end
  end

  class InvalidTodoError < Error
  end

  class TodoContentError < Error
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

  class InvalidLocaleError < Error
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

  class AsymmetricArgsError < Error
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
end
