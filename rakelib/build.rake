# rakelib/build.rake

require 'fileutils'
require './lib/rawww'

namespace :site do
  COMPILER = Rawww::Pandoc
  TEMPLATES_DIR = 'src/templates'

  # We wrap targets into a dynamic helper method to prevent early evaluation during Rake load phase
  def self.targets_map
    site = Rawww::SiteModel.new('src')
    site.pages.each_with_object({}) do |page, hash|
      hash[page.destination_path] = page
    end
  end

  desc "Compile all Markdown pages into production HTML website"
  task :compile => 'manifest:sync' do
    # 1. Evaluate the pages map FRESH, after manifest:sync has completed its execution
    pages_map = targets_map
    
    # 2. Iterate through the dynamically discovered pages and compile them
    pages_map.each do |destination_path, page|
      layout_name = page.metadata[:layout] || 'default'
      template_path = File.join(TEMPLATES_DIR, "#{layout_name}.html")

      # Track timestamps manually to preserve Rake's incremental build speed
      # Rebuild only if target is missing, or if source/template are newer
      should_rebuild = !File.exist?(destination_path) || 
                       File.mtime(page.source_path) > File.mtime(destination_path) ||
                       File.mtime(template_path) > File.mtime(destination_path)

      if should_rebuild
        FileUtils.mkdir_p(File.dirname(destination_path))

        config = Rawww::Config.instance
        current_root = ENV['RAWWW_PRODUCTION'] == 'true' ? config.production_root_path : config.root_path

        base_domain = config.site_url.chomp('/')
        page_path = page.slug == 'index' ? "#{current_root}/" : "#{current_root}/#{page.slug}.html"
        calculated_canonical = "#{base_domain}#{page_path}"

        COMPILER.call(
          source: page.source_path,
          template: template_path,
          destination: destination_path,
          variables: page.metadata.merge(
            'root_path' => current_root,
            'canonical_url' => calculated_canonical,
            'site_title' => config.title,
            'author' => config.author
          )
        )
        puts "  » compile: #{page.source_path} -> /#{page.slug}.html [layout: #{layout_name}]"
      end
    end
  end

  desc "Clean compiled site pages"
  task :clean do
    # Dynamically find files to clean safely
    targets_map.keys.each do |file|
      if File.exist?(file)
        File.delete(file)
        puts "  » deleted: #{file}"
      end
    end
  end
end

# Reset top-level build chain pipelines
task :build => ['assets:copy', 'site:compile', 'seo:generate']
task :clean => ['site:clean', 'manifest:clean', 'assets:clean', 'seo:clean']
