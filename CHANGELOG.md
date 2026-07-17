## [Unreleased]

## 2026-07-16

TODO

- [ ] compile `or-card.svg` to png on Ubuntu
      some problems with fonts on MacOS
- [ ] deploy with proper og-card!

- added `src/og-card.svg`
- fixed "Untitled |" thing
- cleaned extra `/src/*.svg`
- copied `svg` into `/assets`

## [0.1.0] - 2026-07-15

Initial release

``
├── CHANGELOG.md
├── compose.yaml
├── copilot-prompt.md
├── Dockerfile
├── Gemfile
├── lib
│   ├── basic
│   │   ├── alias_members.rb
│   │   ├── callable.rb
│   │   ├── cli_tool.rb
│   │   └── configuration.rb
│   ├── basic.rb
│   ├── rawww
│   │   ├── banner.rb
│   │   ├── basic.rb
│   │   ├── model
│   │   │   ├── page.rb
│   │   │   └── site.rb
│   │   ├── model.rb
│   │   ├── pandoc.rb
│   │   └── version.rb
│   └── rawww.rb
├── PROMPT.md
├── Rakefile
├── rakelib
│   ├── assets.rake
│   ├── build.rake
│   ├── deploy.rake
│   ├── seo.rake
│   └── serve.rake
├── README.md
├── src
│   ├── 404.md
│   ├── about.md
│   ├── assets
│   │   ├── css
│   │   │   ├── modules
│   │   │   │   ├── about.css
│   │   │   │   ├── base.css
│   │   │   │   ├── content.css
│   │   │   │   ├── error.css
│   │   │   │   └── header.css
│   │   │   └── style.css
│   │   ├── images
│   │   └── js
│   ├── favicon.svg
│   ├── favicon1.svg
│   ├── index.md
│   └── templates
│       ├── analytics.html
│       └── default.html
└── www

14 directories, 39 files
```
