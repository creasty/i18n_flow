require_relative 'node_meta_data'
require 'forwardable'

module I18nFlow::YamlAstProxy
  class Node
    extend Forwardable
    include NodeMetaData

    TAG_IGNORE = /^!ignore:(args|key)$/
    TAG_TODO   = /^!todo(?::([,a-zA-Z_-]+))?$/
    TAG_ONLY   = /^!only(?::([,a-zA-Z_-]+))?$/

    attr_reader :node
    attr_reader :parent
    attr_reader :scopes
    attr_reader :file_path
    attr_reader :ignored_violation

    def_delegators :indexed_object, :each

    def initialize(
      node,
      parent:    nil,
      scopes:    [],
      file_path: nil
    )
      @node      = node
      @parent    = parent
      @scopes    = scopes
      @file_path = file_path

      parse_tag!(node.tag)
    end

    def get(key)
      wrap(indexed_object[key], key: key)
    end
    alias [] get

    def set(key, value)
      indexed_object[key] = value
    end
    alias []= set

    def value
      node.value if node.respond_to?(:value)
    end

    def merge!(other)
      return unless other&.is_a?(Node)

      if scalar? && other.scalar?
        node.value = other.value
        return
      end

      if !scalar? && !other.scalar?
        batch do
          other.batch do
            other.each do |k, rhs|
              if (lhs = self[k])
                lhs.merge!(rhs)
              else
                self[k] = rhs.node
              end
            end
          end
        end
      end
    end

    def batch
      yield
    end

    def ==(other)
      return false unless other.is_a?(self.class)
      identity_data == other.identity_data
    end

    def to_yaml
      parent.to_yaml(nil, line_width: -1)
    end

    def keys
      return [] if scalar? || alias?
      indexed_object.keys
    end

  private

    def identity_data
      (scalar? || alias?) ? value : indexed_object
    end

    def indexed_object
      @indexed_object ||= I18nFlow::YamlAstProxy.create(node,
        parent:    parent,
        scopes:    scopes,
        file_path: file_path,
      )
    end

    def wrap(value, key:)
      I18nFlow::YamlAstProxy.create(value,
        parent:    node,
        scopes:    [*scopes, key],
        file_path: file_path,
      )
    end

    def parse_tag!(tag)
      return unless tag

      case tag
      when TAG_TODO
        @tag = :todo
        @todo_locales = $1.to_s.split(',').freeze
      when TAG_ONLY
        @tag = :only
        @valid_locales = $1.to_s.split(',').freeze
      when TAG_IGNORE
        @tag = :ignore
        @ignored_violation = $1.freeze.to_sym
      end
    end
  end
end
