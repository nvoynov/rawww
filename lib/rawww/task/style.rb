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
      
      # Resolves @import instructions and merges target submodules recursively
      def combine(filepath)
        base_dir = File.dirname(filepath)
        combined = ""
    
        unless File.exist?(filepath)
          puts "  » css: Compile Error! Target file missing: #{filepath}"
          return combined
        end

        File.open(filepath, 'r') do |file|
          file.each_line do |line|
            next if line.strip.empty?
            
            if line =~ /^\s*@import\s+(?:url\()?['"]?([^'")\s?#]+)['"]?\)?\s*;/
              module_rel_path = $1
              module_full_path = File.expand_path(module_rel_path, base_dir)

              combined << "/* Injected module: #{module_rel_path} */\n"
              combined << combine(module_full_path) << "\n"
            else
              combined << line
            end
          end
        end
        combined
      end
      
    end
  end
end
