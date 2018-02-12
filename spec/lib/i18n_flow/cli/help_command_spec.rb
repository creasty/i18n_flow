require 'i18n_flow/cli/help_command'

describe I18nFlow::CLI::HelpCommand do
  let(:command) { I18nFlow::CLI::HelpCommand.new([]) }

  describe '#invoke!' do
    it 'should print help' do
      expect {
        command.invoke!
      }.to output(/Usage/).to_stdout
    end
  end
end
