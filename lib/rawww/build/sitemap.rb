require_relative 'base'

module Rawww
  module Build

    # Sitemap.xml Builder
    class Sitemap < Base

      # @param site [Model::Site]
      # @return [String] sitemap xml content
      def call(site)

        base_domain = config.site_url.chomp('/')
        
        xml_content = []
        xml_content << '<?xml version="1.0" encoding="UTF-8"?>'
        xml_content << '<urlset xmlns="http://sitemaps.org">'

        site.pages.each do |page|
          page_path = "#{config.site_root}/"
          destination_path = page.destination_path
          page_path << "#{destination_path.gsub(%r{#{Rawww::PUBLIC_DIR}/}, '')}" \
            if page.slug != 'index'
          calculated_canonical = "#{base_domain}#{page_path}"
          
          xml_content << '  <url>'
          xml_content << "    <loc>#{calculated_canonical}</loc>"
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
