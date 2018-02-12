require 'i18n_flow/configuration'

describe I18nFlow::Configuration do
  let(:configuration) { I18nFlow::Configuration.new }

  describe '.new' do
    let(:options) do
      %i[
        base_path
        glob_patterns
        valid_locales
        master_locale
      ]
    end

    it 'should set default values' do
      options.each do |option|
        expect(configuration.respond_to?(option)).to be(true)
        expect(configuration.send(option)).not_to be_nil
      end
    end
  end

  describe '#base_path, #base_path=' do
    it 'should return an instance of Pathname' do
      expect(configuration.base_path).to be_a(Pathname)
    end

    it 'should store an instance of Pathname from a string in the setter' do
      path = 'foo/bar'

      expect {
        configuration.base_path = path
      }.not_to raise_error

      expect(configuration.base_path).to be_a(Pathname)
      expect(configuration.base_path.to_s).to eq(path)
    end
  end

  describe '#glob_patterns, #glob_patterns=' do
    it 'should return an array' do
      expect(configuration.glob_patterns).to be_a(Array)
    end

    it 'should store the given value as an array of strings in the setter' do
      expect {
        configuration.glob_patterns = [:'foo.yml']
      }.not_to raise_error

      expect(configuration.glob_patterns).to eq(['foo.yml'])
    end
  end

  describe '#valid_locales, #valid_locales=' do
    it 'should return an array' do
      expect(configuration.valid_locales).to be_a(Array)
    end

    it 'should store the given value as an array of strings in the setter' do
      expect {
        configuration.valid_locales = [:en]
      }.not_to raise_error

      expect(configuration.valid_locales).to eq(['en'])
    end
  end

  describe '#master_locale, #master_locale=' do
    it 'should store the given value as an array of strings in the setter' do
      expect {
        configuration.master_locale = :en
      }.not_to raise_error

      expect(configuration.master_locale).to eq('en')
    end
  end

  describe '#validate!' do
    context 'base_path' do
      it 'should raise an error if it is a relative path' do
        configuration.base_path = 'relative/path'

        expect {
          configuration.validate!
        }.to raise_error(/base_path/)
      end

      it 'should not raise if it is a absolute path' do
        configuration.base_path = '/absolute/path'

        expect {
          configuration.validate!
        }.not_to raise_error
      end
    end

    context 'glob_patterns' do
      it 'should raise an error if it is not an array' do
        configuration.glob_patterns = ''

        expect {
          configuration.validate!
        }.to raise_error(/glob_patterns/)
      end

      it 'should raise an error if it is empty' do
        configuration.glob_patterns = []

        expect {
          configuration.validate!
        }.to raise_error(/glob_patterns/)
      end

      it 'should not raise if it is an array' do
        configuration.glob_patterns = ['*.yml']

        expect {
          configuration.validate!
        }.not_to raise_error
      end
    end

    context 'master_locale' do
      it 'should raise an error if it is blank' do
        configuration.master_locale = ''

        expect {
          configuration.validate!
        }.to raise_error(/master_locale/)
      end

      it 'should not raise if it is an array' do
        configuration.glob_patterns = ['*.yml']

        expect {
          configuration.validate!
        }.not_to raise_error
      end
    end

    context 'valid_locales' do
      it 'should raise an error if it is not an array' do
        configuration.valid_locales = ''

        expect {
          configuration.validate!
        }.to raise_error(/valid_locales/)
      end

      it 'should raise an error if it is empty' do
        configuration.valid_locales = []

        expect {
          configuration.validate!
        }.to raise_error(/valid_locales/)
      end

      it 'should raise if it does not contain the master locale' do
        configuration.valid_locales = [:ja]

        expect {
          configuration.validate!
        }.to raise_error(/valid_locales/)
      end

      it 'should not raise if eligible' do
        configuration.valid_locales = [:en]

        expect {
          configuration.validate!
        }.not_to raise_error
      end
    end
  end

  context 'auto config' do
    describe '#auto_configure!' do
      it 'should call `load_from_file!` and `update`' do
        allow(configuration).to receive(:load_from_file!).and_return(true)
        allow(configuration).to receive(:update).and_return(true)

        expect(configuration).to receive(:load_from_file!).once.ordered
        expect(configuration).to receive(:update).once.ordered

        configuration.auto_configure!
      end
    end

    describe '#load_from_file!' do
      let(:pwd)            { '/path/to/pwd' }
      let(:yaml_file_path) { '/path/to/i18n_flow.yml' }

      let(:yaml_file) do
        FakeFS::FakeFile.new.tap do |f|
          f.content = <<-YAML
          glob_patterns:
            - 'config/locales/**/*.yml'
          master_locale: 'ja'
          valid_locales:
            - 'ja'
            - 'en'
          YAML
        end
      end

      before do
        FakeFS::FileSystem.add(pwd)
        Dir.chdir(pwd)
      end

      it 'should raise an error if no file is found' do
        expect {
          configuration.send(:load_from_file!)
        }.to raise_error(I18nFlow::Configuration::NoConfigurationFileFoundError)
      end

      it 'should set `base_path` to the directory of yaml file' do
        FakeFS::FileSystem.add(yaml_file_path, yaml_file)

        expect {
          configuration.send(:load_from_file!)
        }.not_to raise_error

        expect(configuration.base_path).to eq(Pathname.new(File.dirname(yaml_file_path)))
      end

      it 'should set other option values from yaml' do
        FakeFS::FileSystem.add(yaml_file_path, yaml_file)

        expect {
          configuration.send(:load_from_file!)
        }.not_to raise_error

        expect(configuration.master_locale).to eq('ja')
        expect(configuration.valid_locales).to eq(['ja', 'en'])
      end

      it 'should raise an error if there is invalid option in yaml' do
        FakeFS::FileSystem.add(yaml_file_path, yaml_file)
        yaml_file.content = <<-YAML
        foo: true
        YAML

        expect {
          configuration.send(:load_from_file!)
        }.to raise_error(KeyError, /foo/)
      end
    end
  end
end
