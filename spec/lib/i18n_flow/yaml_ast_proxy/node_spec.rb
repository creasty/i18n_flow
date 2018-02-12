require 'psych'
require 'i18n_flow/yaml_ast_proxy'

describe I18nFlow::YamlAstProxy::Node do
  describe '#merge!' do
    it 'should merge mappings' do
      ast_1 = parse_yaml(<<-YAML)
      map:
        foo_1: 'foo_1'
        bar: 'bar_1'
      YAML
      ast_2 = parse_yaml(<<-YAML)
      map:
        foo_2: 'foo_2'
        bar: 'bar_2'
      YAML
      result = parse_yaml(<<-YAML)
      map:
        foo_1: 'foo_1'
        bar: 'bar_2'
        foo_2: 'foo_2'
      YAML

      ast_1['map'].merge!(ast_2['map'])

      expect(ast_1.to_yaml).to eq(result.to_yaml)
    end

    it 'should merge sequences' do
      ast_1 = parse_yaml(<<-YAML)
      seq:
        - 'seq_1_1'
        - 'seq_1_2'
      YAML
      ast_2 = parse_yaml(<<-YAML)
      seq:
        - 'seq_2_1'
        - 'seq_2_2'
      YAML
      result = parse_yaml(<<-YAML)
      seq:
        - 'seq_1_1'
        - 'seq_1_2'
        - 'seq_2_1'
        - 'seq_2_2'
      YAML

      ast_1['seq'].merge!(ast_2['seq'])

      expect(ast_1.to_yaml).to eq(result.to_yaml)
    end

    it 'should merge nested mappings' do
      ast_1 = parse_yaml(<<-YAML)
      en:
        map:
          foo_1: 'foo_1'
          bar: 'bar_1'
      YAML
      ast_2 = parse_yaml(<<-YAML)
      en:
        map:
          foo_2: 'foo_2'
          bar: 'bar_2'
        map_2:
          baz_2: 'baz_2'
      YAML
      result = parse_yaml(<<-YAML)
      en:
        map:
          foo_1: 'foo_1'
          bar: 'bar_2'
          foo_2: 'foo_2'
        map_2:
          baz_2: 'baz_2'
      YAML

      ast_1['en'].merge!(ast_2['en'])

      expect(ast_1.to_yaml).to eq(result.to_yaml)
    end

    it 'should merge nested sequences' do
      ast_1 = parse_yaml(<<-YAML)
      en:
        seq:
          - 'foo_1_1'
          - 'foo_1_2'
      YAML
      ast_2 = parse_yaml(<<-YAML)
      en:
        seq:
          - 'foo_2_1'
          - 'foo_2_2'
      YAML
      result = parse_yaml(<<-YAML)
      en:
        seq:
          - 'foo_1_1'
          - 'foo_1_2'
          - 'foo_2_1'
          - 'foo_2_2'
      YAML

      ast_1['en'].merge!(ast_2['en'])

      expect(ast_1.to_yaml).to eq(result.to_yaml)
    end

    it 'should merge root' do
      ast_1 = parse_yaml(<<-YAML)
      en:
        map:
          foo_1: 'foo_1'
          bar: 'bar_1'
          seq:
            - 'foo_1_1'
            - 'foo_1_2'
      YAML
      ast_2 = parse_yaml(<<-YAML)
      en:
        map:
          foo_2: 'foo_2'
          bar: 'bar_2'
          seq:
            - 'foo_2_1'
            - 'foo_2_2'
        map_2:
          baz_2: 'baz_2'
      YAML
      result = parse_yaml(<<-YAML)
      en:
        map:
          foo_1: 'foo_1'
          bar: 'bar_2'
          seq:
            - 'foo_1_1'
            - 'foo_1_2'
            - 'foo_2_1'
            - 'foo_2_2'
          foo_2: 'foo_2'
        map_2:
          baz_2: 'baz_2'
      YAML

      ast_1.merge!(ast_2)

      expect(ast_1.to_yaml).to eq(result.to_yaml)
    end
  end
end
