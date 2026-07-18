require 'fileutils'
require './lib/rawww'

namespace :assets do
  # Standard asset tracks setup
  ASSET_SOURCES = FileList['src/assets/**/*'].reject { |f| File.directory?(f) }
  ASSET_TARGETS = ASSET_SOURCES.pathmap("%{^src/,#{Rawww::PUBLIC_DIR}/}p")

  # Add root favicon tracking to targets pool
  FAVICON_SRC = 'src/favicon.svg'
  FAVICON_TRG = File.join(Rawww::PUBLIC_DIR, 'favicon.svg')

  desc "Copy static assets (CSS, JS, images, favicon) to the build directory"
  task :copy => (ASSET_TARGETS + [FAVICON_TRG])

  # Rule for standard modular assets mapping
  rule(%r{^#{Rawww::PUBLIC_DIR}/assets/}) do |t|
    source = t.name.sub(/^#{Rawww::PUBLIC_DIR}/, 'src')
    FileUtils.mkdir_p(File.dirname(t.name))
    FileUtils.cp(source, t.name)
    puts "  » copy: #{source} -> #{t.name}"
  end

  # Dedicated rule for transferring the root identity favicon vector
  file FAVICON_TRG => FAVICON_SRC do |t|
    FileUtils.mkdir_p(File.dirname(t.name))
    FileUtils.cp(t.source, t.name)
    puts "  » copy: #{t.source} -> #{t.name} [root branding]"
  end
  
  # Add root OG Card tracking to targets pool
  OG_SRC = 'src/og-card.png'
  OG_TRG = File.join(Rawww::PUBLIC_DIR, 'og-card.png')

  # Dedicated rule for transferring the root Open Graph social banner
  file OG_TRG => OG_SRC do |t|
    FileUtils.mkdir_p(File.dirname(t.name))
    FileUtils.cp(t.source, t.name)
    puts "  » copy: #{t.source} -> #{t.name} [social branding]"
  end

  # Update the main copy task dependencies
  desc "Copy static assets (CSS, JS, images, favicon, og-card) to the build directory"
  task :copy => (ASSET_TARGETS + [FAVICON_TRG, OG_TRG])

  desc "Clean compiled assets"
  task :clean do
    target_dir = File.join(Rawww::PUBLIC_DIR, 'assets')
    FileUtils.rm_rf(target_dir) if Dir.exist?(target_dir)
    File.delete(FAVICON_TRG) if File.exist?(FAVICON_TRG)
    File.delete(OG_TRG) if File.exist?(OG_TRG)
    puts "  » cleaned: assets and branding nodes"
  end
end

# Hook asset automation securely with your fixed site compilation call
task :build => 'assets:copy'
task :clean => 'assets:clean'
