require 'i18n_flow/splitter/merger'

describe I18nFlow::Splitter::Merger do
  let(:merger) { I18nFlow::Splitter::Merger.new([]) }

  describe '#perform_merge!' do
    it 'should append root chunks' do
      ast_1 = parse_yaml_2(<<-YAML)
      en:
        map:
          foo_1: 'foo_1'
          bar_1: 'bar_1'
      YAML
      result = parse_yaml_2(<<-YAML)
      en:
        map:
          foo_1: 'foo_1'
          bar_1: 'bar_1'
      YAML

      allow(merger).to receive(:chunks).and_return([
        ast_1,
      ])

      merger.perform_merge!

      expect(merger.to_yaml).to eq(result.to_yaml)
    end

    it 'should append partial chunks' do
      ast_1 = parse_yaml_2(<<-YAML)
      en:
        map:
          foo_1: 'foo_1'
          bar_1: 'bar_1'
      YAML
      result = parse_yaml_2(<<-YAML)
      en:
        map:
          foo_1: 'foo_1'
          bar_1: 'bar_1'
      YAML

      allow(merger).to receive(:chunks).and_return([
        ast_1['en']['map'],
      ])

      merger.perform_merge!

      expect(merger.to_yaml).to eq(result.to_yaml)
    end

    it 'should merge root chunks' do
      ast_1 = parse_yaml_2(<<-YAML)
      en:
        map:
          foo_1: 'foo_1'
          bar: 'bar_1'
      YAML
      ast_2 = parse_yaml_2(<<-YAML)
      en:
        map:
          foo_2: 'foo_2'
          bar: 'bar_2'
      YAML
      result = parse_yaml_2(<<-YAML)
      en:
        map:
          foo_1: 'foo_1'
          foo_2: 'foo_2'
          bar: 'bar_2'
      YAML

      allow(merger).to receive(:chunks).and_return([
        ast_1,
        ast_2,
      ])

      merger.perform_merge!

      expect(merger.to_yaml).to eq(result.to_yaml)
    end

    it 'should merge partial chunks' do
      ast_1 = parse_yaml_2(<<-YAML)
      en:
        map:
          foo_1: 'foo_1'
          bar: 'bar_1'
      YAML
      ast_2 = parse_yaml_2(<<-YAML)
      en:
        map:
          foo_2: 'foo_2'
          bar: 'bar_2'
      YAML
      result = parse_yaml_2(<<-YAML)
      en:
        map:
          foo_1: 'foo_1'
          foo_2: 'foo_2'
          bar: 'bar_2'
      YAML

      allow(merger).to receive(:chunks).and_return([
        ast_1['en']['map']['foo_1'],
        ast_1['en']['map']['bar'],
        ast_2['en']['map'],
      ])

      merger.perform_merge!

      expect(merger.to_yaml).to eq(result.to_yaml)
    end
  end
end
