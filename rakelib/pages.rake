require_relative 'context'

namespace :pages do
  # Declare source files from the root of the project
  DOC_SOURCES = ['README.md', 'CHANGELOG.md']

  def self.make_page(title, content)
    <<~MARKDOWN
      ---
      title: #{title}
      layout: default
      ---
  
      ::: {.page-main-body-content}
  
      #{content}
  
      :::
    MARKDOWN
  end

  task :sync do
    # puts "  Syncing repository documents..."
  
    DOC_SOURCES.each do |filename|
      next unless File.exist?(filename)

      target_name = filename.downcase
      target_path = File.join('src', target_name)
      page_title = File.basename(filename, '.md')
      original_content = File.read(filename)
      packaged_content = self.make_page(page_title, original_content)

      File.write(target_path, packaged_content)
      puts "  » pages mapped #{filename} -> #{target_path}"
    end
  end

  desc "Clean staged manifest source files"
  task :clean do
    DOC_SOURCES.each do |filename|
      filepath = File.join('src', filename.downcase)
      next unless File.exist?(filepath)
    
      rm filepath
      puts "  » page cleaned: #{filepath}"
    end
  end
end

desc 'Synchronize pages'
task :pages => 'pages:sync'
