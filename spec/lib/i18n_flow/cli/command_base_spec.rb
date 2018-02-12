require 'i18n_flow/cli/command_base'

describe I18nFlow::CLI::CommandBase do
  let(:command) { I18nFlow::CLI::CommandBase.new([]) }

  describe '#invoke!' do
    it 'should raise a not implemented error' do
      expect {
        command.invoke!
      }.to raise_error(/implemented/)
    end
  end

  describe '#invoke' do
    it 'should call `invoke!`' do
      expect(command).to receive(:invoke!).and_return(nil)
      command.invoke
    end

    it 'should exit with an error message' do
      expect(command).to receive(:exit_with_message)
      command.invoke
    end
  end

  describe '#exit_with_message' do
    let(:message)        { 'a message' }
    let(:message_regexp) { /a message/ }

    context 'With status code of zero' do
      let(:status)  { 0 }

      it 'should print a message to stdout and exit' do
        expect {
          begin
            command.exit_with_message(status, message)
          rescue SystemExit => e
            expect(e.status).to eq(status)
          end
        }.to output(message_regexp).to_stdout
      end
    end

    context 'With status code of non-zero' do
      let(:status)  { 1 }

      it 'should print a message to stderr and exit' do
        expect {
          begin
            command.exit_with_message(status, message)
          rescue SystemExit => e
            expect(e.status).to eq(status)
          end
        }.to output(message_regexp).to_stderr
      end
    end
  end
end
