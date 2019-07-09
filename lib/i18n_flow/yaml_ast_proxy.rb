require 'psych'
require_relative 'yaml_ast_proxy/node'
require_relative 'yaml_ast_proxy/mapping'
require_relative 'yaml_ast_proxy/sequence'

module I18nFlow::YamlAstProxy
  def self.create(node, parent: nil, scopes: [], file_path: nil)
    case node
    when NilClass
      nil
    when Node
      if node.parent == parent \
        && node.scopes == scopes \
        && node.file_path == file_path
        node
      else
        node.class.new(node.node,
          parent:    parent,
          scopes:    scopes,
          file_path: file_path,
        )
      end
    when Psych::Nodes::Stream, Psych::Nodes::Document
      Node.new(node.children.first,
        parent:    node,
        scopes:    scopes,
        file_path: file_path,
      )
    when Psych::Nodes::Mapping
      Mapping.new(node,
        parent:    parent,
        scopes:    scopes,
        file_path: file_path,
      )
    when Psych::Nodes::Sequence
      Sequence.new(node,
        parent:    parent,
        scopes:    scopes,
        file_path: file_path,
      )
    else
      Node.new(node,
        parent:    parent,
        scopes:    scopes,
        file_path: file_path,
      )
    end
  end

  def self.new_root
    doc = Psych::Nodes::Document.new([], [], true)
    doc.children << Psych::Nodes::Mapping.new
    stream = Psych::Nodes::Stream.new
    stream.children << doc
    create(stream)
  end

  def self.mark_as_todo(ast)
    if ast.alias?
      return
    end
    if ast.scalar?
      ast.node.tag = '!todo'

      # https://github.com/ruby/psych/blob/f30b65befa4f0a5a8548d482424a84a2383b0284/ext/psych/yaml/emitter.c#L1187
      ast.node.plain = ast.node.quoted = false

      return
    end

    ast.each do |k, v|
      mark_as_todo(v)
    end
  end

  def self.first_key_node_of(node)
    first_node_of(node, 0)
  end

  def self.first_value_node_of(node)
    first_node_of(node, 1)
  end

private

  def self.first_node_of(node, layout_offset)
    node
      .send(:indexed_object)
      .node
      .tap { |n| break unless n.is_a?(Psych::Nodes::Mapping) }
      &.tap { |n| break n.children[layout_offset] }
  end
end
