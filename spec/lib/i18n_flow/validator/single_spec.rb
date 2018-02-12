require 'i18n_flow/validator/single'
require 'i18n_flow/validator/errors'

describe I18nFlow::Validator::Single do
  let(:filepath) { 'foo/bar.en.yml' }
  let(:validator) { I18nFlow::Validator::Single.new(nil, filepath: filepath) }

  describe '#validate' do
    it 'should pass if the filepath and the scope are perfectly matched' do
      ast = parse_yaml_2(<<-YAML)
      en:
        foo:
          bar:
            key_1: text_1
      YAML

      allow(validator).to receive(:ast).and_return(ast)
      validator.validate!

      expect(validator.errors).to eq([])
    end

    it 'should fail if the scope is missing' do
      ast = parse_yaml_2(<<-YAML)
      en:
        foo:
          key_1: text_1
      YAML

      allow(validator).to receive(:ast).and_return(ast)
      validator.validate!

      expect(validator.errors).to eq([
        I18nFlow::Validator::MissingKeyError.new('en.foo.bar'),
      ])
    end

    it 'should fail if its structure is invalid' do
      ast = parse_yaml_2(<<-YAML)
      en:
        foo:
          bar: text_1
      YAML

      allow(validator).to receive(:ast).and_return(ast)
      validator.validate!

      expect(validator.errors).to eq([
        I18nFlow::Validator::InvalidTypeError.new('en.foo.bar'),
      ])
    end

    it 'should fail if it contains extra keys' do
      ast = parse_yaml_2(<<-YAML)
      en:
        foo:
          bar:
            key_1: text_1
          baz:
            key_2: text_2
          bax:
            key_2: text_2
      YAML

      allow(validator).to receive(:ast).and_return(ast)
      validator.validate!

      expect(validator.errors).to eq([
        I18nFlow::Validator::ExtraKeyError.new('en.foo.baz'),
        I18nFlow::Validator::ExtraKeyError.new('en.foo.bax'),
      ])
    end
  end
end
