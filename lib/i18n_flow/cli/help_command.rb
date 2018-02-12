require_relative 'command_base'

class I18nFlow::CLI
  class HelpCommand < CommandBase
    TEXT = <<-HELP
Efficient and maintainable i18n workflow for real globalized applications

Usage:
    i18n_flow COMMAND [args...]
    i18n_flow [options]

Options:
    -v, --version    Show version

Commands:
    version
    help
    HELP

    def invoke!
      puts TEXT
    end
  end
end
