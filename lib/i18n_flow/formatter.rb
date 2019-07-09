class I18nFlow::Formatter
  attr_reader :ast_1
  attr_reader :ast_2

  def initialize(ast_1, ast_2 = nil)
    @ast_1 = ast_1
    @ast_2 = ast_2
  end

  def format!
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
end
