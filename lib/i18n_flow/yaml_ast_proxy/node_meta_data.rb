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
      correction = node.is_a?(Psych::Nodes::Scalar) ? 1 : 0
      node.start_line + correction
    end

    def end_line
      correction = node.is_a?(Psych::Nodes::Scalar) ? 1 : 0
      node.end_line + correction
    end

    def anchor
      node.anchor
    end

    def has_anchor?
      !!anchor
    end

    def marked_as_todo?
      @tag == :todo
    end

    def marked_as_ignored?
      @tag == :ignore
    end

    def marked_as_only?
      @tag == :only && valid_locales.any?
    end

    def todo_locales
      @todo_locales ||= []
    end

    def valid_locales
      @valid_locales ||= []
    end

    def valid_locale?
      !marked_as_only? || valid_locales.include?(locale)
    end
  end
end
