# frozen_string_literal: true

require_relative '../config'
require_relative '../model'

module Rawww
  module Task

    # # NOTE: curious thing BUT smels as overengineering
    # module CallJournal
    #   def call(...)
    #     start_time = Time.now
    #     print "  » Running #{self.class.name}... "
    #     super(...)
    #     elapsed = Time.now - start_time
    #     puts "Finished in #{elapsed.round(2)}s"
    #   end
    # end
    
    # Abstract task
    class Base
      extend Basic::Callable
      
      def call
        raise NotImplementedError, "#{self.class} must implement #call"
      end

      private

      def config = Config.instance
    end
  end
end
