module UtilMacro
  def parse_yaml(yaml)
    parser = I18nFlow::Parser.new(yaml)
    parser.parse!
    parser.root_proxy
  end

  def create_file(path, content)
    FakeFS::FakeFile.new.tap do |file|
      file.content = content
      FakeFS::FileSystem.add(path, file)
    end
  end
end
