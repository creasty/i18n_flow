shared_examples :create_repository do
  let(:repository) do
    I18nFlow::Repository.new(
      base_path:     '/fixtures',
      glob_patterns: ['models/**/*.yml', 'views/**/*.yml'],
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
end
