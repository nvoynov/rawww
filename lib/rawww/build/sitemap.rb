require_relative 'base'

module Rawww
  module Build

    # Sitemap.xml Builder
    class Sitemap < Base

      # @param site [Model::Site]
      # @return [String] sitemap xml content
      def call(site)
        xml_content = []
        xml_content << '<?xml version="1.0" encoding="UTF-8"?>'
        xml_content << '<urlset xmlns="http://sitemaps.org">'

        site.pages.each do |page|
          # Handle special mapping for the main index page
          page_url = page.slug == "index" ? "#{config.site_url}/" : "#{config.site_url}/#{page.slug}.html"
      
          xml_content << '  <url>'
          xml_content << "    <loc>#{page_url}</loc>"
          xml_content << "    <lastmod>#{page.date.strftime('%Y-%m-%d')}</lastmod>"
          xml_content << "    <changefreq>#{page.change_frequency}</changefreq>"
          xml_content << '  </url>'
        end

        xml_content << '</urlset>'
        xml_content.join("\n")
      end
    end    
  end
end
