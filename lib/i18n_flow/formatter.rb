class I18nFlow::Formatter
  attr_reader :ast

  def initialize(ast)
    @ast = ast
  end

  def format!
    sort_keys(ast)
  end

private

  def sort_keys(node)
    node.sort_keys! if node.mapping?
    node.each do |_, val|
      sort_keys(val) if val.mapping?
    end
  end
end
