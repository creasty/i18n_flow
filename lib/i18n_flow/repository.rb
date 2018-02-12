require 'pathname'

class I18nFlow::Repository
  def initialize(
    base_path:,
    glob_patterns:
  )
    @base_path     = Pathname.new(base_path)
    @glob_patterns = glob_patterns.to_a
  end

  def file_paths
    @file_paths ||= @glob_patterns
      .flat_map { |pattern| Dir.glob(@base_path.join(pattern)) }
  end

  def asts_by_path
    @asts ||= file_paths
      .map { |path|
        rel_path = Pathname.new(path).relative_path_from(@base_path).to_s
        parser = I18nFlow::Parser.new(File.read(path), file_path: rel_path)
        parser.parse!
        [rel_path, parser.root_proxy]
      }
      .to_h
  end

  def asts_by_scope
    @asts_by_scope ||= Hash.new { |h, k| h[k] = {} }
      .tap { |h|
        asts_by_path.each { |path, tree|
          locale, *scopes = I18nFlow::Util.filepath_to_scope(path)
          h[scopes.join('.')][locale] = tree
        }
      }
  end
end
