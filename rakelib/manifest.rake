# rakelib/manifest.rake

require 'fileutils'

namespace :manifest do
  # Declare source files from the root of the project
  DOC_SOURCES = ['README.md', 'CHANGELOG.md']

  desc "Automatically stage core repository documents into the website source directory"
  task :sync do
    puts "  » Manifest processing: Syncing repository documents..."
    builder = Rawww::BuildPage.new
    
    DOC_SOURCES.each do |filename|
      next unless File.exist?(filename)

      # Target path inside the website compiler source folder
      target_name = filename.downcase
      target_path = File.join('src', target_name)
      
      # Deduce a clean web title from the file name (e.g., "CHANGELOG" or "README")
      page_title = File.basename(filename, '.md')

      # Read original text payload
      original_content = File.read(filename)

      # Build the final document wrapping it cleanly inside our Pandoc grid class
      packaged_content = builder.call(page_title, original_content)

      # Write onto disk safely
      FileUtils.mkdir_p('src')
      File.write(target_path, packaged_content)
      puts "  » manifest: mapped root #{filename} -> #{target_path}"
    end
  end

  desc "Clean staged manifest source files"
  task :clean do
    DOC_SOURCES.each do |filename|
      target_path = File.join('src', filename.downcase)
      if File.exist?(target_path)
        File.delete(target_path)
        puts "  » manifest cleaned: #{target_path}"
      end
    end
  end
end
