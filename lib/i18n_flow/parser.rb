require 'psych'
require_relative 'tree'
require_relative 'yaml_ast_proxy'

class I18nFlow::Parser
  def initialize
    @builder = Psych::TreeBuilder.new
    @parser = Psych::Parser.new(@builder)
  end

  def parse(buffer)
    @parser.parse(buffer)
  end

  def root
    @builder.root
  end

  def tree(file_path: nil) # DEPRECATED
    I18nFlow::Tree.new(root, file_path: file_path).tree
  end

  def root_proxy
    I18nFlow::YamlAstProxy.create(root)
  end
end
