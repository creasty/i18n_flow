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

      scopes = chunk.scopes
      scopes = scopes[0...-1] if chunk.scalar?

      scopes.each do |scope|
        node = parent[scope]
        if node && !node.mapping?
          # TODO: should raise?
          return
        end

        unless node
          parent[scope] = Psych::Nodes::Mapping.new
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
