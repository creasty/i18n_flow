require_relative 'node'

class I18nFlow::Tree
  attr_reader :root

  def initialize(root, file_path: nil)
    @root = root
    @file_path = file_path
  end

  def tree
    I18nFlow::Node.new(
      scope:      [],
      file_path:  @file_path,
      start_line: 0,
    ).tap do |node|
      visit(root, scope: [], hash: node.hash)
    end
  end

private

  def visit(o, scope:, hash:)
    case o
    when ::Psych::Nodes::Stream, ::Psych::Nodes::Document
      o.children.each do |c|
        visit(c, scope: scope, hash: hash)
      end
    when ::Psych::Nodes::Scalar
      node = I18nFlow::Node.new(
        scope:      scope,
        file_path:  @file_path,
        value:      o.value,
        start_line: o.start_line + 1,
        end_line:   o.end_line,
        anchor:     o.anchor,
        tag:        o.tag,
      )
      hash[node.key] = node
    when ::Psych::Nodes::Sequence
      if scope.any?
        node = I18nFlow::Node.new(
          scope:      scope,
          file_path:  @file_path,
          start_line: o.start_line + 1,
          end_line:   o.end_line,
          anchor:     o.anchor,
          tag:        o.tag,
        )
        hash[node.key] = node
        hash = node.hash
      end

      o.children.each_with_index do |c, i|
        visit(c, scope: [*scope, '$%d' % [i]], hash: hash)
      end
    when ::Psych::Nodes::Alias, ::Psych::Nodes::Mapping
      if scope.any?
        node = I18nFlow::Node.new(
          scope:      scope,
          file_path:  @file_path,
          start_line: o.start_line + 1,
          end_line:   o.end_line,
          anchor:     o.anchor,
          tag:        o.tag,
        )
        hash[node.key] = node
        hash = node.hash
      end

      o.children.each_slice(2) do |k, v|
        next if should_ignore?(k)
        visit(v, scope: [*scope, k.value], hash: hash)
      end
    end
  end

  def should_ignore?(k)
    k.value == '<<' && k.tag != 'tag:yaml.org,2002:str'
  end
end
