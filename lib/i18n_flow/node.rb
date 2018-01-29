require 'psych'

class I18nFlow::Node
  attr_accessor :start_line
  attr_accessor :end_line
  attr_accessor :scope

  def initialize(o, scope:)
    @start_line = o.start_line + 1
    @end_line = o.end_line || @start_line
    @anchor = o.anchor
    @scope = scope
  end

  def has_anchor?
    !!@anchor
  end

  def num_lines
    end_line - start_line + 1
  end

  def level
    scope.size
  end

  def children
    @children ||= []
  end

  def inspect
    [].tap do |lines|
      lines << [
        @anchor ? "&#{@anchor}" : nil,
        scope.join('.'),
        '%d-%d' % [@start_line, @end_line],
        '[%d, %d]' % [level, num_lines],
      ].compact.join(' ')

      children.each do |c|
        lines << c.inspect.gsub(/^/, "    ")
      end
    end.join("\n")
  end
end
