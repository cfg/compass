require 'fileutils'
require 'pathname'
require 'sass/importers/filesystem'

module Compass
  class PublicImporter < Sass::Importers::Filesystem
    attr_accessor :working_path, :options, :name

    include Actions

    def initialize(root, options = {})
      @http_sass_path = options.fetch(:http_sass_path, Compass.configuration.http_sass_path)
      @sass_path = File.expand_path(options.fetch(:sass_path, Compass.configuration.sass_path))
      @name = options.fetch(:name, nil)
      @working_path = options.fetch(:working_path, Compass.configuration.project_path)
      @options = options
      super(root)
    end

    def public_url(uri)
      "#{@http_sass_path}/#{relative_uri(uri)}"
    end

    def write_public_source(uri)
        ensure_source_written!(uri, public_path(uri)) unless uri.index(@sass_path) == 0
    end

    private

    def public_path(uri)
        public_sass_path = @sass_path
        public_sass_path = File.join(@sass_path, @name) if @name
        subdir = File.dirname(File.join(public_sass_path, Compass::Util.relative_path_from_strings(uri, root)))
        File.join(subdir, File.basename(uri))
    end

    def relative_uri(uri)
      if uri.index(@sass_path) == 0
        uri[(@sass_path.length + 1)..-1]
      else
        Compass::Util.relative_path_from_strings(public_path(uri), @sass_path)
      end
    end

    def ensure_source_written!(uri, to)
      directory(File.dirname(to))
      (@@copied ||= {})[to] ||= copy(uri, to, {:quiet => true, :loud => [:create]})
    end
  end
end
