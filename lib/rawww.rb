require_relative 'rawww/version'
require_relative 'rawww/banner'
require_relative 'rawww/basic'
require_relative 'rawww/model'
require_relative 'rawww/build'
require_relative 'rawww/config'
require_relative 'rawww/pandoc'


module Rawww
  extend ::Basic::AliasMembers
  
  alias_members Model
  alias_members Build, prefix: 'Build'

  # Single source of truth for the production output directory
  PUBLIC_DIR = "www"
end

pp Rawww.constants if __FILE__ == $0
