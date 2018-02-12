require 'i18n_flow/cli/version_command'

describe I18nFlow::CLI::VersionCommand do
  let(:command) { I18nFlow::CLI::VersionCommand.new([]) }

  describe '#invoke!' do
    it 'should print gem version' do
      expect {
        command.invoke!
      }.to output(/v\d+\.\d+.\d+/).to_stdout
    end
  end
end
