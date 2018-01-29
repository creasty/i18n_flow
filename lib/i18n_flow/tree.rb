require_relative 'node'

class I18nFlow::Tree
  attr_reader :root

  def initialize(root, include_scalar: false)
    @root = root
    @include_scalar = include_scalar
  end

  def include_scalar?
    !!@include_scalar
  end

  def tree
    [].tap do |children|
      visit(root, scope: [], children: children)
    end
  end

private

  def visit(o, scope:, children:)
    case o
    when ::Psych::Nodes::Stream, ::Psych::Nodes::Document
      o.children.each do |c|
        visit(c, scope: scope, children: children)
      end
    when ::Psych::Nodes::Scalar
      if include_scalar?
        children << I18nFlow::Node.new(o, scope: scope)
      end
    when ::Psych::Nodes::Alias
    when ::Psych::Nodes::Sequence
      if include_scalar?
        if scope.any?
          node = I18nFlow::Node.new(o, scope: scope)
          children << node
          children = node.children
        end

        o.children.each_with_index do |c, i|
          visit(c, scope: [*scope, '$%d' % [i]], children: children)
        end
      else
        children << I18nFlow::Node.new(o, scope: scope)
      end
    when ::Psych::Nodes::Mapping
      if scope.any?
        node = I18nFlow::Node.new(o, scope: scope)
        children << node
        children = node.children
      end

      o.children.each_slice(2) do |k, v|
        next if should_ignore?(k)
        visit(v, scope: [*scope, k.value], children: children)
      end
    end
  end

  def should_ignore?(k)
    k.value == '<<' && k.tag != 'tag:yaml.org,2002:str'
  end
end
