require_relative 'rawww/version'
require_relative 'rawww/banner'
require_relative 'rawww/basic'
require_relative 'rawww/config'
require_relative 'rawww/model'
require_relative 'rawww/task'
require_relative 'rawww/pandoc'

module Rawww
  extend ::Basic::AliasMembers
  
  alias_members Model
  alias_members Task
end
