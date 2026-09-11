require_relative 'context'

namespace :server do
  PORT = 8000

  task :run => :build do
    puts Rawww::BANNER
    puts Rawww.environment_info
    puts "  » Starting development server..."
    puts "  » Local URL: http://localhost:#{PORT}"
    puts "  » Press Ctrl+C to stop the engine"
    puts "  ─────────────────────────────────"
    
    # Launch Ruby's built-in light HTTP server pointing to the www directory
    cmd = "ruby -run -e httpd #{WWW} -p #{PORT}"
    
    # Handle graceful exit on Ctrl+C inside terminal or containers
    begin
      system(cmd)
    rescue Interrupt
      puts "\n  » Server stopped safely. Goodbye!"
    end
  end
end

desc "Serve the compiled production-ready website locally"
task :serve do
  puts "  » Flushing local compilation caches..."
  Rake::Task['clean'].invoke

  puts "  » Generating series markdown..."
  Rake::Task['pages'].invoke

  puts "  » Triggering development build..."
  Rake::Task['build'].invoke

  Rake::Task['server:run'].invoke
end
