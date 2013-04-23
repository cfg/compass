require 'fileutils'
require 'pathname'
require 'sass/importers/filesystem'

module Compass
  class NamedPathname < Pathname
    attr_accessor :name

    def initialize(path, name)
      @name = name
      super(path)
    end
  end

  class PublicImporter < Sass::Importers::Filesystem
    def initialize(root, options = {})
      @http_sass_path = options.fetch(:http_sass_path, Compass.configuration.http_sass_path)
      @sass_path = File.expand_path(options.fetch(:sass_path, Compass.configuration.sass_path))
      @name = options.fetch(:name, nil)
      super(root)
    end

    def public_url(uri)
      "#{@http_sass_path}/#{relative_uri(uri)}"
    end

    def relative_uri(uri)
      if uri.index(@sass_path) == 0
        uri[(@sass_path.length + 1)..-1]
      else
        public_sass_path = @sass_path
        public_sass_path = File.join(@sass_path, @name) if @name
        subdir = File.dirname(File.join(public_sass_path, relative_path_from_strings(uri, root)))
        FileUtils.mkdir_p(subdir)
        FileUtils.cp(uri, subdir)
        relative_path_from_strings(File.join(subdir,File.basename(uri)), @sass_path)
      end
    end

    private

    def relative_path_from_strings(from, to)
      Pathname.new(from).relative_path_from(Pathname.new(to)).to_s
    end
  end
end
