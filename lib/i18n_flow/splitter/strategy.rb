module I18nFlow::Splitter
  class Strategy
    DEFAULT_MAX_LEVEL      = 3
    DEFAULT_LINE_THRESHOLD = 50

    def initialize(
      ast,
      max_level:      DEFAULT_MAX_LEVEL,
      line_threshold: DEFAULT_LINE_THRESHOLD
    )
      @ast            = ast
      @max_level      = max_level
      @line_threshold = line_threshold
    end

    def split!
      @chunks = nil
      traverse(@ast, level: 0)
    end

    def chunks
      @chunks ||= Hash.new { |h, k| h[k] = [] }
    end

  private

    def traverse(node, level:)
      return if node.scalar?

      if level > 0 && node.mapping?
        others, mappings = node.values.partition(&:scalar?)

        others.each do |n|
          add_chunk(n, delta_level: -2)
        end

        if mappings.sum(&:num_lines) < @line_threshold
          mappings.each do |n|
            add_chunk(n, delta_level: -2)
          end
          return
        end

        if level >= @max_level
          add_chunk(node)
          return
        end
      end

      if node.sequence?
        add_chunk(node, delta_level: -2)
        return
      end

      node.each do |_, v|
        traverse(v, level: level + 1)
      end
    end

    def add_chunk(node, delta_level: 0)
      level = [node.scopes.size + delta_level, 1].max
      file_scopes = node.scopes[0...level]
      chunks[file_scopes] << node
    end
  end
end
