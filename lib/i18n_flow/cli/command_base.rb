require_relative '../util'

class I18nFlow::CLI
  class CommandBase
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

    def exit_with_message(status, *args)
      if status.zero?
        puts(*args)
      else
        $stderr.puts(*args)
      end

      exit status
    end
  end
end
