require 'i18n_flow/single_validator'
require 'i18n_flow/validation_error'

describe I18nFlow::SingleValidator do
  let(:validator) { I18nFlow::SingleValidator.new }

  describe '#validate' do
    it 'should pass if the filepath and the scope are perfectly matched' do
      filepath = 'foo/bar.en.yml'

      tree = parse_yaml(<<-YAML)
      en:
        foo:
          bar:
            key_1: text_1
      YAML

      validator.validate(tree, filepath: filepath)

      expect(validator.errors).to eq([])
    end

    it 'should fail if the scope is missing' do
      filepath = 'foo/bar.en.yml'

      tree = parse_yaml(<<-YAML)
      en:
        foo:
          key_1: text_1
      YAML

      validator.validate(tree, filepath: filepath)

      expect(validator.errors).to eq([
        I18nFlow::MissingKeyError.new('en.foo.bar'),
      ])
    end

    it 'should fail if its structure is invalid' do
      filepath = 'foo/bar.en.yml'

      tree = parse_yaml(<<-YAML)
      en:
        foo:
          bar: text_1
      YAML

      validator.validate(tree, filepath: filepath)

      expect(validator.errors).to eq([
        I18nFlow::InvalidTypeError.new('en.foo.bar'),
      ])
    end

    it 'should fail if it contains extra keys' do
      filepath = 'foo/bar.en.yml'

      tree = parse_yaml(<<-YAML)
      en:
        foo:
          bar:
            key_1: text_1
          baz:
            key_2: text_2
          bax:
            key_2: text_2
      YAML

      validator.validate(tree, filepath: filepath)

      expect(validator.errors).to eq([
        I18nFlow::ExtraKeyError.new('en.foo.baz'),
        I18nFlow::ExtraKeyError.new('en.foo.bax'),
      ])
    end
  end
end
