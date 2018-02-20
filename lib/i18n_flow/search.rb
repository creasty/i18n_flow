class I18nFlow::Search
  attr_reader :repository
  attr_reader :pattern

  def initialize(repository:, pattern:)
    @repository = repository
    @pattern    = pattern
  end

  def search!
    repository.asts_by_path.each do |path, ast|
      search_on(ast)
    end

    results.sort_by! { |r| -r[:score] }
  end

  def results
    @results ||= []
  end

private

  def search_on(ast)
    add_result(ast)

    return if ast.scalar? || ast.alias?

    ast.each do |_, v|
      search_on(v)
    end
  end

  def add_result(node)
    locale, *scopes = node.scopes
    key = scopes.join('.')

    score = if node.mapping?
      key_match_score(key)
    elsif node.scalar?
      content_match_score(node.value)
    else
      0
    end

    return unless score > 0

    results << {
      locale: locale,
      key:    key,
      file:   node.file_path,
      line:   node.start_line,
      value:  node.value,
      score:  score,
    }
  end

  def key_match_score(key)
    if key == pattern
      return 10
    end
    if key.downcase == pattern.downcase
      return 9
    end

    return 0
  end

  def content_match_score(str)
    if str.include?(pattern)
      return 8 * lcs_score(str, pattern)
    end
    if str.downcase.include?(pattern.downcase)
      return 6 * lcs_score(str.downcase, pattern.downcase)
    end

    return 0
  end

  def lcs_score(a, b)
    a_size = a.size
    b_size = b.size

    m = Array.new(a_size) { 0 }

    result = 0

    b_size.times do |i|
      result = d = 0

      a_size.times do |j|
        t = (b[i] == a[j]) ? d + 1 : d
        d = m[j]

        m[j] = result = [d, t, result].max
      end
    end

    result * 2.0 / (a_size + b_size)
  end
end
