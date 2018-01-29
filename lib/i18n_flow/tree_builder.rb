require 'psych'

class I18nFlow::TreeBuilder < Psych::TreeBuilder
  attr_accessor :parser

  def scalar(value, anchor, tag, plain, quoted, style)
    mark = parser.mark
    super.tap do |s|
      s.start_line = mark.line
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
    end
  end
end
