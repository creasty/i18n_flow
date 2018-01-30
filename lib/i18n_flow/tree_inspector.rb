class I18nFlow::TreeInspector
  def initialize(tree)
    @tree = tree
  end

  def inspect
    [].tap do |lines|
      @tree.values.each do |n|
        lines << inspect_node(n)
      end
    end.join("\n")
  end

private
  def inspect_node(node)
    [].tap do |lines|
      lines << [
        inspect_anchor(node),
        node.full_key,
        inspect_line(node),
        inspect_tag(node),
      ].compact.join(' ')

      node.hash.values.each do |n|
        lines << inspect_node(n).gsub(/^/, "    ")
      end
    end.join("\n")
  end

  def inspect_anchor(node)
    return unless node.has_anchor?
    '&%s' % [node.instance_variable_get(:@anchor)]
  end

  def inspect_line(node)
    if node.end_line
      '%d-%d (%d)' % [node.start_line, node.end_line, node.num_lines]
    else
      '%d' % [node.start_line]
    end
  end

  def inspect_tag(node)
    case node.instance_variable_get(:@tag)
    when :todo
      'TODO'
    when :ignore
      'IGNORED'
    when :only
      'ONLY:%s' % [node.instance_variable_get(:@only)]
    end
  end
end
