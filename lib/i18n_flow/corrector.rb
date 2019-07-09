require_relative 'validator/symmetry'
require_relative 'validator/errors'
require_relative 'yaml_ast_proxy'

class I18nFlow::Corrector
  attr_reader :ast_1
  attr_reader :ast_2

  def initialize(ast_1, ast_2)
    @ast_1 = ast_1
    @ast_2 = ast_2
  end

  def correct!
    n1, n2 = [ast_1, ast_2]
      .map { |n| I18nFlow::YamlAstProxy.first_value_node_of(n) }
      .map { |n| I18nFlow::YamlAstProxy.create(n) }

    errors = I18nFlow::Validator::Symmetry.new(n2, n1)
      .tap(&:validate!)
      .errors

    errors.each do |error|
      case error
      when I18nFlow::Validator::MissingKeyError
        src_node = error.src_node
        I18nFlow::YamlAstProxy.mark_as_todo(src_node)
        error.dest_node[error.dest_key] = src_node.node
      when I18nFlow::Validator::ExtraKeyError
        if error.dest_node.mapping?
          error.dest_node.delete(error.dest_key)
        elsif error.dest_node.sequence?
          error.dest_node.delete_at(error.dest_key)
        end
      end
    end
  end
end
