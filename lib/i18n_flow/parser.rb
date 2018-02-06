require 'psych'
require_relative 'tree'

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

  def tree(file_path: nil)
    I18nFlow::Tree.new(root, file_path: file_path).tree
  end
end
