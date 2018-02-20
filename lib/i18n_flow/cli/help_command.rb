require_relative 'command_base'

class I18nFlow::CLI
  class HelpCommand < CommandBase
    TEXT = <<-HELP
Manage translation status in yaml file

Usage:
    i18n_flow COMMAND [args...]
    i18n_flow [options]

Options:
    -v, --version    Show version
    -h               Show help

Commands:
    lint       Validate files
    search     Search contents and keys
    copy       Copy translations and mark as todo
    split      Split a file into proper-sized files
    version    Show version
    help       Show help
    HELP

    def invoke!
      puts TEXT
    end
  end
end
