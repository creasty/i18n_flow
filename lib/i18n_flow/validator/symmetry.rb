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
      keys = t1.content.keys | t2.content.keys

      keys.each do |k|
        validate_node(t1, t2, k)
      end
    end

    def validate_node(t1, t2, key)
      n1 = t1.content[key]
      n2 = t2.content[key]

      return if n1&.marked_as_ignored? || n2&.marked_as_ignored?

      check_only_tag(n1, n2)&.tap do |err|
        errors << err if err
        return
      end

      check_only_tag(n2, n1)&.tap do |err|
        errors << err if err
        return
      end

      check_asymmetric_key(n1, n2, t2)&.tap do |err|
        errors << err
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

      if n1.value?
        check_args(n1, n2)&.tap do |err|
          errors << err
        end
      else
        validate_content(n1, n2)
      end
    end

    def check_only_tag(n1, n2)
      return unless n1&.marked_as_only?

      if !n1.valid_locale?
        InvalidLocaleError.new(n1.full_key,
          expect: n1.valid_locales,
          actual: n1.locale,
        ).set_location(n1)
      elsif n2&.locale && !n1.valid_locales.include?(n2.locale)
        InvalidLocaleError.new(n2.full_key,
          expect: n1.valid_locales,
          actual: n2.locale,
        ).set_location(n2)
      else
        false
      end
    end

    def check_type(n1, n2)
      return unless n1 && n2
      return if n1.value? == n2.value?

      InvalidTypeError.new(n2.full_key).set_location(n2)
    end

    def check_asymmetric_key(n1, n2, t2)
      return if n1 && n2

      if n1
        full_key = [t2.locale, *n1.scopes.drop(1)].join('.')
        MissingKeyError.new(full_key).set_location(t2)
      else
        ExtraKeyError.new(n2.full_key).set_location(n2)
      end
    end

    def check_todo_tag(n1, n2)
      return unless n2.marked_as_todo?

      if !n2.value?
        InvalidTodoError.new(n2.full_key).set_location(n2)
      elsif n2.value != n1.value
        TodoContentError.new(n2.full_key,
          expect: n1.value,
          actual: n2.value,
        ).set_location(n2)
      end
    end

    def check_args(n1, n2)
      args_1 = I18nFlow::Util.extract_args(n1.value)
      args_2 = I18nFlow::Util.extract_args(n2.value)

      return if args_1 == args_2

      AsymmetricArgsError.new(n2.full_key,
        expect: args_1,
        actual: args_2,
      ).set_location(n2)
    end
  end
end
