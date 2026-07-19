require_relative 'base'

module Rawww
  module Build

    # Page Builder
    class Page < Base

      # @param title [String]
      # @param content [String]
      # @return [String] Rawww page content
      def call(title, content)
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
    end    
  end
end
