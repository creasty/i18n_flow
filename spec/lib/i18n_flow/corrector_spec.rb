require 'i18n_flow/corrector'

describe I18nFlow::Corrector do
  def correct_ast(ast_1, ast_2 = nil)
    I18nFlow::Corrector.new(ast_1, ast_2)
      .tap(&:correct!)
  end

  describe '#correct!' do
    it 'should complement missing keys and mark as !todo' do
      ast_1 = parse_yaml(<<-YAML)
      es:
        alfa: 'a'
        delta: 'd'
        echo: 'e'
        golf: 'g'
        hotel: 'h'
      YAML
      ast_2 = parse_yaml(<<-YAML)
      en:
        alfa: 'A'
        bravo: 'B'
        charlie: 'C'
        delta: 'D'
        echo: 'E'
        foxtrot: !only 'F'
        golf: 'G'
        hotel: 'H'
      YAML
      result = parse_yaml(<<-YAML)
      es:
        alfa: 'a'
        delta: 'd'
        echo: 'e'
        golf: 'g'
        hotel: 'h'
        bravo: !todo 'B'
        charlie: !todo 'C'
      YAML

      corrected = correct_ast(ast_1, ast_2)
      expect(corrected.ast_1.to_yaml).to eq(result.to_yaml)
    end

    it 'should complement missing elements in a sequence' do
      ast_1 = parse_yaml(<<-YAML)
      es:
        foo:
          - 'one'
          - 'two'
      YAML
      ast_2 = parse_yaml(<<-YAML)
      en:
        foo:
          - 'ONE'
          - 'TWO'
          - 'THREE'
          - !only 'FOUR'
      YAML
      result = parse_yaml(<<-YAML)
      es:
        foo:
          - 'one'
          - 'two'
          - !todo 'THREE'
      YAML

      corrected = correct_ast(ast_1, ast_2)
      expect(corrected.ast_1.to_yaml).to eq(result.to_yaml)
    end

    it 'should delete extra keys which are not marked as !only' do
      ast_1 = parse_yaml(<<-YAML)
      es:
        alfa: 'a'
        bravo: 'b'
        charlie: 'c'
        delta: 'd'
        echo: 'e'
        foxtrot: !only 'f'
        golf: 'g'
        hotel: 'h'
      YAML
      ast_2 = parse_yaml(<<-YAML)
      en:
        alfa: 'A'
        bravo: 'B'
        charlie: 'C'
        golf: 'G'
        hotel: 'H'
      YAML
      result = parse_yaml(<<-YAML)
      es:
        alfa: 'a'
        bravo: 'b'
        charlie: 'c'
        foxtrot: !only 'f'
        golf: 'g'
        hotel: 'h'
      YAML

      corrected = correct_ast(ast_1, ast_2)
      expect(corrected.ast_1.to_yaml).to eq(result.to_yaml)
    end

    it 'should delete extra elements in a sequence' do
      ast_1 = parse_yaml(<<-YAML)
      es:
        foo:
          - 'one'
          - 'two'
          - 'three'
          - !only 'four'
      YAML
      ast_2 = parse_yaml(<<-YAML)
      en:
        foo:
          - 'ONE'
          - 'TWO'
      YAML
      result = parse_yaml(<<-YAML)
      es:
        foo:
          - 'one'
          - 'two'
          - !only 'four'
      YAML

      corrected = correct_ast(ast_1, ast_2)
      expect(corrected.ast_1.to_yaml).to eq(result.to_yaml)
    end

    it 'should update translations with !todo according to the source' do
      ast_1 = parse_yaml(<<-YAML)
      es:
        foo: !todo 'outdated'
      YAML
      ast_2 = parse_yaml(<<-YAML)
      en:
        foo: 'latest'
      YAML
      result = parse_yaml(<<-YAML)
      es:
        foo: !todo 'latest'
      YAML

      corrected = correct_ast(ast_1, ast_2)
      expect(corrected.ast_1.to_yaml).to eq(result.to_yaml)
    end

    it 'should update translations with !todo (works bidirectionally)' do
      ast_1 = parse_yaml(<<-YAML)
      es:
        foo: 'latest'
      YAML
      ast_2 = parse_yaml(<<-YAML)
      en:
        foo: !todo 'outdated'
      YAML
      result_1 = parse_yaml(<<-YAML)
      es:
        foo: 'latest'
      YAML
      result_2 = parse_yaml(<<-YAML)
      en:
        foo: !todo 'latest'
      YAML

      corrected = correct_ast(ast_1, ast_2)
      expect(corrected.ast_1.to_yaml).to eq(result_1.to_yaml)
      expect(corrected.ast_2.to_yaml).to eq(result_2.to_yaml)
    end

    it 'should update translations with !todo (synchronize)' do
      ast_1 = parse_yaml(<<-YAML)
      es:
        foo: !todo 'outdated'
      YAML
      ast_2 = parse_yaml(<<-YAML)
      en:
        foo: !todo 'latest'
      YAML
      result_1 = parse_yaml(<<-YAML)
      es:
        foo: !todo 'latest'
      YAML
      result_2 = parse_yaml(<<-YAML)
      en:
        foo: !todo 'latest'
      YAML

      corrected = correct_ast(ast_1, ast_2)
      expect(corrected.ast_1.to_yaml).to eq(result_1.to_yaml)
      expect(corrected.ast_2.to_yaml).to eq(result_2.to_yaml)
    end
  end
end
