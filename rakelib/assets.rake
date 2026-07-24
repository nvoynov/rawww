# rakelib/assets.rake
require 'fileutils'
require './lib/rawww'

namespace :assets do
  # Capture all static files EXCEPT anything inside the assets/css/ directory structure
  ASSET_SOURCES = FileList['src/assets/**/*']
    .reject { |f| File.directory?(f) }
    .reject { |f| f.start_with?('src/assets/css/') } # Exclude raw CSS assets pipeline completely

  ASSET_TARGETS = ASSET_SOURCES.pathmap("%{^src/,#{Rawww::PUBLIC_DIR}/}p")

  # Rule for standard modular assets mapping (images, scripts, branding, favicons)
  rule(%r{^#{Rawww::PUBLIC_DIR}/assets/}) do |t|
    source = t.name.sub(/^#{Rawww::PUBLIC_DIR}/, 'src')
    FileUtils.mkdir_p(File.dirname(t.name))
    FileUtils.cp(source, t.name)
    puts "  » copy: #{source} -> #{t.name}"
  end

  # Update the main copy task dependencies
  desc "Copy static assets (JS, images, favicon, og-card) to the build directory"
  task :copy => ASSET_TARGETS

  desc "Clean compiled assets and branding nodes"
  task :clean => 'css:clean' do
    # Target path pointing to the compiled distribution assets root directory context
    target_assets_dir = File.join(Rawww::PUBLIC_DIR, 'assets')
    
    # We cleanly prune the directory, but leave other parts handled by explicit clean triggers
    if Dir.exist?(target_assets_dir)
      # Iterate and delete static items, skipping target folder structures if they are managed standalone
      FileUtils.rm_rf(target_assets_dir)
      puts "  » cleaned: static assets and branding nodes"
    end
  end
end

# Hook asset automation securely with your fixed site compilation call
task :build => 'assets:copy'
task :clean => 'assets:clean'
