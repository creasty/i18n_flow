require 'psych'

class I18nFlow::Node
  TAG_IGNORE = '!ignore'
  TAG_TODO   = /^!todo(?::([,a-zA-Z_-]+))?$/
  TAG_ONLY   = /^!only:([,a-zA-Z_-]+)$/

  attr_reader :psych_node
  attr_reader :scopes
  attr_reader :file_path
  attr_reader :todo_locales
  attr_reader :valid_locales

  def initialize(psych_node, scopes:, file_path:)
    @psych_node = psych_node
    @scopes     = scopes.freeze
    @file_path  = file_path

    case psych_node
    when Psych::Nodes::Scalar
      @start_line = psych_node.start_line + 1
      @end_line   = psych_node.end_line + 1
    else
      @start_line = psych_node.start_line
      @end_line   = psych_node.end_line
    end

    @todo_locales  = []
    @valid_locales = []

    parse_tag!(psych_node.tag)
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

  def start_line
    @psych_node.start_line
  end

  def end_line
    @psych_node.end_line
  end

  def value
    return unless value?
    @psych_node.value
  end

  def mapping?
    @psych_node.is_a?(Psych::Nodes::Mapping)
  end

  def value?
    @psych_node.is_a?(Psych::Nodes::Scalar)
  end

  def sequence?
    @psych_node.is_a?(Psych::Nodes::Sequence)
  end

  def anchor
    @psych_node.anchor
  end

  def has_anchor?
    !!anchor
  end

  def marked_as_todo?
    @tag == :todo
  end

  def marked_as_ignored?
    @tag == :ignore
  end

  def marked_as_only?
    @tag == :only && @valid_locales.any?
  end

  def valid_locale?
    !marked_as_only? || @valid_locales.include?(locale)
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
