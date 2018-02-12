class I18nFlow::CLI
  require_relative 'cli/version_command'
  require_relative 'cli/help_command'

  COMMANDS = {
    'version' => VersionCommand,
    'help'    => HelpCommand,
  }

  attr_reader :args
  attr_reader :command

  def initialize(args)
    @command, *@args = args
  end

  def run
    command_class = COMMANDS[command] || COMMANDS['help']
    command_class.new(args).invoke
  end
end
