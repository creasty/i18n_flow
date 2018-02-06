class I18nFlow::SplitStrategy
  DEFAULT_MAX_LEVEL      = 3
  DEFAULT_LINE_THRESHOLD = 50

  def initialize(
    tree,
    max_level:      DEFAULT_MAX_LEVEL,
    line_threshold: DEFAULT_LINE_THRESHOLD
  )
    @tree           = tree
    @max_level      = max_level
    @line_threshold = line_threshold
  end

  def split
    @chunks = nil
    traverse(@tree, level: 0)
    chunks
  end

  def chunks
    @chunks ||= Hash.new { |h, k| h[k] = [] }
  end

private

  def traverse(node, level:)
    content_nodes = node.content.values

    if level > 0
      value_nodes, content_nodes = content_nodes.partition(&:value?)
      value_nodes.each do |n|
        add_chunk(n, delta_level: -2)
      end

      if content_nodes.sum(&:num_lines) < @line_threshold
        content_nodes.each do |n|
          add_chunk(n, delta_level: -2)
        end
        return
      end

      if level >= @max_level
        add_chunk(node)
        return
      end
    end

    content_nodes.each do |n|
      traverse(n, level: level + 1)
    end
  end

  def add_chunk(node, delta_level: 0)
    level = [node.scopes.size + delta_level, 1].max
    file_scopes = node.scopes[0...level]
    chunks[file_scopes] << [node.start_line, node.end_line]
  end
end
