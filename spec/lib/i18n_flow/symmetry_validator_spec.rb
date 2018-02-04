require 'i18n_flow/validation_error'

describe I18nFlow::SymmetryValidator do
  let(:validator) { I18nFlow::SymmetryValidator.new }

  describe '#validate' do
    it 'should pass if the given trees are completely the same' do
      t1 = parse_yaml(<<-YAML)
      en:
        key_1: text_1
        foo:
          key_2: text_2
      YAML
      t2 = parse_yaml(<<-YAML)
      ja:
        key_1: text_1
        foo:
          key_2: text_2
      YAML

      validator.validate(t1['en'], t2['ja'])

      expect(validator.errors).to eq({})
    end

    context 'asymmetric key' do
      it 'should detect' do
        t1 = parse_yaml(<<-YAML)
        en:
          key_1: text_1
          key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML)
        ja:
          key_1: text_1
          key_3: text_3
        YAML

        validator.validate(t1['en'], t2['ja'])

        expect(validator.errors).to eq({
          'en.key_2' => I18nFlow::AsymmetricKeyError.new,
          'ja.key_3' => I18nFlow::AsymmetricKeyError.new,
        })
      end

      it 'should detect on nested node' do
        t1 = parse_yaml(<<-YAML)
        en:
          key_1: text_1
          foo:
            key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML)
        ja:
          key_1: text_1
          foo:
            key_3: text_3
        YAML

        validator.validate(t1['en'], t2['ja'])

        expect(validator.errors).to eq({
          'en.foo.key_2' => I18nFlow::AsymmetricKeyError.new,
          'ja.foo.key_3' => I18nFlow::AsymmetricKeyError.new,
        })
      end

      it 'should suppress an error on the ignored node (value)' do
        t1 = parse_yaml(<<-YAML)
        en:
          key_1: text_1
          key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML)
        ja:
          key_1: text_1
          key_3: !ignore text_3
        YAML

        validator.validate(t1['en'], t2['ja'])

        expect(validator.errors).to eq({
          'en.key_2' => I18nFlow::AsymmetricKeyError.new,
        })
      end

      it 'should suppress an error on the ignored node (map)' do
        t1 = parse_yaml(<<-YAML)
        en:
          key_1: text_1
          foo:
            key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML)
        ja:
          key_1: text_1
          foo: !ignore
            key_3: text_3
        YAML

        validator.validate(t1['en'], t2['ja'])

        expect(validator.errors).to eq({})
      end
    end

    context 'type mismatch' do
      it 'should detect' do
        t1 = parse_yaml(<<-YAML)
        en:
          key_1: text_1
          key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML)
        ja:
          key_1: text_1
          key_2:
            one: text_2
        YAML

        validator.validate(t1['en'], t2['ja'])

        expect(validator.errors).to eq({
          'ja.key_2' => I18nFlow::TypeMismatchError.new,
        })
      end

      it 'should detect on nested node' do
        t1 = parse_yaml(<<-YAML)
        en:
          key_1: text_1
          foo:
            key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML)
        ja:
          key_1: text_1
          foo:
            key_2:
              one: text_2
        YAML

        validator.validate(t1['en'], t2['ja'])

        expect(validator.errors).to eq({
          'ja.foo.key_2' => I18nFlow::TypeMismatchError.new,
        })
      end

      it 'suppress an error on the ignored node' do
        t1 = parse_yaml(<<-YAML)
        en:
          key_1: text_1
          key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML)
        ja:
          key_1: text_1
          key_2: !ignore
            one: text_2
        YAML

        validator.validate(t1['en'], t2['ja'])

        expect(validator.errors).to eq({})
      end

      it 'suppress an error on the ignored node (outer map)' do
        t1 = parse_yaml(<<-YAML)
        en:
          key_1: text_1
          foo:
            key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML)
        ja:
          key_1: text_1
          foo: !ignore
            key_2:
              one: text_2
        YAML

        validator.validate(t1['en'], t2['ja'])

        expect(validator.errors).to eq({})
      end
    end

    context 'explicitly-annotated asymmetry' do
      it 'should pass if the asymmetric node is tagged with its locale (value)' do
        t1 = parse_yaml(<<-YAML)
        en:
          key_1: text_1
          key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML)
        ja:
          key_1: text_1
          key_2: text_2
          key_3: !only:ja text_3
        YAML

        validator.validate(t1['en'], t2['ja'])

        expect(validator.errors).to eq({})
      end

      it 'should pass if the asymmetric node is tagged with its locale (map)' do
        t1 = parse_yaml(<<-YAML)
        en:
          key_1: text_1
          key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML)
        ja:
          key_1: text_1
          key_2: text_2
          key_3: !only:ja
            one: text_3
        YAML

        validator.validate(t1['en'], t2['ja'])

        expect(validator.errors).to eq({})
      end

      it 'should pass if the symmetric node is tagged with both locales' do
        t1 = parse_yaml(<<-YAML)
        en:
          key_1: text_1
          key_2: !only:en,ja text_2
        YAML
        t2 = parse_yaml(<<-YAML)
        ja:
          key_1: text_1
          key_2: !only:en,ja text_2
        YAML

        validator.validate(t1['en'], t2['ja'])

        expect(validator.errors).to eq({})
      end

      it 'should fail if the symmetric node is tagged with an one-side locale' do
        t1 = parse_yaml(<<-YAML)
        en:
          key_1: text_1
          key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML)
        ja:
          key_1: text_1
          key_2: !only:ja text_2
        YAML

        validator.validate(t1['en'], t2['ja'])

        expect(validator.errors).to eq({
          'en.key_2' => I18nFlow::InvalidLocaleError.new(expect: ['ja'], actual: 'en'),
        })
      end

      it 'should fail if the asymmetric node is tagged with a different locale' do
        t1 = parse_yaml(<<-YAML)
        en:
          key_1: text_1
          key_2: text_2
        YAML
        t2 = parse_yaml(<<-YAML)
        ja:
          key_1: text_1
          key_2: text_2
          key_3: !only:en
            one: text_3
        YAML

        validator.validate(t1['en'], t2['ja'])

        expect(validator.errors).to eq({
          'ja.key_3' => I18nFlow::InvalidLocaleError.new(expect: ['en'], actual: 'ja'),
        })
      end
    end
  end
end
