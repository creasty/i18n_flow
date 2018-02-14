require 'yaml'
require 'pathname'
require_relative 'util'

class I18nFlow::Configuration
  module Validation
    def self.included(base)
      base.include(InstanceMethods)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def _validators
        @_validators ||= []
      end

      def validate(attr, message, &block)
        _validators << [attr, message, block]
      end
    end

    module InstanceMethods
      def validate!
        self.class._validators.each do |attr, message, block|
          next if instance_eval(&block)
          raise ValueError.new(attr, message)
        end
      end
    end
  end

  class NoConfigurationFileFoundError < ::IOError
    def message
      'no configuration file found'
    end
  end

  class ValueError < ::StandardError
    def initialize(attr, message)
      @attr    = attr
      @message = message
    end

    def message
      '%s: %s' % [@attr, @message]
    end
  end
end

class I18nFlow::Configuration
  include Validation

  CONFIG_FILES = [
    'i18n_flow.yml',
    'i18n_flow.yaml',
  ].freeze

  LINTERS = %i[
    file_scope
    symmetry
  ].freeze

  attr_reader(*%i[
    base_path
    glob_patterns
    valid_locales
    locale_pairs
    linters
    split_max_level
    split_line_threshold
  ])

  validate :base_path, 'need to be an absolute path' do
    !!base_path&.absolute?
  end

  validate :glob_patterns, 'should be an array' do
    !glob_patterns.nil?
  end

  validate :glob_patterns, 'should contain at least one pattern' do
    glob_patterns.any?
  end

  validate :valid_locales, 'should be an array' do
    !valid_locales.nil?
  end

  validate :valid_locales, 'should contain at least one pattern' do
    valid_locales.any?
  end

  validate :locale_pairs, 'should be an array' do
    !locale_pairs.nil?
  end

  validate :linters, "should be an array" do
    !linters.nil?
  end

  validate :linters, "should contain any of [#{LINTERS.join(', ')}]" do
    (linters - LINTERS).empty?
  end

  validate :split_max_level, 'must be set' do
    !split_max_level.nil?
  end

  validate :split_line_threshold, 'must be set' do
    !split_line_threshold.nil?
  end

  def initialize
    update(validate: false) do |c|
      c.base_path            = File.expand_path('.')
      c.glob_patterns        = ['*.en.yml']
      c.valid_locales        = %w[en]
      c.locale_pairs         = []
      c.linters              = LINTERS
      c.split_max_level      = 3
      c.split_line_threshold = 50
    end
  end

  def base_path=(path)
    @base_path = path&.tap do |v|
      break Pathname.new(v)
    end
  end

  def glob_patterns=(patterns)
    @glob_patterns = patterns&.tap do |v|
      break unless v.is_a?(Array)
      break v.map(&:to_s)
    end
  end

  def locale_pairs=(pairs)
    @locale_pairs = pairs&.tap do |v|
      break unless v.is_a?(Array)
      break unless v.all? { |e| e.size == 2 }
      break v.map { |e| e.map(&:to_s) }
    end
  end

  def valid_locales=(locales)
    @valid_locales = locales&.tap do |v|
      break unless v.is_a?(Array)
      break v.map(&:to_s)
    end
  end

  def linters=(linters)
    @linters = linters&.tap do |v|
      break unless v.is_a?(Array)
      break v.map(&:to_sym)
    end
  end

  def split_max_level=(level)
    @split_max_level = level&.tap do |v|
      break unless v.is_a?(Integer)
    end
  end

  def split_line_threshold=(threshold)
    @split_line_threshold = threshold&.tap do |v|
      break unless v.is_a?(Integer)
    end
  end

  def update(validate: true)
    yield self if block_given?
    validate! if validate
  end

  def auto_configure!
    load_from_file!
    update
  end

private

  def load_from_file!
    config_file = I18nFlow::Util.find_file_upward(*CONFIG_FILES)

    unless config_file
      raise NoConfigurationFileFoundError
    end

    yaml = YAML.load_file(config_file)
    yaml_dir = File.dirname(config_file)

    _base_path = yaml.delete('base_path')
    self.base_path = _base_path ? File.absolute_path(_base_path, yaml_dir) : yaml_dir

    yaml.each do |k, v|
      if respond_to?("#{k}=")
        send("#{k}=", v)
      else
        raise KeyError.new('invalid option: %s' % [k])
      end
    end
  end
end
