describe I18nFlow::Validator do
  let(:validator) do
     I18nFlow::Validator.new(
       base_path:     '/fixtures',
       glob_patterns: ['models/**/*.yml', 'views/**/*.yml'],
       valid_locales: %w[ja en fr],
       master_locale: 'ja',
     )
  end

  before do
    create_file('/fixtures/models/user.en.yml', <<-YAML)
    en:
      models:
        user:
          key_1: text_1
    YAML
    create_file('/fixtures/models/user.ja.yml', <<-YAML)
    ja:
      models:
        user:
          key_1: text_1
    YAML
    create_file('/fixtures/views/profiles/show.en.yml', <<-YAML)
    en:
      views:
        profiles:
          show:
            key_1: text_1
    YAML
    create_file('/fixtures/views/profiles/show.ja.yml', <<-YAML)
    ja:
      views:
        profiles:
          show:
            key_1: text_1
    YAML
    create_file('/fixtures/views/profiles/show.fr.yml', <<-YAML)
    fr:
      views:
        profiles:
          show:
            key_1: text_1
    YAML
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

  describe '#trees' do
    it 'should return a hash of tree indexed by (relative) file paths' do
      expect(validator.trees.keys).to match_array([
        'models/user.en.yml',
        'models/user.ja.yml',
        'views/profiles/show.en.yml',
        'views/profiles/show.ja.yml',
        'views/profiles/show.fr.yml',
      ])
    end
  end

  describe '#trees_by_scope' do
    it 'should return a hash of tree indexed by scopes' do
      expect(validator.trees_by_scope.keys).to match_array([
        'models.user',
        'views.profiles.show',
      ])
      expect(validator.trees_by_scope['models.user'].keys).to match_array(['en', 'ja'])
      expect(validator.trees_by_scope['views.profiles.show'].keys).to match_array(['en', 'ja', 'fr'])
    end
  end

  describe '#validate' do
    it 'should' do
      validator.validate
      expect(validator.errors).to eq({})
    end
  end
end
