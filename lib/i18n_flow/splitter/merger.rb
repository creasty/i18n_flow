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
        merge(chunk)
      end
    end

    def to_yaml
      root.parent.to_yaml
    end

  private

    def merge(chunk)

    end
  end
end
