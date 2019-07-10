require 'psych'
require_relative 'command_base'
require_relative '../util'
require_relative '../parser'
require_relative '../yaml_ast_proxy'

class I18nFlow::CLI
  class CopyCommand < CommandBase
    def invoke!
      unless src_file && dst_file
        exit_with_message(1, 'usage: i18n_flow copy [--locale=LOCALE] SRC_FILE DST_FILE')
      end

      parser.parse!

      I18nFlow::YamlAstProxy.mark_as_todo(parser.root_proxy)

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
      @first_key_node = I18nFlow::YamlAstProxy.first_key_node_of(parser.root_proxy)
    end

  private

    def parser
      @parser ||= I18nFlow::Parser.new(File.read(src_file), file_path: src_file)
    end
  end
end
