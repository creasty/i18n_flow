require 'psych'

class I18nFlow::Node
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

  def inspect
    [].tap do |lines|
      lines << [
        inspect_anchor,
        scope.join('.'),
        inspect_line,
        inspect_tag,
      ].compact.join(' ')

      children.each do |c|
        lines << c.inspect.gsub(/^/, "    ")
      end
    end.join("\n")
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

  def inspect_anchor
    return unless has_anchor?
    '&%s' % [@anchor]
  end

  def inspect_line
    if end_line
      '%d-%d (%d)' % [start_line, end_line, num_lines]
    else
      '%d' % [start_line]
    end
  end

  def inspect_tag
    case @tag
    when :todo
      'TODO'
    when :ignore
      'IGNORED'
    when :only
      'ONLY[%s]' % [@only]
    end
  end
end
