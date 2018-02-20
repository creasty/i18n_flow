class I18nFlow::Search
  class Item
    attr_reader :locale
    attr_reader :file
    attr_reader :line
    attr_reader :value
    attr_reader :score

    def initialize(
      locale:,
      file:,
      line:,
      value:,
      score:
    )
      @locale = locale
      @file   = file
      @line   = line
      @value  = value
      @score  = score
    end
  end
end


class I18nFlow::Search
  attr_reader :repository
  attr_reader :pattern

  SCORE_KEY_CS_MATCH     = 10
  SCORE_KEY_CI_MATCH     = 9
  SCORE_CONTENT_CS_MATCH = 8
  SCORE_CONTENT_CI_MATCH = 6

  def initialize(
    repository:,
    pattern:,
    include_all: false
  )
    @repository  = repository
    @pattern     = pattern
    @include_all = include_all
  end

  def search!
    repository.asts_by_scope.each do |scope, locale_trees|
      asts = locale_trees
        .map { |locale, tree| tree[locale] }
        .compact

      search_on(asts)
    end
  end

  def results
    @results ||= indexed_results
      .sort_by { |k, rs| -rs.map(&:score).max }
      .to_h
  end

  def include_all?
    !!@include_all
  end

  def indexed_results
    @indexed_results ||= Hash.new { |h, k| h[k] = [] }
  end

  def pattern_downcase
    @pattern_downcase ||= pattern.downcase
  end

private

  def search_on(asts)
    if include_all?
      score = asts.map { |a| score_for(a) }.max
      if score > 0
        asts.each do |ast|
          add_result(ast, score: score)
        end
      end
    else
      asts.each do |ast|
        score = score_for(ast)
        next unless score > 0
        add_result(ast, score: score)
      end
    end

    recursive_asts = asts.reject { |a| a.scalar? || a.alias? }
    keys = recursive_asts.flat_map(&:keys).uniq

    keys.each do |k|
      search_on(recursive_asts.map { |a| a[k] }.compact)
    end
  end

  def add_result(node, score:)
    locale, *scopes = node.scopes
    key = scopes.join('.')

    indexed_results[key] << Item.new(
      locale: locale,
      file:   node.file_path,
      line:   node.start_line,
      value:  node.value,
      score:  score,
    )
  end

  def score_for(node)
    key = node.scopes[1..-1].join('.')

    key_match_score(key).tap do |score|
      return score if score > 0
    end

    if node.scalar?
      return content_match_score(node.value)
    end

    0
  end

  def key_match_score(key)
    if key == pattern
      return SCORE_KEY_CS_MATCH
    end
    if key.downcase == pattern_downcase
      return SCORE_KEY_CI_MATCH
    end

    0
  end

  def content_match_score(str)
    if str.include?(pattern)
      return SCORE_CONTENT_CS_MATCH * lcs_score(str, pattern)
    end

    str = str.downcase

    if str.include?(pattern_downcase)
      return SCORE_CONTENT_CI_MATCH * lcs_score(str, pattern_downcase)
    end

    0
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
