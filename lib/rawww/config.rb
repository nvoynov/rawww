# lib/rawww/config.rb
require_relative 'basic'

module Rawww
  # Strict structural parameter schema for the rawww static web engine config
  ConfigSchema = Data.define(:title, :author, :root_path, :production_root_path, :site_url) do
    # Define absolute clean default values using standard keyword arguments fallback layout
    def initialize(
      title: "RAWWW Engine", 
      author: "Nikolay Voynov", 
      root_path: "", 
      production_root_path: "/rawww", 
      site_url: "https://github.io"
    )
      super(
        title: title, 
        author: author, 
        root_path: root_path, 
        production_root_path: production_root_path, 
        site_url: site_url
      )
    end
  end

  # The active operational Configuration proxy entity
  class Config < ::Basic::Configuration
    # Automatically manages config initialization mapping onto '_config.yml' target file
    manage ConfigSchema
  end
end
