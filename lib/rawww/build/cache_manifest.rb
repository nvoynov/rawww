require 'json'
require_relative 'base'

module Rawww
  module Build
  
    # Service object responsible for scanning the final production output directory 
    # and compiling a deterministic mtime manifest for granular Service Worker caching.
    class CacheManifest < Base

      # @return [String] JSON manifest content
      def call
        manifest_payload = { "assets" => {} }
      
        # Dynamically locate generated assets file footprint within the web root
        production_files = Dir
          .glob("#{Rawww::PUBLIC_DIR}/**/*")
          .select{ File.file?(it)  }
          .reject{ it =~ /\.html$/ }
          .tap{ pp it }
      
        production_files.each do |file|
          # Convert absolute/relative disk paths straight to pristine
          #   web root keys (e.g., "/css/style.css")
          clean_key = file.sub(/^#{Rawww::PUBLIC_DIR}/, "")
        
          # Capture the integer modification stamp as an unforgeable cache-busting token
          manifest_payload["assets"][clean_key] = File.mtime(file).to_i
        end

        JSON.pretty_generate(manifest_payload)
      end
    end
  end
end
