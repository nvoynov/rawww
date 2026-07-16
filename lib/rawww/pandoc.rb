require_relative 'basic'
require_relative 'config'

module Rawww

  # Dedicated compilation engine wrapping the system Pandoc compiler 
  # to transform raw Markdown pages into fully themed HTML5 website nodes.
  class Pandoc < ::Basic::CliTool
    executable :pandoc
    
    # Translates a raw markdown file into a themed website page.
    #
    # @param source [String] path to the input markdown source file
    # @param template [String] path to the HTML master shell template
    # @param destination [String] target output path for the compiled HTML
    # @return [String] raw standard output text from the execution pipeline
    # @raise [RuntimeError] if the system pandoc utility returns an error
    def call(source:, template:, destination:, variables: {}, extra_arguments: [])
      cmd = [
        source,
        "-f", "markdown+fenced_divs+raw_html",
        "-t", "html5",
        "--template", template,
        "-o", destination
      ]

      variables.each do |key, value|
        next if value.nil?
        cmd << "-V" << "#{key}=#{value}"
      end

      execute_command(*(cmd + extra_arguments))
    end
  end
end
