require 'psych'

class I18nFlow::Node
  TAG_TODO   = '!todo'
  TAG_IGNORE = '!ignore'
  TAG_ONLY   = /^!only:([\w-]+)$/

  attr_accessor :start_line
  attr_accessor :end_line
  attr_reader :value
  attr_reader :anchor
  attr_reader :only

  def initialize(
    scope:,
    value: nil,
    start_line: nil,
    end_line: nil,
    anchor: nil,
    tag: nil
  )
    @scope      = scope
    @value      = value
    @start_line = start_line
    @end_line   = end_line
    @anchor     = anchor

    parse_tag!(tag)
  end

  def has_anchor?
    !!anchor
  end

  def num_lines
    return 1 unless end_line
    end_line - start_line + 1
  end

  def level
    @scope.size
  end

  def key
    @scope.last
  end

  def locale
    @scope.first
  end

  def full_key
    @scope.join('.')
  end

  def hash
    @hash ||= {}
  end

  def todo?
    @tag == :todo
  end

  def ignored?
    @tag == :ignore
  end

  def value?
    !value.nil?
  end

  def has_only?
    !only.nil?
  end

private

  def parse_tag!(tag)
    return unless tag

    case tag
    when TAG_TODO
      @tag = :todo
    when TAG_ONLY
      @tag = :only
      @only = $1
    when TAG_IGNORE
      @tag = :ignore
    end
  end
end
