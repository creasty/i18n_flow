require_relative 'command_base'
require_relative '../util'

class I18nFlow::CLI
  class CopyCommand < CommandBase
    def invoke!
      @src_file = args[0]
      @dst_file = args[1]

      unless @src_file && @dst_file
        exit_with_message(1, 'usage: i18n_flow copy SRC_FILE DST_FILE')
      end

      parser = I18nFlow::Parser.new(File.read(@src_file), file_path: @src_file)
      parser.parse!
      mark_as_todo(parser.root_proxy)

      File.write(@dst_file, parser.root_proxy.to_yaml)
    end

    def mark_as_todo(ast)
      if ast.alias?
        return
      end
      if ast.scalar?
        ast.node.tag = '!todo'

        # https://github.com/ruby/psych/blob/f30b65befa4f0a5a8548d482424a84a2383b0284/ext/psych/yaml/emitter.c#L1187
        ast.node.plain = ast.node.quoted = false

        return
      end

      ast.each do |k, v|
        mark_as_todo(v)
      end
    end
  end
end
