require 'psych'
require_relative 'node_inspector'

class I18nFlow::Node
  include I18nFlow::NodeInspector

  TAG_TODO   = '!todo'
  TAG_IGNORE = '!ignore'
  TAG_ONLY   = /^!only:([\w-]+)$/

  attr_accessor :start_line
  attr_accessor :end_line
  attr_reader :scope
  attr_reader :only

  def initialize(o, scope:)
    @start_line = o.start_line + 1
    @end_line = o.end_line
    @anchor = o.anchor
    @scope = scope

    parse_tag!(o.tag)
  end

  def has_anchor?
    !!@anchor
  end

  def num_lines
    return 1 unless end_line
    end_line - start_line + 1
  end

  def level
    scope.size
  end

  def children
    @children ||= []
  end

  def todo?
    @tag == :todo
  end

  def ignored?
    @tag == :ignore
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
