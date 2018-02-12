describe I18nFlow::Validator::Multiplexer do
  let(:validator) do
     I18nFlow::Validator::Multiplexer.new(
       base_path:     '/fixtures',
       glob_patterns: ['models/**/*.yml', 'views/**/*.yml'],
       valid_locales: %w[en ja fr],
       master_locale: 'en',
     )
  end

  let(:models_user_en_yml) do
    <<-YAML
    en:
      models:
        user:
          key_1: text_1
    YAML
  end
  let(:models_user_ja_yml) do
    <<-YAML
    ja:
      models:
        user:
          key_1: text_1
    YAML
  end
  let(:views_profiles_show_en_yml) do
    <<-YAML
    en:
      views:
        profiles:
          show:
            key_1: text_1
    YAML
  end
  let(:views_profiles_show_ja_yml) do
    <<-YAML
    ja:
      views:
        profiles:
          show:
            key_1: text_1
    YAML
  end
  let(:views_profiles_show_fr_yml) do
    <<-YAML
    fr:
      views:
        profiles:
          show:
            key_1: text_1
    YAML
  end

  before do
    create_file('/fixtures/models/user.en.yml', models_user_en_yml)
    create_file('/fixtures/models/user.ja.yml', models_user_ja_yml)
    create_file('/fixtures/views/profiles/show.en.yml', views_profiles_show_en_yml)
    create_file('/fixtures/views/profiles/show.ja.yml', views_profiles_show_ja_yml)
    create_file('/fixtures/views/profiles/show.fr.yml', views_profiles_show_fr_yml)
  end

  describe '#file_paths' do
    it 'should return an array of matched file paths' do
      expect(validator.file_paths).to match_array([
        '/fixtures/models/user.en.yml',
        '/fixtures/models/user.ja.yml',
        '/fixtures/views/profiles/show.en.yml',
        '/fixtures/views/profiles/show.ja.yml',
        '/fixtures/views/profiles/show.fr.yml',
      ])
    end
  end

  describe '#asts' do
    it 'should return a hash of tree indexed by (relative) file paths' do
      expect(validator.asts.keys).to match_array([
        'models/user.en.yml',
        'models/user.ja.yml',
        'views/profiles/show.en.yml',
        'views/profiles/show.ja.yml',
        'views/profiles/show.fr.yml',
      ])
    end
  end

  describe '#asts_by_scope' do
    it 'should return a hash of tree indexed by scopes' do
      expect(validator.asts_by_scope.keys).to match_array([
        'models.user',
        'views.profiles.show',
      ])
      expect(validator.asts_by_scope['models.user'].keys).to match_array(['en', 'ja'])
      expect(validator.asts_by_scope['views.profiles.show'].keys).to match_array(['en', 'ja', 'fr'])
    end
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
