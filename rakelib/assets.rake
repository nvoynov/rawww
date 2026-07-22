require 'fileutils'
require './lib/rawww'

namespace :assets do
  # Standard asset tracks setup
  ASSET_SOURCES = FileList['src/assets/**/*'].reject { |f| File.directory?(f) }
  ASSET_TARGETS = ASSET_SOURCES.pathmap("%{^src/,#{Rawww::PUBLIC_DIR}/}p")

  # Rule for standard modular assets mapping
  rule(%r{^#{Rawww::PUBLIC_DIR}/assets/}) do |t|
    source = t.name.sub(/^#{Rawww::PUBLIC_DIR}/, 'src')
    FileUtils.mkdir_p(File.dirname(t.name))
    FileUtils.cp(source, t.name)
    puts "  » copy: #{source} -> #{t.name}"
  end

  # Update the main copy task dependencies
  desc "Copy static assets (CSS, JS, images, favicon, og-card) to the build directory"
  task :copy => ASSET_TARGETS

  desc "Clean compiled assets"
  task :clean do
    target_dir = File.join(Rawww::PUBLIC_DIR, 'assets')
    FileUtils.rm_rf(target_dir) if Dir.exist?(target_dir)
    puts "  » cleaned: assets and branding nodes"
  end
end

# Hook asset automation securely with your fixed site compilation call
task :build => 'assets:copy'
task :clean => 'assets:clean'
