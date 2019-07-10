require 'i18n_flow/formatter'

describe I18nFlow::Formatter do
  def format_ast(ast)
    I18nFlow::Formatter.new(ast)
      .tap(&:format!)
      .ast
  end

  describe '#format!' do
    it 'should remove extra whitespaces' do
      ast = parse_yaml(<<-YAML)
      en:
        alfa: 'A'

        bravo:   'B'
        charlie: 'C'
        delta:   'D'
        echo:    'E'
        foxtrot: 'F'

        golf: 'G'
        hotel: 'H'
      YAML
      result = parse_yaml(<<-YAML)
      en:
        alfa: 'A'
        bravo: 'B'
        charlie: 'C'
        delta: 'D'
        echo: 'E'
        foxtrot: 'F'
        golf: 'G'
        hotel: 'H'
      YAML

      formatted = format_ast(ast)
      expect(formatted.to_yaml).to eq(result.to_yaml)
    end

    context 'sort keys' do
      it 'should sort keys' do
        ast = parse_yaml(<<-YAML)
        en:
          echo: 'E'
          delta: 'D'
          foxtrot: 'F'
          alfa: 'A'
          hotel: 'H'
          bravo: 'B'
          charlie: 'C'
          golf: 'G'
        YAML
        result = parse_yaml(<<-YAML)
        en:
          alfa: 'A'
          bravo: 'B'
          charlie: 'C'
          delta: 'D'
          echo: 'E'
          foxtrot: 'F'
          golf: 'G'
          hotel: 'H'
        YAML

        formatted = format_ast(ast)
        expect(formatted.to_yaml).to eq(result.to_yaml)
      end

      it 'should sort keys recursively' do
        ast = parse_yaml(<<-YAML)
        en:
          alfa: 'A'
          bravo:
            delta: 'D'
            charlie: 'C'
            echo:
              foxtrot: 'F'
              hotel: 'H'
              golf: 'G'
        YAML
        result = parse_yaml(<<-YAML)
        en:
          alfa: 'A'
          bravo:
            charlie: 'C'
            delta: 'D'
            echo:
              foxtrot: 'F'
              golf: 'G'
              hotel: 'H'
        YAML

        formatted = format_ast(ast)
        expect(formatted.to_yaml).to eq(result.to_yaml)
      end

      it 'should move mappings to the bottom' do
        ast = parse_yaml(<<-YAML)
        en:
          alfa: 'A'
          bravo: 'B'
          charlie:
            - 'one'
            - 'two'
          delta: 'D'
          echo: 'E'
          foxtrot:
            bar: 'bar'
            foo: 'foo'
          golf: 'G'
          hotel:
            baz: 'baz'
        YAML
        result = parse_yaml(<<-YAML)
        en:
          alfa: 'A'
          bravo: 'B'
          charlie:
            - 'one'
            - 'two'
          delta: 'D'
          echo: 'E'
          golf: 'G'
          foxtrot:
            bar: 'bar'
            foo: 'foo'
          hotel:
            baz: 'baz'
        YAML

        formatted = format_ast(ast)
        expect(formatted.to_yaml).to eq(result.to_yaml)
      end

      it 'should move anchors before the mappings' do
        ast = parse_yaml(<<-YAML)
        en:
          alfa: 'A'
          xxx: &xxx
            echo: 'E'
            golf: 'G'
          charlie:
            <<: *xxx
            a: 123
          bravo: 'B'
          delta: 'D'
        YAML
        result = parse_yaml(<<-YAML)
        en:
          alfa: 'A'
          bravo: 'B'
          delta: 'D'
          xxx: &xxx
            echo: 'E'
            golf: 'G'
          charlie:
            <<: *xxx
            a: 123
        YAML

        formatted = format_ast(ast)
        expect(formatted.to_yaml).to eq(result.to_yaml)
      end
    end
  end
end
