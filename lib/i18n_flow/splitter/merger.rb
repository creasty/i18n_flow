module I18nFlow::Splitter
  class Merger
    attr_reader :chunks

    def initialize(chunks)
      @chunks = chunks
    end

    def root
      @root ||= I18nFlow::YamlAstProxy.new_root
    end

    def perform_merge!
      chunks.each do |chunk|
        append_chunk(chunk)
      end
    end

    def to_yaml
      root.parent.to_yaml
    end

  private

    def append_chunk(chunk)
      parent = root

      chunk.scopes[0..(chunk.scalar? ? -2 : -1)]
        .each
        .with_index do |scope, i|
          next_scope = chunk.scopes[i + 1]
          is_seq = next_scope ? next_scope&.is_a?(Integer) : chunk.sequence?

          node = parent[scope]

          if node && (!is_seq && !node.mapping? || is_seq && !node.sequence?)
            # TODO: should raise?
            return
          end

          unless node
            parent[scope] = if is_seq
              Psych::Nodes::Sequence.new
            else
              Psych::Nodes::Mapping.new
            end
            node = parent[scope]
          end

          parent = node
        end

      if chunk.scalar?
        parent[chunk.scopes[-1]] = chunk.node
      else
        parent.merge!(chunk)
      end
    end
  end
end
