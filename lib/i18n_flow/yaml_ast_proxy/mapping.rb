require 'psych'
require_relative 'node'

module I18nFlow::YamlAstProxy
  class Mapping < Node
    extend Forwardable

    def_delegators :indexed_object, :==, :keys, :size

    def each
      indexed_object.each do |k, _|
        yield k, cache[k]
      end
    end

    def values
      indexed_object.map { |k, _| cache[k] }
    end

    def set(key, value)
      super.tap do
        cache.delete(key)
        synchronize!
      end
    end
    alias []= set

    def delete(key)
      indexed_object.delete(key)
      cache.delete(key)
      synchronize!
    end

    def batch
      @locked = true
      yield
    ensure
      @locked = false
      synchronize!
    end

    def merge!(other)
      return unless other&.is_a?(Mapping)

      batch do
        other.batch do
          other.each do |k, rhs|
            if (lhs = self[k])
              lhs.merge!(rhs)
            else
              self[k] = rhs.node
            end
          end
        end
      end
    end

    def sort_keys!
      @indexed_object = indexed_object
        .sort_by { |k, v| [sort_order(v), k] }
        .to_h
      @cache = nil
      synchronize!
    end

  private

    def cache
      @cache ||= Hash.new { |h, k| h[k] = wrap(indexed_object[k], key: k) }
    end

    def indexed_object
      @indexed_object ||= node.children
        .each_slice(2)
        .map { |k, v| [k.value, v] }
        .to_h
    end

    def synchronize!
      return if @locked

      children = indexed_object.flat_map { |k, v| [Psych::Nodes::Scalar.new(k), v] }
      node.children.replace(children)
    end

    # -2  Default with anchor
    # -1  Aliases
    #  0  Default without anchor
    #  0  Mappings with anchor
    #  1  Mappings without anochor
    def sort_order(node)
      case node
      when Psych::Nodes::Alias then -1
      when Psych::Nodes::Mapping then node.anchor ? 0 : 1
      else node.anchor ? -2 : 0
      end
    end
  end
end
