require 'i18n_flow/symmetry_validator'
require 'i18n_flow/validation_error'

describe I18nFlow::SymmetryValidator do
  let(:validator) { I18nFlow::SymmetryValidator.new }

  describe '#validate' do
    it 'should pass if the given trees are completely the same' do
      t1 = parse_yaml(<<-YAML).content['en']
      en:
        key_1: text_1
        foo:
          key_2: text_2
      YAML
      t2 = parse_yaml(<<-YAML).content['ja']
      ja:
        key_1: text_1
        foo:
          key_2: text_2
      YAML

      validator.validate(t1, t2)

      expect(validator.errors).to eq([])
    end

    context 'asymmetric key' do
      it 'should detect' do
        t1 = parse_yaml(<<-YAML).content['en']
        en:
          key_1: text_1
          key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML).content['ja']
        ja:
          key_1: text_1
          key_3: text_3
        YAML

        validator.validate(t1, t2)

        expect(validator.errors).to eq([
          I18nFlow::MissingKeyError.new('ja.key_2'),
          I18nFlow::ExtraKeyError.new('ja.key_3'),
        ])
      end

      it 'should detect on nested node' do
        t1 = parse_yaml(<<-YAML).content['en']
        en:
          key_1: text_1
          foo:
            key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML).content['ja']
        ja:
          key_1: text_1
          foo:
            key_3: text_3
        YAML

        validator.validate(t1, t2)

        expect(validator.errors).to eq([
          I18nFlow::MissingKeyError.new('ja.foo.key_2'),
          I18nFlow::ExtraKeyError.new('ja.foo.key_3'),
        ])
      end

      it 'should suppress an error on the ignored node (value)' do
        t1 = parse_yaml(<<-YAML).content['en']
        en:
          key_1: text_1
          key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML).content['ja']
        ja:
          key_1: text_1
          key_3: !ignore text_3
        YAML

        validator.validate(t1, t2)

        expect(validator.errors).to eq([
          I18nFlow::MissingKeyError.new('ja.key_2'),
        ])
      end

      it 'should suppress an error on the ignored node (map)' do
        t1 = parse_yaml(<<-YAML).content['en']
        en:
          key_1: text_1
          foo:
            key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML).content['ja']
        ja:
          key_1: text_1
          foo: !ignore
            key_3: text_3
        YAML

        validator.validate(t1, t2)

        expect(validator.errors).to eq([])
      end
    end

    context 'type mismatch' do
      it 'should detect' do
        t1 = parse_yaml(<<-YAML).content['en']
        en:
          key_1: text_1
          key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML).content['ja']
        ja:
          key_1: text_1
          key_2:
            one: text_2
        YAML

        validator.validate(t1, t2)

        expect(validator.errors).to eq([
          I18nFlow::InvalidTypeError.new('ja.key_2'),
        ])
      end

      it 'should detect on nested node' do
        t1 = parse_yaml(<<-YAML).content['en']
        en:
          key_1: text_1
          foo:
            key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML).content['ja']
        ja:
          key_1: text_1
          foo:
            key_2:
              one: text_2
        YAML

        validator.validate(t1, t2)

        expect(validator.errors).to eq([
          I18nFlow::InvalidTypeError.new('ja.foo.key_2'),
        ])
      end

      it 'suppress an error on the ignored node' do
        t1 = parse_yaml(<<-YAML).content['en']
        en:
          key_1: text_1
          key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML).content['ja']
        ja:
          key_1: text_1
          key_2: !ignore
            one: text_2
        YAML

        validator.validate(t1, t2)

        expect(validator.errors).to eq([])
      end

      it 'suppress an error on the ignored node (outer map)' do
        t1 = parse_yaml(<<-YAML).content['en']
        en:
          key_1: text_1
          foo:
            key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML).content['ja']
        ja:
          key_1: text_1
          foo: !ignore
            key_2:
              one: text_2
        YAML

        validator.validate(t1, t2)

        expect(validator.errors).to eq([])
      end
    end

    context '!only tag' do
      it 'should pass if the asymmetric node is tagged with its locale (value)' do
        t1 = parse_yaml(<<-YAML).content['en']
        en:
          key_1: text_1
          key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML).content['ja']
        ja:
          key_1: text_1
          key_2: text_2
          key_3: !only:ja text_3
        YAML

        validator.validate(t1, t2)

        expect(validator.errors).to eq([])
      end

      it 'should pass if the asymmetric node is tagged with its locale (map)' do
        t1 = parse_yaml(<<-YAML).content['en']
        en:
          key_1: text_1
          key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML).content['ja']
        ja:
          key_1: text_1
          key_2: text_2
          key_3: !only:ja
            one: text_3
        YAML

        validator.validate(t1, t2)

        expect(validator.errors).to eq([])
      end

      it 'should pass if the symmetric node is tagged with both locales' do
        t1 = parse_yaml(<<-YAML).content['en']
        en:
          key_1: text_1
          key_2: !only:en,ja text_2
        YAML
        t2 = parse_yaml(<<-YAML).content['ja']
        ja:
          key_1: text_1
          key_2: !only:en,ja text_2
        YAML

        validator.validate(t1, t2)

        expect(validator.errors).to eq([])
      end

      it 'should fail if the symmetric node is tagged with an one-side locale' do
        t1 = parse_yaml(<<-YAML).content['en']
        en:
          key_1: text_1
          key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML).content['ja']
        ja:
          key_1: text_1
          key_2: !only:ja text_2
        YAML

        validator.validate(t1, t2)

        expect(validator.errors).to eq([
          I18nFlow::InvalidLocaleError.new('en.key_2', expect: ['ja'], actual: 'en'),
        ])
      end

      it 'should fail if the asymmetric node is tagged with a different locale' do
        t1 = parse_yaml(<<-YAML).content['en']
        en:
          key_1: text_1
          key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML).content['ja']
        ja:
          key_1: text_1
          key_2: text_2
          key_3: !only:en
            one: text_3
        YAML

        validator.validate(t1, t2)

        expect(validator.errors).to eq([
          I18nFlow::InvalidLocaleError.new('ja.key_3', expect: ['en'], actual: 'ja'),
        ])
      end

      it 'should fail if the symmetric node is tagged with a different locale' do
        t1 = parse_yaml(<<-YAML).content['en']
        en:
          key_1: text_1
          key_2: !only:en text_2
        YAML
        t2 = parse_yaml(<<-YAML).content['ja']
        ja:
          key_1: text_1
          key_2: text_2
        YAML

        validator.validate(t1, t2)

        expect(validator.errors).to eq([
          I18nFlow::InvalidLocaleError.new('ja.key_2', expect: ['en'], actual: 'ja'),
        ])
      end
    end

    context '!todo tag' do
      it 'should pass if the value is marked as todo' do
        t1 = parse_yaml(<<-YAML).content['en']
        en:
          key_1: text_1
          key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML).content['ja']
        ja:
          key_1: text_1
          key_2: !todo text_2
        YAML

        validator.validate(t1, t2)

        expect(validator.errors).to eq([])
      end

      it 'should fail if the tag is on a non-value node' do
        t1 = parse_yaml(<<-YAML).content['en']
        en:
          key_1: text_1
          foo: !todo
            key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML).content['ja']
        ja:
          key_1: text_1
          foo: !todo
            key_2: text_2
        YAML

        validator.validate(t1, t2)

        expect(validator.errors).to eq([
          # en.foo is ignored,
          I18nFlow::InvalidTodoError.new('ja.foo'),
        ])
      end

      it 'should fail if texts are different' do
        t1 = parse_yaml(<<-YAML).content['en']
        en:
          key_1: text_1
          key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML).content['ja']
        ja:
          key_1: text_1
          key_2: !todo text_9
        YAML

        validator.validate(t1, t2)

        expect(validator.errors).to eq([
          I18nFlow::TodoContentError.new('ja.key_2', expect: 'text_2', actual: 'text_9'),
        ])
      end
    end

    context 'args' do
      it 'should pass if the arguments are exclusive and exhaustive' do
        t1 = parse_yaml(<<-YAML).content['en']
        en:
          key_1: '%{arg_1} %{arg_2}'
        YAML
        t2 = parse_yaml(<<-YAML).content['ja']
        ja:
          key_1: '%{arg_1} %{arg_2}'
        YAML

        validator.validate(t1, t2)

        expect(validator.errors).to eq([])
      end

      it 'should be insensitive of the order of arguments' do
        t1 = parse_yaml(<<-YAML).content['en']
        en:
          key_1: '%{arg_1} %{arg_2}'
        YAML
        t2 = parse_yaml(<<-YAML).content['ja']
        ja:
          key_1: '%{arg_2} %{arg_1}'
        YAML

        validator.validate(t1, t2)

        expect(validator.errors).to eq([])
      end

      it 'should ignore confusing args' do
        t1 = parse_yaml(<<-YAML).content['en']
        en:
          key_1: 'foo %%{arg_1}'
        YAML
        t2 = parse_yaml(<<-YAML).content['ja']
        ja:
          key_1: 'foo'
        YAML

        validator.validate(t1, t2)

        expect(validator.errors).to eq([])
      end

      it 'should detect unbalanced arguments' do
        t1 = parse_yaml(<<-YAML).content['en']
        en:
          key_1: 'foo %{arg_1}'
        YAML
        t2 = parse_yaml(<<-YAML).content['ja']
        ja:
          key_1: 'foo %{arg_2}'
        YAML

        validator.validate(t1, t2)

        expect(validator.errors).to eq([
          I18nFlow::AsymmetricArgsError.new('ja.key_1',
            expect: ['arg_1'],
            actual: ['arg_2'],
          )
        ])
      end
    end
  end
end
