require 'psych'

class I18nFlow::TreeBuilder < Psych::Handler
  attr_reader :root
  attr_accessor :parser

  def initialize
    @stack     = []
    @root      = nil
    @last_line = nil
  end

  def start_mapping(anchor, tag, implicit, style)
    @last_line = parser.mark.line

    Psych::Nodes::Mapping.new(anchor, tag, implicit, style).tap do |n|
      n.start_line = @last_line
      @stack.last.children << n
      @stack << n
    end
  end

  def end_mapping
    @last_line = parser.mark.line

    @stack.pop.tap do |n|
      n.end_line = @last_line
    end
  end

  def start_sequence(anchor, tag, implicit, style)
    @last_line = parser.mark.line

    Psych::Nodes::Sequence.new(anchor, tag, implicit, style).tap do |n|
      n.start_line = @last_line
      @stack.last.children << n
      @stack << n
    end
  end

  def end_sequence
    @last_line = parser.mark.line

    @stack.pop.tap do |n|
      n.end_line = @last_line
    end
  end

  def start_document(version, tag_directives, implicit)
    @last_line = parser.mark.line

    # Psych::Nodes::Document.new(version, tag_directives, implicit).tap do |n|
    #   n.start_line = @last_line
    #   @stack.last.children << n
    #   @stack << n
    # end
  end

  def end_document(implicit_end = !streaming?)
    @last_line = parser.mark.line

    # @stack.pop.tap do |n|
    #   n.implicit_end = implicit_end
    #   n.end_line = @last_line
    # end
  end

  def start_stream(encoding)
    @last_line = parser.mark.line

    @root = Psych::Nodes::Stream.new(encoding).tap do |n|
      n.start_line = @last_line
      @stack << n
    end
  end

  def end_stream
    @last_line = parser.mark.line

    @stack.pop.tap do |n|
      n.end_line = @last_line
    end
  end

  def scalar(value, anchor, tag, plain, quoted, style)
    last_line = @last_line + 1
    @last_line = [parser.mark.line, last_line].max - 1

    Psych::Nodes::Scalar.new(value, anchor, tag, plain, quoted, style).tap do |s|
      s.start_line = last_line
      s.end_line = @last_line + 1
      @stack.last.children << s
    end
  end

  def alias(anchor)
    @last_line = parser.mark.line

    # Psych::Nodes::Alias.new(anchor).tap do |n|
    #   @stack.last.children << n
    # end
  end
end
