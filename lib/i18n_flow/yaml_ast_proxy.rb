require 'psych'

module I18nFlow::YamlAstProxy
  def self.create(node, parent: nil, scopes: [])
    case node
    when I18nFlow::YamlAstProxy::Node
      node
    when Psych::Nodes::Stream, Psych::Nodes::Document
      Node.new(node.children.first, parent: node, scopes: scopes)
    when Psych::Nodes::Mapping
      Mapping.new(node, parent: parent, scopes: scopes)
    when Psych::Nodes::Sequence
      Sequence.new(node, parent: parent, scopes: scopes)
    else
      Node.new(node, parent: parent, scopes: scopes)
    end
  end

  def self.new_root
    doc = Psych::Nodes::Document.new
    doc.children << Psych::Nodes::Mapping.new
    stream = Psych::Nodes::Stream.new
    stream.children << doc
    create(stream)
  end

  class Node
    extend Forwardable

    attr_reader :node
    attr_reader :parent
    attr_reader :scopes

    def_delegators :indexed_object, :each

    def initialize(node, parent: nil, scopes: [])
      @node   = node
      @parent = parent
      @scopes = scopes
    end

    def get(key)
      wrap(indexed_object[key], key: key)
    end
    alias [] get

    def set(key, value)
      indexed_object[key] = value
    end
    alias []= set

    def enumerable?
      case @node
      when Psych::Nodes::Stream,
        Psych::Nodes::Document,
        Psych::Nodes::Mapping,
        Psych::Nodes::Sequence
        true
      else
        false
      end
    end

    def sequence?
      @node.is_a?(Psych::Nodes::Sequence)
    end

    def mapping?
      @node.is_a?(Psych::Nodes::Sequence)
    end

    def scalar?
      @node.is_a?(Psych::Nodes::Scalar)
    end

    def value
      @node.value if @node.respond_to?(:value)
    end

  private

    def indexed_object
      @indexed_object ||= I18nFlow::YamlAstProxy.create(@node, parent: @parent, scopes: scopes)
    end

    def wrap(value, key:)
      I18nFlow::YamlAstProxy.create(value, parent: @node, scopes: [*@scopes, key])
    end
  end

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

  private

    def cache
      @cache ||= Hash.new { |h, k| h[k] = wrap(indexed_object[k], key: k) }
    end

    def indexed_object
      @indexed_object ||= @node.children
        .each_slice(2)
        .reject { |k, _| should_ignore?(k) }
        .map { |k, v| [k.value, v] }
        .to_h
    end

    def synchronize!
      return if @locked

      children = indexed_object.flat_map { |k, v| [Psych::Nodes::Scalar.new(k), v] }
      @node.children.replace(children)
    end

    def should_ignore?(k)
      k.value == '<<' && k.tag != 'tag:yaml.org,2002:str'
    end
  end

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
