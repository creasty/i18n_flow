module I18nFlow::YamlAstProxy
  module NodeMetaData
    def num_lines
      return 1 unless end_line
      end_line - start_line + 1
    end

    def key
      scopes.last
    end

    def locale
      scopes.first
    end

    def full_key
      scopes.join('.')
    end

    def start_line
      node.start_line + line_correction
    end

    def end_line
      node.end_line + line_correction
    end

    def start_column
      node.start_column
    end

    def end_column
      node.end_column
    end

    def anchor
      node.anchor
    end

    def sequence?
      is_a?(Sequence)
    end

    def mapping?
      is_a?(Mapping)
    end

    def scalar?
      node.is_a?(Psych::Nodes::Scalar)
    end

    def alias?
      node.is_a?(Psych::Nodes::Alias)
    end

    def has_anchor?
      !!anchor
    end

    def marked_as_todo?
      @tag == :todo
    end

    def marked_as_only?
      @tag == :only
    end

    def todo_locales
      @todo_locales ||= []
    end

    def valid_locales
      @valid_locales ||= []
    end

    def valid_locale?
      valid_locales.empty? || valid_locales.include?(locale)
    end

  private

    def line_correction
      node.is_a?(Psych::Nodes::Scalar) ? 1 : 0
    end
  end
end
