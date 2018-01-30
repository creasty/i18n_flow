require 'psych'
require_relative 'tree_builder'
require_relative 'tree'

class I18nFlow::Parser
  def initialize
    @builder = I18nFlow::TreeBuilder.new
    @parser = Psych::Parser.new(@builder)
    @builder.parser = @parser
  end

  def parse(buffer)
    @parser.parse(buffer)
  end

  def root
    @builder.root
  end

  def tree
    I18nFlow::Tree.new(root).tree
  end
end
