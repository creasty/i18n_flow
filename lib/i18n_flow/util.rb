module I18nFlow::Util
  extend self

  def extract_args(text)
    text.to_s
      .gsub(/%%/, '')
      .scan(/%\{([^\}]+)\}/)
      .flatten
      .sort
  end

  def filepath_to_scope(filepath)
    *scopes, filename = filepath.split('/')
    *basename, locale, _ = filename.split('.')

    ([locale] + scopes + basename).compact
  end
end
