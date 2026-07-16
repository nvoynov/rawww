require "open3"
require_relative "callable"

module Basic
  # Abstract infrastructure base class providing a clean declarative DSL for safely
  # orchestrating and verifying external host system command-line utilities.
  class CliTool
    extend Callable

    class << self
      # Declaratively registers the host system binary executable command,
      # automatically preparing validation parameters for the child scope.
      #
      # @param name [String, Symbol] the core system command identifier
      def executable(name)
        @command = name.to_s.strip
      end

      # @return [String, nil] the registered active system executable command
      attr_reader :command
    end

    # Baseline initializer verifying dependencies execution availability.
    # Automatically triggers a Fail-Fast runtime guard sequence if missing.
    #
    # @raise [RuntimeError] if the declared system dependency tool is missing
    def initialize
      raise "No executable command declared for #{self.class}" unless command

      # Crossplatform check verifying if the binary target is executable
      unless system("command -v #{command} >/dev/null 2>&1")
        raise RuntimeError, "CLI dependency [#{command}] is missing in this OS!"
      end
    end

    protected

    # Executes the pre-registered shell binary securely via Open3 mechanics.
    # Accurately splits and forwards optional process keyword options (like chdir).
    #
    # @param args [Array<String>] collection of clean contextual CLI parameters
    # @param kwargs [Hash] optional system process overrides (e.g., chdir: path)
    # @return [String] raw standard output text from the execution pipeline
    # @raise [RuntimeError] if the system utility returns an error exit status
    def execute_command(*args, **kwargs)
      # Pass both positioning parameters and keywords separation natively to capture3
      stdout, stderr, status = Open3.capture3(command, *args, **kwargs)

      unless status.success?
        raise "CLI Tool [#{command}] execution failed! " \
              "Exit status: #{status.exitstatus}. Reason: #{stderr.strip}"
      end

      stdout
    end

    private

    # Proxy helper shortcut delegating command string lookups straight to class scope.
    # @return [String, nil] the active binary command name string
    def command = self.class.command
  end
end
