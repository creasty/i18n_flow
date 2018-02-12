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
end
