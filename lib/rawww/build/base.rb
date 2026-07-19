require 'forwardable'
require_relative '../config'
require_relative '../basic'
require_relative '../model'

module Rawww
  module Build

    # Abstract Builder
    class Base
      extend ::Basic::Callable
      extend Forwardable
      def_delegator :'Rawww::Config', :instance, :config
    end    
  end
end
