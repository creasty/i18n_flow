require 'psych'
require_relative 'command_base'
require_relative '../util'
require_relative '../parser'

class I18nFlow::CLI
  class CopyCommand < CommandBase
    def invoke!
      unless src_file && dst_file
        exit_with_message(1, 'usage: i18n_flow copy [--locale=LOCALE] SRC_FILE DST_FILE')
      end

      parser.parse!

      mark_as_todo(parser.root_proxy)

      if locale && first_key_node
        first_key_node.value = locale
      end

      File.write(dst_file, parser.root_proxy.to_yaml)
    end

    def src_file
      args[0]
    end

    def dst_file
      args[1]
    end

    def locale
      options['locale']
    end

    def first_key_node
      return @first_key_node if defined?(@first_key_node)
      @first_key_node = parser.root_proxy
        .send(:indexed_object)
        .node
        .tap { |n| break unless n.is_a?(Psych::Nodes::Mapping) }
        &.tap { |n| break n.children.first }
    end

  private

    def parser
      @parser ||= I18nFlow::Parser.new(File.read(src_file), file_path: src_file)
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
