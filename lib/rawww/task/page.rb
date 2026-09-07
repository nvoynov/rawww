require_relative 'base'
require_relative '../pandoc'
require 'fileutils'

module Rawww
  module Task
  
    # Page compiler
    class Page < Base
      TEMPLATES = 'templates'
      
      def initialize
        @compiler = Pandoc.new
        @templates = File.join(config.raw, TEMPLATES)
      end
      
      # @param page [PageModel]
      # @oaram extra_arguments [Array<String>]
      def call(filepath, extra_arguments: [])
        page = PageModel.new(filepath)
        layout = page.metadata[:layout] || 'default'
        template = File.join(@templates, layout + '.html')
        FileUtils.mkdir_p File.dirname(page.destination_path)
        
        @compiler.call(
          source: page.source_path,
          destination: page.destination_path,
          template:,
          variables: page.metadata.merge(
            'root_path' => config.site_root,
            'canonical_url' => canonical_url(page),
            'site_title' => config.title,
            'author' => config.author
          ),
          extra_arguments:
        )
      end

      private

      def canonical_url(page)
        index = config.site_url.chomp('/') + config.site_root
        return index if page.slug == 'index'

        index + page.destination_path.sub(%r{^#{config.www}/}, '')
      end 
    end
  end
end
