require 'json'
require_relative 'base'

module Rawww
  module Task
  
    # Cachemap.json builder
    class Cachemap < Base
      def call
        payload = { "assets" => {} }

        public_dir = config.www
        filenames = Dir.glob(File.join(public_dir, '**/*'))
          .select{ File.file?(it)  }
          .reject{ it =~ /\.html$/ }

        filenames.each do |file|
          key = file.sub(/^#{public_dir}/, '')
          val = File.mtime(file).to_i
          payload['assets'][key] = val
        end

        body = JSON.pretty_generate(payload)
        filepath = File.join(public_dir, 'cachemap.json')
        File.write(filepath, body)
      end
    end
  end
end
