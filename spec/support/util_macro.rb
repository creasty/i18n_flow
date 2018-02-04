module UtilMacro
  def parse_yaml(yaml)
    parser = I18nFlow::Parser.new
    parser.parse(yaml)
    parser.tree
  end
end
