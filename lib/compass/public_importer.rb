require 'fileutils'
require 'sass/importers/filesystem'

module Compass
  class PublicImporter < Sass::Importers::Filesystem
    def initialize(root, options = {})
      @http_sass_path = options.fetch(:http_sass_path, Compass.configuration.http_sass_path)
      @sass_path = File.expand_path(options.fetch(:sass_path, Compass.configuration.sass_path))
      super(root)
    end

    def public_url(uri)
      "#{@http_sass_path}/#{relative_uri(uri)}"
    end

    protected

    def relative_uri(uri)
      if uri.index(@sass_path) == 0
        uri[(@sass_path.length + 1)..-1]
      else
        FileUtils.mkdir_p(@sass_path)
        FileUtils.cp(uri, @sass_path)
        File.basename(uri)
      end
    end
  end
end
