require 'psych'
require_relative 'node'

class I18nFlow::Tree
  attr_reader :root

  def initialize(root, file_path: nil)
    @root = root
    @file_path = file_path
  end

  def tree
    I18nFlow::Node.new(@root,
      scopes:     [],
      file_path:  @file_path,
    ).tap do |node|
      visit(root, scopes: node.scopes, content: node.content)
    end
  end

private

  def visit(o, scopes:, content:)
    case o
    when Psych::Nodes::Stream, Psych::Nodes::Document
      o.children.each do |c|
        visit(c, scopes: scopes, content: content)
      end
    when Psych::Nodes::Scalar
      node = I18nFlow::Node.new(o,
        scopes:    scopes,
        file_path: @file_path,
      )
      content[node.key] = node
    when Psych::Nodes::Sequence
      if scopes.any?
        node = I18nFlow::Node.new(o,
          scopes:    scopes,
          file_path: @file_path,
        )
        content[node.key] = node
        content = node.content
      end

      o.children.each_with_index do |c, i|
        visit(c, scopes: [*scopes, '$%d' % [i]], content: content)
      end
    when Psych::Nodes::Alias
      # Ignore
    when Psych::Nodes::Mapping
      if scopes.any?
        node = I18nFlow::Node.new(o,
          scopes:    scopes,
          file_path: @file_path,
        )
        content[node.key] = node
        content = node.content
      end

      o.children.each_slice(2) do |k, v|
        next if should_ignore?(k)
        visit(v, scopes: [*scopes, k.value], content: content)
      end
    end
  end

  def should_ignore?(k)
    k.value == '<<' && k.tag != 'tag:yaml.org,2002:str'
  end
end
