require_relative 'node'

module I18nFlow::YamlAstProxy
  class Sequence < Node
    def_delegators :indexed_object, :==, :<<

    def each
      indexed_object.each.with_index do |o, i|
        yield i, wrap(o, key: i)
      end
    end

  private

    def indexed_object
      @node.children
    end
  end
end
