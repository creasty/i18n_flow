module I18nFlow::Splitter
  class Strategy
    DEFAULT_MAX_LEVEL      = 3
    DEFAULT_LINE_THRESHOLD = 50

    def initialize(
      px,
      max_level:      DEFAULT_MAX_LEVEL,
      line_threshold: DEFAULT_LINE_THRESHOLD
    )
      @px             = px
      @max_level      = max_level
      @line_threshold = line_threshold
    end

    def split
      @chunks = nil
      traverse(@px, level: 0)
      chunks
    end

    def chunks
      @chunks ||= Hash.new { |h, k| h[k] = [] }
    end

  private

    def traverse(px, level:)
      return if px.scalar?

      if level > 0 && px.mapping?
        others, mappings = px.values.partition(&:scalar?)

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
          add_chunk(px)
          return
        end
      end

      if px.sequence?
        add_chunk(px, delta_level: -2)
        return
      end

      px.each do |_, v|
        traverse(v, level: level + 1)
      end
    end

    def add_chunk(px, delta_level: 0)
      level = [px.scopes.size + delta_level, 1].max
      file_scopes = px.scopes[0...level]
      chunks[file_scopes] << px
    end
  end
end
