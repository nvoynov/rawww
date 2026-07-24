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

  # Helper method to dry up and orchestrate native Pandoc include-before-body injections
  def compile_pandoc_extra_args(target_src)
    extra_args = []

    # when you need to provide some extra inclusions based on target
    # analytics_part = "#{SRC_DIR}/templates/analytics_fragment.html"
    # extra_args << "--include-before-body=#{analytics_part}" \
    #   if File.exist?(analytics_part)
    extra_args
  end

  desc "Compile all Markdown pages into production HTML website"
  task :compile => 'manifest:sync' do
    # 1. Evaluate the pages map FRESH, after manifest:sync has completed its execution
    pages_map = targets_map
    config = Rawww::Config.instance
    
    # 2. Iterate through the dynamically discovered pages and compile them
    pages_map.each do |destination_path, page|
      layout_name = page.metadata[:layout] || 'default'
      template_path = File.join(TEMPLATES_DIR, "#{layout_name}.html")

      # Track timestamps manually to preserve Rake's incremental build speed
      # Rebuild only if target is missing, or if source/template are newer
      should_rebuild =
        !File.exist?(destination_path) || 
        File.mtime(page.source_path) > File.mtime(destination_path) ||
        File.mtime(template_path) > File.mtime(destination_path)

      if should_rebuild
        FileUtils.mkdir_p(File.dirname(destination_path))

        base_domain = config.site_url.chomp('/')
        # page_path = page.slug == 'index' ? "#{current_root}/" : "#{current_root}/#{page.slug}.html"
        page_path = "#{config.site_root}/"
        page_path << "#{destination_path.gsub(%r{#{Rawww::PUBLIC_DIR}/}, '')}" \
          if page.slug != 'index'

        calculated_canonical = "#{base_domain}#{page_path}"
        extra_args = compile_pandoc_extra_args(destination_path)

        COMPILER.call(
          source: page.source_path,
          template: template_path,
          destination: destination_path,
          variables: page.metadata.merge(
            'root_path' => config.site_root,
            'canonical_url' => calculated_canonical,
            'site_title' => config.title,
            'author' => config.author
          ),
          extra_arguments: extra_args
        )
        puts "  » compile: #{page.source_path} -> /#{page.slug}.html [layout: #{layout_name}]"
      end
    end
  end

  CACHE_MANIFEST = File.join(Rawww::PUBLIC_DIR, 'cache_manifest.json')
  desc "Build cache-manifest.json"
  file CACHE_MANIFEST do |t|
    raw = Rawww::BuildCacheManifest.()
    File.write(t.name, raw)
    puts "  » cache mainifest: -> #{t.name}"
  end

  SERVICE_WORKER_SRC = File.join('src', 'sw.js')
  SERVICE_WORKER = File.join(Rawww::PUBLIC_DIR, 'sw.js')
  file SERVICE_WORKER do |t|
    FileUtils.cp SERVICE_WORKER_SRC, SERVICE_WORKER
  end

  task :build => [:compile, CACHE_MANIFEST, SERVICE_WORKER]

  desc "Clean compiled site pages"
  task :clean do
    # Dynamically find files to clean safely
    targets = targets_map.keys + [CACHE_MANIFEST, SERVICE_WORKER] 
    targets.each do |file|
      next unless File.exist?(file)

      File.delete(file)
      puts "  » deleted: #{file}"
    end
  end
end

# Reset top-level build chain pipelines
task :build => ['assets:copy', 'site:build',  'seo:generate']
task :clean => ['site:clean', 'manifest:clean', 'assets:clean', 'seo:clean']
