class I18nFlow::CLI
  module Color
    COLORS = {
      black:   30,
      red:     31,
      green:   32,
      yellow:  33,
      blue:    34,
      magenta: 35,
      cyan:    36,
      white:   37,
    }.freeze

    def color(str, c)
      "\e[1;#{COLORS[c]}m#{str}\e[0m"
    end
  end
end
