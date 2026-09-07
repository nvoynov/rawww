require 'pathname'
require 'rake/clean'
require_relative 'context'

# rake clean
CLEAN.include(
  File.join(WWW, 'sitemap.xml'),
  File.join(WWW, 'robots.txt'),
  File.join(WWW, 'cachemap.json'),
  File.join(WWW, 'sw.js'),
  SiteModel.new.pages.map(&:destination_path)
)

# rake clobber
CLOBBER.include(WWW)

# BIG BUILD RAKE
namespace :site do

######## Copy/Compile Assets

  RAW_ASSETS = File.join(RAW, 'assets')
  WWW_ASSETS = File.join(WWW, 'assets')

  STYLE_ASSETS = FileList[File.join(RAW_ASSETS, '**/*.css')]
  WWW_CSS_DIR  = File.join(WWW_ASSETS, 'css')  
  WWW_JS_DIR   = File.join(WWW_ASSETS, 'js')
  WWW_STYLE    = File.join(WWW_CSS_DIR, 'style.css')
  ASSET_FILES  = FileList[File.join(RAW_ASSETS, '**/*.*')].reject{ File.directory?(_1) }
  WWW_OTHERS   = (ASSET_FILES - STYLE_ASSETS).pathmap("%{^#{RAW}/,#{WWW}/}p")

  directory WWW_ASSETS
  directory WWW_JS_DIR
  directory WWW_CSS_DIR

  file WWW_STYLE => [WWW_ASSETS, WWW_CSS_DIR, *STYLE_ASSETS] do
    StyleTask.call
    puts "  » assets: compiled #{WWW_STYLE}"
  end

  # just copy other than styles
  rule(%r{^#{WWW_ASSETS}/(?!css/|.+/css/).+$}) do |t|
    source = t.name.sub(/^#{WWW_ASSETS}/, RAW_ASSETS)
    File.dirname(t.name).then{ mkdir_p it unless Dir.exist?(it) }
    cp source, t.name, verbose: false
    puts "  » assets: copied #{source} -> #{t.name}"
  end

  desc 'Copy assets'
  task :assets => ([WWW_STYLE] + WWW_OTHERS) #  [WWW_STYLE, *WWW_OTHERS.to_a]

######## Compile Markdown pages

  COMPILER = PageTask.new

  PAGES = SiteModel.new.pages
    .map{ [_1.destination_path, _1.source_path] }
    .to_h
  
  # NOTE: this fits the situattion when all pages prepared beforehed
  #   When you generate pages depend on site_root, you need to change
  #   it for straight approach Site.new.pages.each{ COMPILER.call(it) }
  desc 'Compile markdown pages'
  task :pages => PAGES.keys

  rule ".html" => ->(f){ PAGES[f] } do |t|
    COMPILER.(t.source)
    puts "  » pages: compiled #{t.source} -> #{t.name}"
  end

######## Site index files

  # Исправлена опечатка в stie_url -> site_url
  URL = CONFIG.site_url 
  SITEMAP = File.join(WWW, 'sitemap.xml')

  desc "Build sitemap.xml"
  file SITEMAP => PAGES.keys do |t|
    SitemapTask.call
    puts "  » index: dump /#{t.name}"
  end

  ROBOTS = File.join(WWW, 'robots.txt')

  desc "Build robots.txt"
  file ROBOTS do |t|
    content = <<~TEXT
      # robots.txt for rawww static engine
      User-agent: *
      Allow: /

      Sitemap: #{URL}/sitemap.xml
    TEXT

    File.write(t.name, content)
    puts "  » index: dump /#{t.name}"
  end

  CACHEMAP = File.join(WWW, 'cachemap.json')
  desc "Build cachemap.json"
  file CACHEMAP do |t|
    CachemapTask.call
    puts "  » index: dump /#{t.name}"
  end

  RAW_SERVICE = File.join(RAW, 'sw.js')
  SERVICE = File.join(WWW, 'sw.js')
  
  desc "Copy sw.js"
  file SERVICE do
    cp RAW_SERVICE, SERVICE, verbose: false
    puts "  » index: copy /#{SERVICE}"
  end

  desc 'Build site index'
  task :index => [SITEMAP, ROBOTS, CACHEMAP, SERVICE]
end

desc "Build site"
task :build => %w[ site:assets site:pages site:index ]
