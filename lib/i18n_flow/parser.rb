require 'psych'
require_relative 'yaml_ast_proxy'

class I18nFlow::Parser
  attr_reader :buffer
  attr_reader :file_path

  def initialize(buffer, file_path: nil)
    @buffer = buffer
    @file_path = file_path
  end

  def parse!
    parser.parse(buffer)
  end

  def root
    builder.root
  end

  def root_proxy
    @root_proxy ||= I18nFlow::YamlAstProxy.create(root, file_path: file_path)
  end

private

  def builder
    @builder ||= Psych::TreeBuilder.new
  end

  def parser
    @parser ||= Psych::Parser.new(builder)
  end
end
