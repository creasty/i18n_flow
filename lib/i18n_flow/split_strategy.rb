require 'psych'
require_relative 'util'

class I18nFlow::SplitStrategy
  DEFAULT_MAX_LEVEL      = 3
  DEFAULT_LINE_THRESHOLD = 50

  def initialize(
    tree,
    max_level:      DEFAULT_MAX_LEVEL,
    line_threshold: DEFAULT_LINE_THRESHOLD
  )
    @tree           = tree
    @max_level      = max_level
    @line_threshold = line_threshold
  end

  def split
    @chunks = nil
    traverse(@tree, level: 0)
    chunks
  end

  def splitted_trees
    split.map do |file_scopes, file_chunks|
      file_path = I18nFlow::Util.scope_to_filepath(file_scopes)
      [file_path, build_yaml(file_chunks)]
    end.to_h
  end

  def chunks
    @chunks ||= Hash.new { |h, k| h[k] = [] }
  end

private

  def build_yaml(file_chunks)
    Psych::Nodes::Stream.new.tap do |stream|
      stream.children << Psych::Nodes::Document.new do |doc|
        doc.children << Psych::Nodes::Mapping.new do |mapping|
          file_chunks.each do |node|
            mapping.children << Psych::Nodes::Scalar.new(node.value)
            mapping.children << node.psych_node
          end
        end
      end
    end
  end

  def traverse(node, level:)
    content_nodes = node.content.values

    if level > 0
      content_nodes, value_nodes = content_nodes.partition(&:mapping?)
      value_nodes.each do |n|
        add_chunk(n, delta_level: -2)
      end

      if content_nodes.sum(&:num_lines) < @line_threshold
        content_nodes.each do |n|
          add_chunk(n, delta_level: -2)
        end
        return
      end

      if level >= @max_level
        add_chunk(node)
        return
      end
    end

    content_nodes.each do |n|
      traverse(n, level: level + 1)
    end
  end

  def add_chunk(node, delta_level: 0)
    level = [node.scopes.size + delta_level, 1].max
    file_scopes = node.scopes[0...level]
    chunks[file_scopes] << node
  end
end
