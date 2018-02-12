require 'i18n_flow/configuration'

describe I18nFlow do
  describe '.config' do
    it 'should return an instance of Configuration' do
      expect {
        expect(I18nFlow.config).to be_a(I18nFlow::Configuration)
      }.not_to raise_error
    end
  end

  describe '.configure' do
    it 'should change option values inside a block' do
      expect {
        I18nFlow.configure do |config|
          expect(config).to be_a(I18nFlow::Configuration)
        end
      }.not_to raise_error
    end
  end
end
