require_relative '../util'

class I18nFlow::CLI
  class CommandBase
    COLORS = {
      black:   30,
      red:     31,
      green:   32,
      yellow:  33,
      blue:    34,
      magenta: 35,
      cyan:    36,
      white:   37,
    }

    attr_reader(*%i[
      args
      options
    ])

    def initialize(args)
      @args    = args.dup
      @options = I18nFlow::Util::parse_options(@args)
    end

    def invoke!
      raise 'Not implemented'
    end

    def invoke
      begin
        invoke!
      rescue => e
        exit_with_message(1, '[%s] %s' % [e.class.name, e.message])
      end
    end

    def exit_with_message(status, *args)
      if status.zero?
        puts(*args)
      else
        $stderr.puts(*args)
      end

      exit status
    end

    def color(str, c)
      "\e[1;#{COLORS[c]}m#{str}\e[0m"
    end
  end
end
