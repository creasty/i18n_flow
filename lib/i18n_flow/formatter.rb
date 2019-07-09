require_relative 'validator/symmetry'
require_relative 'validator/errors'

class I18nFlow::Formatter
  attr_reader :ast_1
  attr_reader :ast_2

  def initialize(ast_1, ast_2 = nil)
    @ast_1 = ast_1
    @ast_2 = ast_2
  end

  def format!
    correct_errors(ast_1, ast_2) if ast_2
    sort_keys(ast_1)
  end

private

  def sort_keys(node)
    return if node.scalar?

    node.sort_keys! if node.mapping?
    node.each do |_, val|
      sort_keys(val)
    end
  end

  def correct_errors(ast_1, ast_2)
    first_key_nodes = [ast_1, ast_2]
      .map { |n| first_key_node_of(n) }

    first_value_nodes = [ast_1, ast_2]
      .zip(first_key_nodes)
      .map { |(ast, key_node)| ast[key_node.value] }

    errors = I18nFlow::Validator::Symmetry.new(first_value_nodes[1], first_value_nodes[0])
      .tap(&:validate!)
      .errors

    errors.each do |error|
      case error
      when I18nFlow::Validator::MissingKeyError
        src_node = error.src_node
        mark_as_todo(src_node)
        error.dest_node[error.dest_key] = src_node.node
      end
    end
  end

  def first_key_node_of(node)
    node
      .send(:indexed_object)
      .node
      .tap { |n| break unless n.is_a?(Psych::Nodes::Mapping) }
      &.tap { |n| break n.children.first }
  end

  def mark_as_todo(ast)
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
end
