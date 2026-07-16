# rakelib/seo.rake

require 'fileutils'
require './lib/rawww'

namespace :seo do
  # Define your production root domain here
  SITE_URL = "https://your-domain.com"

  desc "Generate production sitemap.xml and robots.txt rules"
  task :generate => 'site:compile' do
    site = Rawww::SiteModel.new('src')
    sitemap_path = File.join(Rawww::PUBLIC_DIR, "sitemap.xml")
    robots_path = File.join(Rawww::PUBLIC_DIR, "robots.txt")

    puts "  » Generating SEO search index nodes..."

    # 1. Build the sitemap.xml structure
    xml_content = []
    xml_content << '<?xml version="1.0" encoding="UTF-8"?>'
    xml_content << '<urlset xmlns="http://sitemaps.org">'

    site.pages.each do |page|
      # Handle special mapping for the main index page
      page_url = page.slug == "index" ? "#{SITE_URL}/" : "#{SITE_URL}/#{page.slug}.html"
      
      xml_content << '  <url>'
      xml_content << "    <loc>#{page_url}</loc>"
      xml_content << "    <lastmod>#{page.date.strftime('%Y-%m-%d')}</lastmod>"
      xml_content << "    <changefreq>#{page.change_frequency}</changefreq>"
      xml_content << '  </url>'
    end

    xml_content << '</urlset>'

    # Save sitemap file securely
    FileUtils.mkdir_p(Rawww::PUBLIC_DIR)
    File.write(sitemap_path, xml_content.join("\n"))
    puts "  » generated: /sitemap.xml [#{site.pages.size} pages linked]"

    # 2. Build the robots.txt structure pointing to the sitemap
    robots_content = <<~TEXT
      # robots.txt for rawww static engine
      User-agent: *
      Allow: /

      Sitemap: #{SITE_URL}/sitemap.xml
    TEXT

    File.write(robots_path, robots_content)
    puts "  » generated: /robots.txt"
  end

  desc "Clean compiled SEO nodes"
  task :clean do
    ["sitemap.xml", "robots.txt"].each do |file|
      target = File.join(Rawww::PUBLIC_DIR, file)
      if File.exist?(target)
        File.delete(target)
        puts "  » deleted: #{target}"
      end
    end
  end
end

# Automatically hook SEO tasks into the global workflow
task :build => 'seo:generate'
task :clean => 'seo:clean'
