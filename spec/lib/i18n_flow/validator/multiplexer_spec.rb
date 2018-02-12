describe I18nFlow::Validator::Multiplexer do
  include_examples :create_repository

  let(:validator) do
     I18nFlow::Validator::Multiplexer.new(
       repository:    repository,
       valid_locales: %w[en ja fr],
       master_locale: 'en',
     )
  end

  describe '#validate' do
    it 'should pass' do
      validator.validate!
      expect(validator.errors).to eq({})
    end

    context 'violate single validator rules' do
      let(:models_user_ja_yml) do
        <<-YAML
        ja:
          modulo:
            user:
              key_1: text_1
        YAML
      end

      it 'should fail' do
        validator.validate!
        expect(validator.errors).to eq({
          'models/user.ja.yml' => {
            'ja.models' => I18nFlow::Validator::MissingKeyError.new('ja.models'),
            'ja.modulo' => I18nFlow::Validator::ExtraKeyError.new('ja.modulo'),
          },
        })
      end
    end

    context 'violate symmetry validator rules' do
      let(:views_profiles_show_ja_yml) do
        <<-YAML
        ja:
          views:
            profiles:
              show:
                key_2: text_2
        YAML
      end

      it 'should fail' do
        validator.validate!
        expect(validator.errors).to eq({
          'views/profiles/show.ja.yml' => {
            'ja.views.profiles.show.key_2' => I18nFlow::Validator::ExtraKeyError.new('ja.views.profiles.show.key_2'),
            'ja.views.profiles.show.key_1' => I18nFlow::Validator::MissingKeyError.new('ja.views.profiles.show.key_1'),
          },
        })
      end
    end
  end
end
