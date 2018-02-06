require_relative 'node'

class I18nFlow::Tree
  attr_reader :root

  def initialize(root, file_path: nil)
    @root = root
    @file_path = file_path
  end

  def tree
    I18nFlow::Node.new(
      scopes:     [],
      file_path:  @file_path,
      start_line: 1,
    ).tap do |node|
      visit(root, scopes: [], content: node.content)
    end
  end

private

  def visit(o, scopes:, content:)
    case o
    when ::Psych::Nodes::Stream, ::Psych::Nodes::Document
      o.children.each do |c|
        visit(c, scopes: scopes, content: content)
      end
    when ::Psych::Nodes::Scalar
      node = I18nFlow::Node.new(
        scopes:     scopes,
        file_path:  @file_path,
        value:      o.value,
        start_line: o.start_line,
        end_line:   o.end_line,
        anchor:     o.anchor,
        tag:        o.tag,
      )
      content[node.key] = node
    when ::Psych::Nodes::Sequence
      if scopes.any?
        node = I18nFlow::Node.new(
          scopes:     scopes,
          file_path:  @file_path,
          start_line: o.start_line,
          end_line:   o.end_line,
          anchor:     o.anchor,
          tag:        o.tag,
        )
        content[node.key] = node
        content = node.content
      end

      o.children.each_with_index do |c, i|
        visit(c, scopes: [*scopes, '$%d' % [i]], content: content)
      end
    when ::Psych::Nodes::Alias, ::Psych::Nodes::Mapping
      if scopes.any?
        node = I18nFlow::Node.new(
          scopes:     scopes,
          file_path:  @file_path,
          start_line: o.start_line,
          end_line:   o.end_line,
          anchor:     o.anchor,
          tag:        o.tag,
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
