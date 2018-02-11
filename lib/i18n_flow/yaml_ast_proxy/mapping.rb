require 'psych'
require_relative 'node'

module I18nFlow::YamlAstProxy
  class Mapping < Node
    extend Forwardable

    def_delegators :indexed_object, :==

    def each
      indexed_object.each do |k, _|
        yield k, cache[k]
      end
    end

    def keys
      indexed_object.keys
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

    def batch
      @locked = true
      yield
    ensure
      @locked = false
      synchronize!
    end

    def merge(other)
      batch do
        indexed_object.merge(other.indexed_object)
      end
    end

  private

    def cache
      @cache ||= Hash.new { |h, k| h[k] = wrap(indexed_object[k], key: k) }
    end

    def indexed_object
      @indexed_object ||= @node.children
        .each_slice(2)
        .map { |k, v| [k.value, v] }
        .to_h
    end

    def synchronize!
      return if @locked

      children = indexed_object.flat_map { |k, v| [Psych::Nodes::Scalar.new(k), v] }
      @node.children.replace(children)
    end
  end
end
