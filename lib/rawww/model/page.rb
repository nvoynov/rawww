# lib/rawww/models/page.rb

module Rawww
  module Model
    # Represents a single raw Markdown file within the project lifecycle.
    # Responsible for path mapping, slug generation, and metadata extraction.
    class Page
      attr_reader :source_path

      def initialize(source_path)
        @source_path = source_path
      end

      # Generates a clean URL slug for the page.
      # Falls back to the filename if not explicitly defined in Front Matter.
      # @return [String] e.g., "about" or "my-custom-post"
      def slug
        @slug ||= begin
          raw_slug = metadata[:slug]
          if raw_slug && !raw_slug.empty?
            # Clean explicit slug from Front Matter
            raw_slug.downcase.strip.gsub(/[^a-z0-9\-_]+/, '-')
          else
            # Extract clean filename without directory and extension
            File.basename(@source_path, '.md').downcase
          end
        end
      end

      # Dynamically calculates target path based on the generated slug
      # @return [String] target html destination path (e.g., 'www/about.html')
      def destination_path
        # Keep directory structure but replace file name with the calculated slug
        dir_part = File.dirname(@source_path).sub(/^src/, 'www')
        File.join(dir_part, "#{slug}.html")
      end

      # Safely extracts Front Matter data block from the top of the file.
      # @return [Hash] containing parsed data like :title, :layout, and :slug
      def metadata
        @metadata ||= extract_metadata
      end

      # Returns the actual system modification time of the raw markdown file
      # @return [Time] file modification time
      def date
        @date ||= File.stat(@source_path).mtime
      end

      # Dynamically calculates sitemap change frequency based on file age
      # @return [String] dynamic frequency value (daily, weekly, monthly, yearly)
      def change_frequency
        days_old = (Time.now - date).to_i / 86400

        case days_old
        when 0...14   then "daily"
        when 14...56  then "weekly"
        when 56...365 then "monthly"
        else               "yearly"
        end
      end

      private

      def extract_metadata
        content = File.read(@source_path)
        data = { layout: 'default', slug: nil }
        
        if content =~ /\A---(.*?)---/m
          front_matter_block = $1
          begin
            parsed_yaml = YAML.load(front_matter_block) || {}
            yaml_data = parsed_yaml.transform_keys(&:to_sym)
            data.merge!(yaml_data)
          rescue StandardError => e
            puts "YAML parsing error in #{@source_path}: #{e.message}"
          end
        end

        data
      end


    end
  end
end
