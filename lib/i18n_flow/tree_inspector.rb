class I18nFlow::TreeInspector
  def initialize(tree)
    @tree = tree
  end

  def inspect
    [].tap do |lines|
      @tree.content.values.each do |n|
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

      node.content.values.each do |n|
        lines << inspect_node(n).gsub(/^/, "    ")
      end
    end.join("\n")
  end

  def inspect_anchor(node)
    return unless node.has_anchor?
    '&%s' % [node.anchor]
  end

  def inspect_line(node)
    if node.end_line && node.start_line
      '%d-%d (%d)' % [node.start_line, node.end_line, node.num_lines]
    elsif node.start_line
      '%d' % [node.start_line]
    end
  end

  def inspect_tag(node)
    return 'TOOD:%s' % [node.todo_locales.join(',')] if node.todo?
    return 'IGNORED' if node.ignored?
    return 'ONLY:%s' % [node.valid_locales.join(',')] if node.has_only?
  end
end
