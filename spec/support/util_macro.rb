module UtilMacro
  def parse_yaml(yaml)
    parser = I18nFlow::Parser.new
    parser.parse(yaml)
    parser.tree
  end

  def create_file(path, content)
    FakeFS::FakeFile.new.tap do |file|
      file.content = content
      FakeFS::FileSystem.add(path, file)
    end
  end
end
