# rakelib/seo.rake

require 'fileutils'
require './lib/rawww'

namespace :seo do
  # Define your production root domain here
  SITE_URL = Rawww::Config.instance.site_url

  desc "Generate production sitemap.xml and robots.txt rules"
  task :generate => 'site:compile' do
    site = Rawww::SiteModel.new('src')
    sitemap_path = File.join(Rawww::PUBLIC_DIR, "sitemap.xml")
    robots_path = File.join(Rawww::PUBLIC_DIR, "robots.txt")

    puts "  » Generating SEO search index nodes..."
    FileUtils.mkdir_p(Rawww::PUBLIC_DIR)
    File.write(sitemap_path, Rawww::BuildSitemap.call(site))
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
