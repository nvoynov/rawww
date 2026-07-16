# rakelib/deploy.rake

require 'fileutils'
require './lib/rawww'

namespace :site do

  desc "Deploy the compiled website to GitHub Pages"
  task :push => :build do
    puts Rawww::BANNER
    puts "  » Preparing deployment to GitHub Pages..."

    # Automatically detect the current remote git origin URL
    remote_url = `git config --get remote.origin.url`.strip
    
    if remote_url.empty?
      puts "  [Error] No remote git origin found. Please run 'git remote add origin <url>' first."
      exit 1
    end

    unless Dir.exist?(Rawww::PUBLIC_DIR)
      puts "  [Error] Target build directory '#{Rawww::PUBLIC_DIR}' does not exist. Run rake build first."
      exit 1
    end

    # Navigate into the compiled output directory
    Dir.chdir(Rawww::PUBLIC_DIR) do
      puts "  » Initializing temporary deployment repository..."
      system("git init -b gh-pages")
      system("git config user.name 'rawww-bot'")
      system("git config user.email 'rawww-bot@local.internal'")
      
      puts "  » Staging compiled production nodes..."
      system("git add .")
      
      puts "  » Committing frozen raw production state..."
      system("git commit -m 'Automated rawww production deployment close'")
      
      puts "  » Executing force push sequence to remote gh-pages branch..."
      # Perform a safe force push sequence to update the live website node
      success = system("git push --force #{remote_url} gh-pages")

      if success
        puts "  ─────────────────────────────────"
        puts "  » Deployment successful! Your raw node is live."
      else
        puts "  [Error] Push sequence failed. Verify your repository write permissions."
      end
    end

    # Clean up the hidden temporary .git metadata directory inside /www to avoid pollution
    git_cache = File.join(Rawww::PUBLIC_DIR, '.git')
    FileUtils.rm_rf(git_cache) if Dir.exist?(git_cache)
  end
end

# Expose a clean, punchy top-level shortcut task
desc "Deploy compiled site to GitHub Pages"
task :push => 'site:push'
