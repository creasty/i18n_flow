require 'i18n_flow/util'

describe I18nFlow::Util do
  describe '.extract_args' do
    it 'should extract translation arguments' do
      {
        ''                          => %w[],
        'foo'                       => %w[],
        '%{arg_1}'                  => %w[arg_1],
        'foo %{arg_1}'              => %w[arg_1],
        'foo %{arg_1} bar %{arg_2}' => %w[arg_1 arg_2],
        'foo %{arg_2} bar %{arg_1}' => %w[arg_1 arg_2],
        '%{arg_1}%{arg_2}'          => %w[arg_1 arg_2],
        '%{arg_1}%%{arg_2}'         => %w[arg_1],
        '%%{arg_1} bar %%%{arg_2}'  => %w[arg_2],
      }.each do |input, output|
        expect(I18nFlow::Util.extract_args(input)).to eq(output)
      end
    end
  end

  describe '.filepath_to_scope' do
    it 'should parse file path into locale and scopes' do
      {
        'en.yml'                 => %w[en],
        'foo.en.yml'             => %w[en foo],
        'foo/bar/en.yml'         => %w[en foo bar],
        'foo/bar/baz.en.yml'     => %w[en foo bar baz],
        'foo/bar/baz.bax.en.yml' => %w[en foo bar baz bax],
      }.each do |input, output|
        expect(I18nFlow::Util.filepath_to_scope(input)).to eq(output)
      end
    end
  end

  describe '.scope_to_filepath' do
    it 'should build file path from scopes' do
      {
        %w[en]                 => 'en.yml',
        %w[en foo]             => 'foo.en.yml',
        %w[en foo bar]         => 'foo/bar/en.yml',
        %w[en foo bar baz]     => 'foo/bar/baz.en.yml',
        %w[en foo bar baz bax] => 'foo/bar/baz.bax.en.yml',
      }.each do |input, output|
        expect(I18nFlow::Util.scope_to_filepath(input)).to eq(output)
      end
    end
  end
end
