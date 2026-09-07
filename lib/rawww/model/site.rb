# lib/rawww/models/site.rb

require_relative '../config'
require_relative 'page'

module Rawww
  module Model
    # Represents the entire website content structure.
    # Scans the source directory and aggregates individual Page models.
    class Site
      attr_reader :pages

      def initialize
        ptrn = File.join(Config.instance.raw, '**/*.md')
        @pages = Dir.glob(ptrn).map{ Page.new(it) }
      end

      # Helper method to find a specific page by its source path.
      # Utilizes Ruby 3.4 implicit 'it' block parameter for strict matching.
      # @param source_path [String] e.g., 'src/index.md'
      # @return [Rawww::PageModel, nil] matching page instance or nil
      def find_page(source_path)
        pages.find { it.source_path == source_path }
      end
    end
  end
end
