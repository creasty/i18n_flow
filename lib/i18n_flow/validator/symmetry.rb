require_relative 'errors'
require_relative '../util'

module I18nFlow::Validator
  class Symmetry
    attr_reader :ast_1
    attr_reader :ast_2

    def initialize(ast_1, ast_2)
      @ast_1 = ast_1
      @ast_2 = ast_2
    end

    def validate!
      @errors = nil
      validate_content(ast_1, ast_2)
    end

    def errors
      @errors ||= []
    end

  private

    def validate_content(t1, t2)
      keys = t1.keys | t2.keys

      keys.each do |k|
        validate_node(t1, t2, k)
      end
    end

    def validate_node(t1, t2, key)
      n1 = t1[key]
      n2 = t2[key]

      check_only_tag(n1, n2)&.tap do |err|
        errors << err if err
        return
      end

      check_asymmetric_key(n1, n2, t2, key)&.tap do |err|
        errors << err if err
        return
      end

      check_type(n1, n2)&.tap do |err|
        errors << err
        return
      end

      check_todo_tag(n1, n2)&.tap do |err|
        errors << err
        return
      end

      if n1.scalar? || n1.alias?
        check_args(n1, n2)&.tap do |err|
          errors << err
        end
      else
        validate_content(n1, n2)
      end
    end

    def check_only_tag(n1, n2)
      return unless n1&.marked_as_only? || n2&.marked_as_only?

      if n1 && !n1.valid_locale?
        return InvalidLocaleError.new(n1.full_key,
          expect: n1.valid_locales,
          actual: n1.locale,
        ).set_location(n1)
      end

      if n2 && !n2.valid_locale?
        return InvalidLocaleError.new(n2.full_key,
          expect: n2.valid_locales,
          actual: n2.locale,
        ).set_location(n2)
      end

      if n1 && !n2 && n1.marked_as_only?
        return false
      end

      if !n1 && n2 && n2.marked_as_only?
        return false
      end

      if n1 && n2 && n1.valid_locales.any? && !n1.valid_locales.include?(n2.locale)
        return InvalidLocaleError.new(n2.full_key,
          expect: n1.valid_locales,
          actual: n2.locale,
        ).set_location(n2)
      end

      if n1 && n2 && n2.valid_locales.any? && !n2.valid_locales.include?(n1.locale)
        return InvalidLocaleError.new(n1.full_key,
          expect: n2.valid_locales,
          actual: n1.locale,
        ).set_location(n1)
      end

      false
    end

    def check_type(n1, n2)
      return unless n1 && n2
      return if n1.scalar? == n2.scalar?

      InvalidTypeError.new(n2.full_key).set_location(n2)
    end

    def check_asymmetric_key(n1, n2, t2, key)
      return false if n1&.ignored_violation == :key || n2&.ignored_violation == :key
      return if n1 && n2

      if n1
        full_key = [t2.locale, *n1.scopes.drop(1)].join('.')
        MissingKeyError.new(full_key).set_location(t2)
          .set_correction_context(dest_node: t2, dest_key: key, src_node: n1)
      else
        ExtraKeyError.new(n2.full_key).set_location(n2)
      end
    end

    def check_todo_tag(n1, n2)
      return unless n2.marked_as_todo?

      if !n2.scalar?
        InvalidTodoError.new(n2.full_key).set_location(n2)
      elsif n2.value != n1.value
        TodoContentError.new(n2.full_key,
          expect: n1.value,
          actual: n2.value,
        ).set_location(n2)
      end
    end

    def check_args(n1, n2)
      return if n1.ignored_violation == :args || n2.ignored_violation == :args

      args_1 = I18nFlow::Util.extract_args(n1.value).uniq
      args_2 = I18nFlow::Util.extract_args(n2.value).uniq

      return if args_1 == args_2

      AsymmetricArgsError.new(n2.full_key,
        expect: args_1,
        actual: args_2,
      ).set_location(n2)
    end
  end
end
