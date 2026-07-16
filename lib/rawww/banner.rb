require_relative "version"

module Rawww
  BANNER = <<~TEXT
        ____ ___ _ _ _ _ _ _
       / __ \\/   | | | | | | | | |
      / /_/ / /| | | | | | | | |
     / _, _/ ___ | |/| |/| |/| |
    /_/ |_/_/  |_|__,__,__,__/  v#{VERSION}
     ─────────────────────────────────
     ─── rake & pandoc static web core ───
  TEXT

  def self.environment_info
    ruby_v   = RUBY_VERSION
    rake_v   = Rake::VERSION rescue 'unknown'
    
    # Безопасно запрашиваем версию pandoc без зависания терминала
    pandoc_v = `pandoc --version 2>&1`.split("\n").first rescue nil
    pandoc_v = pandoc_v ? (pandoc_v.match(/pandoc\s+([\d.]+)/)&.captures&.first || 'unknown') : 'not installed'

    "[ ruby #{ruby_v} • rake #{rake_v} • pandoc #{pandoc_v} ]"
  end
end
