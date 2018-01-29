module I18nFlow::NodeInspector
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
