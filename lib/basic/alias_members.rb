module Basic

  module AliasMembers
    # Metaprogramming engine that extracts constants from a sub-module 
    # and exposes them directly at the parent module level with a suffix.
    #
    # @param source_module [Module] the sub-module to scan (e.g., Rawww::Model)
    def alias_members(source_module, prefix: nil, suffix: nil)
      prefix ||= ''
      suffix ||= ''
      
      # Extracts the last part of the module name (e.g., "Rawww::Model" -> "Model")
      suffix = source_module.name.split('::').last \
        if suffix.empty? && prefix.empty?

      source_module.constants.each do |const_name|
        next if const_name == :Base
        const_value = source_module.const_get(const_name)
      
        # We target core operational entities like Classes or Sub-Modules
        next unless const_value.is_a?(Class) || const_value.is_a?(Module)

        # Constructs a predictable alias name (e.g., "PageModel")
        alias_name = "#{prefix}#{const_name}#{suffix}"

        # Explicitly bind the constant to the module that extended this helper (self)
        self.const_set(alias_name, const_value)
      end
    end
  end

end
