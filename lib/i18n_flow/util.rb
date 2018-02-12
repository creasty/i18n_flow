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

    ([locale] + scopes + basename).compact.reject(&:empty?)
  end

  def scope_to_filepath(scopes)
    locale, *components = scopes
    [components.join('/'), locale, 'yml'].compact.reject(&:empty?).join('.')
  end

  def find_file_upward(*file_names)
    pwd  = Dir.pwd
    base = Hash.new { |h, k| h[k] = pwd }
    file = {}

    while base.values.all? { |b| '.' != b && '/' != b }
      file_names.each do |name|
        file[name] = File.join(base[name], name)
        base[name] = File.dirname(base[name])

        return file[name] if File.exists?(file[name])
      end
    end

    nil
  end
end
