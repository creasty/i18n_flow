require 'i18n_flow/util'

describe I18nFlow::Util do
  describe '.extract_args' do
    it 'should extract translation arguments' do
      {
        ''                          => %w[],
        'foo'                       => %w[],
        '%{arg_1}'                  => %w[arg_1],
        'foo %{arg_1}'              => %w[arg_1],
        'foo %{arg_1} bar %{arg_2}' => %w[arg_1 arg_2],
        'foo %{arg_2} bar %{arg_1}' => %w[arg_1 arg_2],
        '%{arg_1}%{arg_2}'          => %w[arg_1 arg_2],
        '%{arg_1}%%{arg_2}'         => %w[arg_1],
        '%%{arg_1} bar %%%{arg_2}'  => %w[arg_2],
      }.each do |input, output|
        expect(I18nFlow::Util.extract_args(input)).to eq(output)
      end
    end
  end

  describe '.filepath_to_scope' do
    it 'should parse file path into locale and scopes' do
      {
        'en.yml'                 => %w[en],
        '.en.yml'                => %w[en],
        'foo.en.yml'             => %w[en foo],
        'foo/bar/en.yml'         => %w[en foo bar],
        'foo/bar/baz.en.yml'     => %w[en foo bar baz],
        'foo/bar/baz.bax.en.yml' => %w[en foo bar baz bax],
      }.each do |input, output|
        expect(I18nFlow::Util.filepath_to_scope(input)).to eq(output)
      end
    end
  end

  describe '.scope_to_filepath' do
    it 'should build file path from scopes' do
      {
        [nil, 'en']            => 'en.yml',
        %w[en]                 => 'en.yml',
        %w[en foo]             => 'foo.en.yml',
        %w[en foo bar]         => 'foo/bar.en.yml',
        %w[en foo bar baz]     => 'foo/bar/baz.en.yml',
        %w[en foo bar baz bax] => 'foo/bar/baz/bax.en.yml',
      }.each do |input, output|
        expect(I18nFlow::Util.scope_to_filepath(input)).to eq(output)
      end
    end
  end

  describe '.find_file_upward' do
    let(:file)      { FakeFS::FakeFile.new }
    let(:file_name) { 'file' }

    it 'should return a file path if a file is exist in the current directory' do
      pwd       = '/a/b/c/d'
      file_path = "/a/b/c/d/#{file_name}"

      FakeFS::FileSystem.add(pwd)
      FakeFS::FileSystem.add(file_path, file)

      Dir.chdir(pwd) do
        expect(I18nFlow::Util.find_file_upward(file_name)).to eq(file_path)
      end
    end

    it 'should return a file path if a file is exist at the parent directory' do
      pwd       = '/a/b/c/d'
      file_path = "/a/b/c/#{file_name}"

      FakeFS::FileSystem.add(pwd)
      FakeFS::FileSystem.add(file_path, file)

      Dir.chdir(pwd) do
        expect(I18nFlow::Util.find_file_upward(file_name)).to eq(file_path)
      end
    end

    it 'should return a file path if a file is exist at somewhere of parent directories' do
      pwd       = '/a/b/c/d'
      file_path = "/a/#{file_name}"

      FakeFS::FileSystem.add(pwd)
      FakeFS::FileSystem.add(file_path, file)

      Dir.chdir(pwd) do
        expect(I18nFlow::Util.find_file_upward(file_name)).to eq(file_path)
      end
    end

    it 'should return nil if a file is not exist in any parent directories' do
      pwd       = '/a/b/c/d'
      file_path = "/abc/#{file_name}"

      FakeFS::FileSystem.add(pwd)
      FakeFS::FileSystem.add(file_path, file)

      Dir.chdir(pwd) do
        expect(I18nFlow::Util.find_file_upward(file_name)).to be_nil
      end
    end

    context 'Multiple file names' do
      let(:file_2)      { FakeFS::FakeFile.new }
      let(:file_name_2) { 'file' }

      it 'should return a file path if one of files is exist at somewhere of parent directories' do
        pwd       = '/a/b/c/d'
        file_path = "/a/#{file_name}"

        FakeFS::FileSystem.add(pwd)
        FakeFS::FileSystem.add(file_path, file)

        Dir.chdir(pwd) do
          expect(I18nFlow::Util.find_file_upward(file_name, file_name_2)).to eq(file_path)
        end
      end

      it 'should return the first match if one of files is exist at somewhere of parent directories' do
        pwd         = '/a/b/c/d'
        file_path   = "/a/#{file_name}"
        file_path_2 = "/a/#{file_name_2}"

        FakeFS::FileSystem.add(pwd)
        FakeFS::FileSystem.add(file_path, file)
        FakeFS::FileSystem.add(file_path_2, file)

        Dir.chdir(pwd) do
          expect(I18nFlow::Util.find_file_upward(file_name, file_name_2)).to eq(file_path)
          expect(I18nFlow::Util.find_file_upward(file_name_2, file_name)).to eq(file_path_2)
        end
      end

      it 'should return nil if non of files is not exist in any parent directories' do
        pwd         = '/a/b/c/d'
        file_path   = "/abc/#{file_name}"
        file_path_2 = "/cba/#{file_name_2}"

        FakeFS::FileSystem.add(pwd)
        FakeFS::FileSystem.add(file_path, file)
        FakeFS::FileSystem.add(file_path_2, file)

        Dir.chdir(pwd) do
          expect(I18nFlow::Util.find_file_upward(file_name, file_name_2)).to be_nil
        end
      end
    end
  end

  describe '.parse_options' do
    it 'should parse short options' do
      args = ['-a', '-b']
      options = I18nFlow::Util.parse_options(args)

      expect(args).to be_empty
      expect(options).to be_a(Hash)
      expect(options['a']).to be(true)
      expect(options['b']).to be(true)
    end

    it 'should parse long options' do
      args = ['--long-a', '--long-b']
      options = I18nFlow::Util.parse_options(args)

      expect(args).to be_empty
      expect(options).to be_a(Hash)
      expect(options['long-a']).to be(true)
      expect(options['long-b']).to be(true)
    end

    it 'should parse long options with value' do
      args = ['--long-a=value-of-a', '--long-b=value-of-b']
      options = I18nFlow::Util.parse_options(args)

      expect(args).to be_empty
      expect(options).to be_a(Hash)
      expect(options['long-a']).to eq('value-of-a')
      expect(options['long-b']).to eq('value-of-b')
    end

    it 'should not parse options after once non-option args appears' do
      args = ['-a', '--long-a', 'non-option', '--long-b=value-of-b']
      options = I18nFlow::Util.parse_options(args)

      expect(args).to eq(['non-option', '--long-b=value-of-b'])
      expect(options).to be_a(Hash)
      expect(options['a']).to be(true)
      expect(options['long-a']).to be(true)
      expect(options['long-b']).to be_nil
    end
  end

end
