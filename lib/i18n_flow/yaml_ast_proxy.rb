require 'psych'
require_relative 'yaml_ast_proxy/node'
require_relative 'yaml_ast_proxy/mapping'
require_relative 'yaml_ast_proxy/sequence'

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
end
