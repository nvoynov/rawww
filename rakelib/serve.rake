# rakelib/serve.rake
require './lib/rawww'

namespace :server do
  PORT = 8000

  desc "Launch a lightweight local preview server for the compiled website"
  task :run => :build do
    puts Rawww::BANNER
    puts Rawww.environment_info
    puts "  » Starting development server..."
    puts "  » Local URL: http://localhost:#{PORT}"
    puts "  » Press Ctrl+C to stop the engine"
    puts "  ─────────────────────────────────"
    
    # Launch Ruby's built-in light HTTP server pointing to the www directory
    cmd = "ruby -run -e httpd #{Rawww::PUBLIC_DIR} -p #{PORT}"
    
    # Handle graceful exit on Ctrl+C inside terminal or containers
    begin
      system(cmd)
    rescue Interrupt
      puts "\n  » Server stopped safely. Goodbye!"
    end
  end
end

# Expose a clean, punchy top-level shortcut task
desc "Serve the compiled production-ready website locally"
task :serve => 'server:run'
