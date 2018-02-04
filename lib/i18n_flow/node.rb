require 'psych'

class I18nFlow::Node
  TAG_TODO   = '!todo'
  TAG_IGNORE = '!ignore'
  TAG_ONLY   = /^!only:([,a-zA-Z_-]+)$/

  attr_accessor :start_line
  attr_accessor :end_line
  attr_reader :value
  attr_reader :anchor
  attr_reader :valid_locales

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

    @valid_locales = []

    parse_tag!(tag)
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

  def value?
    !value.nil?
  end

  def has_anchor?
    !!anchor
  end

  def todo?
    @tag == :todo
  end

  def ignored?
    @tag == :ignore
  end

  def has_only?
    @tag == :only && @valid_locales.any?
  end

  def valid_locale?
    !has_only? || @valid_locales.include?(locale)
  end

private

  def parse_tag!(tag)
    return unless tag

    case tag
    when TAG_TODO
      @tag = :todo
    when TAG_ONLY
      @tag = :only
      @valid_locales = $1.split(',').freeze
    when TAG_IGNORE
      @tag = :ignore
    end
  end
end
