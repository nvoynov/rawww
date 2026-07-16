# lib/rawww/models/site.rb

module Rawww
  module Model
    # Represents the entire website content structure.
    # Scans the source directory and aggregates individual Page models.
    class Site
      attr_reader :source_dir

      # @param source_dir [String] the root path containing raw markdown content
      def initialize(source_dir = 'src')
        @source_dir = source_dir
      end

      # Scans the directory and maps every Markdown file to a PageModel instance.
      # Utilizes Ruby 3.4 implicit 'it' block parameter for clean transformation.
      # @return [Array<Rawww::PageModel>] collection of site pages
      def pages
        @pages ||= Dir
          .glob(File.join(@source_dir, '**/*.md'))
          .map{ Rawww::PageModel.new(it) }
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
