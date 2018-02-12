require 'i18n_flow/repository'

describe I18nFlow::Repository do
  include_examples :create_repository

  describe '#file_paths' do
    it 'should return an array of matched file paths' do
      expect(repository.file_paths).to match_array([
        '/fixtures/models/user.en.yml',
        '/fixtures/models/user.ja.yml',
        '/fixtures/views/profiles/show.en.yml',
        '/fixtures/views/profiles/show.ja.yml',
        '/fixtures/views/profiles/show.fr.yml',
      ])
    end
  end

  describe '#asts_by_path' do
    it 'should return a hash of tree indexed by (relative) file paths' do
      expect(repository.asts_by_path.keys).to match_array([
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
      expect(repository.asts_by_scope.keys).to match_array([
        'models.user',
        'views.profiles.show',
      ])
      expect(repository.asts_by_scope['models.user'].keys).to match_array(['en', 'ja'])
      expect(repository.asts_by_scope['views.profiles.show'].keys).to match_array(['en', 'ja', 'fr'])
    end
  end
end
