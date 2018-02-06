require 'psych'

class I18nFlow::Node
  TAG_IGNORE = '!ignore'
  TAG_TODO   = /^!todo(?::([,a-zA-Z_-]+))?$/
  TAG_ONLY   = /^!only:([,a-zA-Z_-]+)$/

  attr_accessor :start_line
  attr_accessor :end_line
  attr_reader :scopes
  attr_reader :file_path
  attr_reader :value
  attr_reader :anchor
  attr_reader :todo_locales
  attr_reader :valid_locales

  def initialize(
    scopes:,
    file_path: nil,
    value: nil,
    start_line: nil,
    end_line: nil,
    anchor: nil,
    tag: nil
  )
    @scopes     = scopes.freeze
    @file_path  = file_path
    @value      = value
    @start_line = start_line
    @end_line   = end_line
    @anchor     = anchor

    @todo_locales  = []
    @valid_locales = []

    parse_tag!(tag)
  end

  def num_lines
    return 1 unless end_line
    end_line - start_line + 1
  end

  def key
    @scopes.last
  end

  def locale
    @scopes.first
  end

  def full_key
    @scopes.join('.')
  end

  def content
    @content ||= {}
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

  def only?
    @tag == :only && @valid_locales.any?
  end

  def valid_locale?
    !only? || @valid_locales.include?(locale)
  end

private

  def parse_tag!(tag)
    return unless tag

    case tag
    when TAG_TODO
      @tag = :todo
      @todo_locales = $1.to_s.split(',').freeze
    when TAG_ONLY
      @tag = :only
      @valid_locales = $1.split(',').freeze
    when TAG_IGNORE
      @tag = :ignore
    end
  end
end
