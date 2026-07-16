# rakelib/build.rake

require 'fileutils'
require './lib/rawww'

namespace :site do
  COMPILER = Rawww::Pandoc
  TEMPLATES_DIR = 'src/templates'
  SITE = Rawww::SiteModel.new('src')

  # Optimize lookups by creating a Hash indexed by destination paths (O(1) access)
  PAGES_MAP = SITE.pages.each_with_object({}) do |page, hash|
    hash[page.destination_path] = page
  end

  HTML_TARGETS = PAGES_MAP.keys

  desc "Compile all Markdown pages into production HTML website"
  task :compile => HTML_TARGETS

  rule %r{^www/.*\.html$} => [
    ->(task_name) {
      page = PAGES_MAP[task_name]
      if page
        layout_name = page.metadata[:layout] || 'default'
        template_path = File.join(TEMPLATES_DIR, "#{layout_name}.html")
        [page.source_path, template_path]
      else
        :error
      end
    }
  ] do |t|
    page = PAGES_MAP[t.name]
    next unless page

    layout_name = page.metadata[:layout] || 'default'
    template_path = File.join(TEMPLATES_DIR, "#{layout_name}.html")

    FileUtils.mkdir_p(File.dirname(page.destination_path))

    # Determine the correct root path based on the production environment flag
    # Access parameters safely via the Singleton instance proxy methods
    config = Rawww::Config.instance

    # Determine the correct root path based on the production environment flag
    current_root = ENV['RAWWW_PRODUCTION'] == 'true' ? config.production_root_path : config.root_path

    # Safely construct the absolute canonical URL for search engines
    base_domain = config.site_url.chomp('/')
    page_path = page.slug == 'index' ? "#{current_root}/" : "#{current_root}/#{page.slug}.html"
    calculated_canonical = "#{base_domain}#{page_path}"

    # Pass everything to the compiler, blending page metadata and system variables
    COMPILER.call(
      source: page.source_path,
      template: template_path,
      destination: page.destination_path,
      variables: page.metadata.merge(
        'root_path' => current_root,
        'canonical_url' => calculated_canonical,
        'site_title' => config.title,
        'author' => config.author
      )
    )
    
    # Updated terminal log to explicitly show the beautiful compiled URL slug
    puts "  » compile: #{page.source_path} -> /#{page.slug}.html [layout: #{layout_name}]"
  end

  desc "Clean compiled site pages"
  task :clean do
    HTML_TARGETS.each do |file|
      if File.exist?(file)
        File.delete(file)
        puts "  » deleted: #{file}"
      end
    end
  end
end

task :build => 'site:compile'
task :clean => 'site:clean'
