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
        @metadata ||= parse_front_matter
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

      # A lightweight, zero-dependency parser for core document configuration.
      def parse_front_matter
        content = File.read(@source_path)
        data = { layout: 'default', slug: nil }

        if content =~ /\A---(.*?)---/m
          front_matter_block = $1

          if (title_match = front_matter_block.match(/title:\s*(.*)/))
            raw_title = title_match.captures.first
            # data[:title] = raw_title ? raw_title.strip : 'Untitled'
            data[:title] = raw_title if raw_title
          end

          if (layout_match = front_matter_block.match(/layout:\s*(.*)/))
            raw_layout = layout_match.captures.first
            data[:layout] = raw_layout ? raw_layout.strip : 'default'
          end

          # Support explicit custom slug overriding inside Front Matter
          if (slug_match = front_matter_block.match(/slug:\s*(.*)/))
            raw_slug = slug_match.captures.first
            data[:slug] = raw_slug ? raw_slug.strip : nil
          end
        end

        data
      end
    end
  end
end
