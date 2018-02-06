require 'psych'

class I18nFlow::TreeBuilder < Psych::TreeBuilder
  attr_accessor :parser

  def initialize
    super
    @last_line = 0
  end

  def scalar(value, anchor, tag, plain, quoted, style)
    super.tap do |s|
      end_line = [parser.mark.line, @last_line + 1].max

      s.start_line = @last_line + 1
      s.end_line = end_line
      @last_line = end_line - 1
    end
  end

  def start_mapping(anchor, tag, implicit, style)
    mark = parser.mark
    super.tap do |s|
      s.start_line = mark.line
    end
  end

  def end_mapping
    mark = parser.mark
    super.tap do |s|
      s.end_line = mark.line
      @last_line = mark.line
    end
  end

  def start_sequence(anchor, tag, implicit, style)
    mark = parser.mark
    super.tap do |s|
      s.start_line = mark.line
    end
  end

  def end_sequence
    mark = parser.mark
    super.tap do |s|
      s.end_line = mark.line
      @last_line = mark.line
    end
  end

  def end_document(implicit)
    mark = parser.mark
    super.tap do |s|
      @last_line = mark.line
    end
  end

  def end_stream
    mark = parser.mark
    super.tap do |s|
      @last_line = mark.line
    end
  end
end
