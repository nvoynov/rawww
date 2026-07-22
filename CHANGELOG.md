## [Unreleased]

## [Unreleased] - 2026-07-22

- added `doc/*.md`
- moved `favicon.svg` and `og-card.png` moved to `src/assets/`, simplyfying `assets.rake` 
- fixed `src/default.html` for using `rawww.yml` settings
- fixed `src/index` for providing relative og-card.png path
- added pragmatic caching
  - designed `Build::CacheManifest`
  - added `src/sw.js` for managing
  - changed `build.rake` accordingly
- added `#compile_pandoc_extra_args` Pandoc compiler (see `build.rake`) 

## [Unreleased] - 2026-07-19

- sitemap generator moved to `build/sitemap.rb`
- manifest page generator extracted into `build/page.rb`

## [0.1.0] - 2026-07-18

- changed `src/about.md` for prividing banner
- designed `rakelib/manifest.rake` demo for copying README and CHANGELOG; accordingly updated navigagion in `src/templates/default.html`

## [Unrelesed] - 2026-07-16

- added `src/og-card.svg`
- fixed "Untitled |" thing
- cleaned extra `/src/*.svg`
- copied `svg` into `/assets`

## [Unreleased] - 2026-07-15

Initial release

```
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
