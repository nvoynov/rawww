# rakelib/deploy.rake

require 'fileutils'
require './lib/rawww'

namespace :site do
  desc "Deploy the compiled website to GitHub Pages"
  task :push do
    puts Rawww::BANNER
    puts "  » Launching production deployment execution phase..."

    # Extract single source of truth path from our Data config instance
    public_dir = Rawww::Config.instance.public_dir rescue 'www'
    remote_url = `git config --get remote.origin.url`.strip rescue ''
    
    if remote_url.empty?
      puts "  [Error] No remote git origin found. Please run 'git remote add origin <url>' first."
      exit 1
    end

    unless Dir.exist?(public_dir)
      puts "  [Error] Target build directory '#{public_dir}' does not exist."
      exit 1
    end

    # Navigate into the compiled output directory
    Dir.chdir(public_dir) do
      puts "  » Initializing temporary deployment repository..."
      system("git init -b gh-pages")
      system("git config user.name 'rawww-bot'")
      system("git config user.email 'rawww-bot@local.internal'")
      
      puts "  » Staging compiled production nodes..."
      system("git add .")
      
      puts "  » Committing frozen raw production state..."
      system("git commit -m 'Automated rawww production deployment close'")
      
      puts "  » Executing force push sequence to remote gh-pages branch..."
      success = system("git push --force #{remote_url} gh-pages")

      if success
        puts "  ─────────────────────────────────"
        puts "  » Deployment successful! Your raw node is live."
      else
        puts "  [Error] Push sequence failed. Verify your repository write permissions."
      end
    end

    # Clean up the hidden temporary .git metadata directory inside public path
    git_cache = File.join(public_dir, '.git')
    FileUtils.rm_rf(git_cache) if Dir.exist?(git_cache)
  end
end

# Intercept the global shortcut call
task :push do
  # 1. Lock the environment into production state
  ENV['RAWWW_PRODUCTION'] = 'true'
  puts "  » Production environment state locked."
  
  # 2. FORCE CLEAN the directory to break Rake timestamp cache mechanism
  puts "  » Flushing local compilation caches..."
  Rake::Task['clean'].invoke
  
  # 3. Trigger a completely fresh, clean production build execution
  puts "  » Triggering fresh production build..."
  Rake::Task['build'].invoke
  
  # 4. Invoke the real deploy mechanism
  Rake::Task['site:push'].invoke
end
