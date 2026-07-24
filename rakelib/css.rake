# rakelib/css.rake
require 'fileutils'

namespace :css do
  # Path constants defining context layers
  SRC_CSS_DIR = File.join(Rawww::SOURCE_DIR, 'assets', 'css')
  PUB_CSS_DIR = File.join(Rawww::PUBLIC_DIR, 'assets', 'css')
  
  MAIN_SRC_CSS = File.join(SRC_CSS_DIR, 'style.css')
  FINAL_PUB_CSS = File.join(PUB_CSS_DIR, 'style.css')

  CSS_SRC_FILES = File.exist?(SRC_CSS_DIR) ? FileList["#{SRC_CSS_DIR}/**/*.css"] : []

  # --- CORE UTILITY METHODS ---

  # Phase 1: Resolves @import instructions and merges target submodules
  def self.inline_css_modules(main_file_path, base_dir)
    combined = ""
    
    File.open(main_file_path, 'r') do |file|
      file.each_line do |line|
        # Guard clause: skip empty layout lines immediately
        next if line.strip.empty?

        # NEW GUARD CLAUSE: Skip commented-out imports securely
        next if line.strip.start_with?('/*')

        # Guard clause: if line is not an @import directive, buffer it and continue
        unless line =~ /@import\s+(?:url\()?['"]?([^'")]+)['"]?\)?;/
          combined << line
          next
        end

        # Process matching module reference
        module_rel_path = $1
        module_full_path = File.expand_path(module_rel_path, base_dir)

        # Fallback safeguard check for physically missing submodules
        unless File.exist?(module_full_path)
          puts "  » css: Compile Error! Target module missing: #{module_full_path}"
          next
        end

        combined << "/* Injected module: #{module_rel_path} */\n"
        combined << File.read(module_full_path) << "\n"
      end
    end
    combined
  end

  # Phase 2: Compresses raw combined CSS code strings via a chained regex pipeline
  def self.minify_css_payload(raw_css)
    raw_css
      # Step A: Evict multi-line CSS block comments /* ... */
      .gsub(/\/\*.*?\*\//m, '')
      # Step B: Flatten layout linebreaks, structural carriage returns, and tabs
      .gsub(/[\n\r\t]/, ' ')
      # Step C: Compress sequential multi-space boundaries into tight single layout slots
      .gsub(/ {2,}/, ' ')
      # Step D: Strip redundant whitespace padding wrapping active syntax selectors ({ } : ; ,)
      .gsub(/\s*([\{\}:;,])\s*/, '\1')
      # Step E: Evict loose final semicolons standing right before terminating block brackets
      .gsub(/;}/, '}')
      # Step F: Trim edge whitespace configurations completely
      .strip
  end

  # Phase 3: Manages metrics reporting and writes binary payload stream to disk
  def self.write_optimized_bundle(destination_path, payload, original_size_bytes)
    FileUtils.mkdir_p(File.dirname(destination_path))
    File.write(destination_path, payload)
    
    orig_kb = original_size_bytes / 1024.0
    mini_kb = payload.bytesize / 1024.0
    reduction = orig_kb > 0 ? ((orig_kb - mini_kb) / orig_kb * 100).round(1) : 0

    puts "  » css: Production single stylesheet bundle built cleanly."
    puts "         Optimized payload size: #{mini_kb.round(2)} KB (-#{reduction}%)"
  end

  # --- RAKE FILE TASK BOUNDARY ---

  # Incremental file compilation track target map 
  file FINAL_PUB_CSS => CSS_SRC_FILES do
    puts "  » css: Detected modifications. Running asset optimization pipeline..."
    
    # Execute structural phases sequentially
    combined_source = inline_css_modules(MAIN_SRC_CSS, SRC_CSS_DIR)
    minified_payload = minify_css_payload(combined_source)
    
    write_optimized_bundle(FINAL_PUB_CSS, minified_payload, combined_source.bytesize)
  end

  # CLI Shorthand Hook Configuration Entrypoint
  desc "Compile, inline, and minify CSS modules dynamically"
  task :build => FINAL_PUB_CSS

  desc "Clean compiled production production stylesheet target"
  task :clean do
    if File.exist?(FINAL_PUB_CSS)
      FileUtils.rm_f(FINAL_PUB_CSS)
      puts "  » css: Cleaned production asset target at #{FINAL_PUB_CSS}"
    end
  end
end
