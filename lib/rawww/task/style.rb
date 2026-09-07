require 'json'
require_relative 'base'

module Rawww
  module Task
  
    # Style.css builder
    class Style < Base
      def call
        source = File.join(config.raw, 'assets', 'css', 'style.css')
        target = source.sub(/^#{config.raw}/, config.www) 
        combine(source)
          .then{ minify(it) }
          .then{ File.write(target, it) }
      end

      private 

      # Compresses raw combined CSS code strings via a chained regex pipeline
      def minify(raw_css)
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
      
      # Resolves @import instructions and merges target submodules
      def combine(filepath)
        base_dir = File.dirname(filepath)
        combined = ""
    
        File.open(filepath, 'r') do |file|
          file.each_line do |line|
            next if line.strip.empty?
            next if line.strip.start_with?('/*')

            # Guard if line is not an @import directive, buffer it and continue
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
    end
  end
end
