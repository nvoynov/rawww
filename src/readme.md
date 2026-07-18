---
title: README
layout: default
---

::: {.page-main-body-content}

# RAWWW

> Raw Markdown to WWW. Driven by Rake and Pandoc.
>
> **Project Origin**
>
> This starter template is the refined distillation of a month-long architectural journey designing a custom photography web gallery. The codebase successfully evolved from a rigid Jekyll setup into a lightweight, high-utility, and fully transparent compiler powered by Ruby, Rake, and Pandoc. **RAWWW** preserves this foundation as a production-ready springboard for future static web craft.

A minimalist, high-utility static website starter kit designed for speed, clean code, and zero JS overhead. Write raw Pandoc Markdown, orchestrate with Rake, and deploy anywhere.

## Features

* **Pure Pandoc**: Compile rich Markdown directly to clean HTML.
* **Rake Automation**: Build, serve, and deploy using simple Ruby scripts.
* **Docker Ready**: Pre-configured environment for isolated development via Docker or Podman.
* **Clean Architecture**: Minimal assets, modular CSS, and structured folders.

## Quick Start

### 1. Fork and Clone

To be able to deploy your site and push changes, you need your own copy of the repository.

1. Click the **Fork** button at the top right of this repository page to copy it to your GitHub account.
2. Clone your newly forked repository (replace `your-username` with your actual GitHub username):

```bash
git clone https://github.com
cd rawww
```

> **Alternative**: If this repository is configured as a template, you can simply click the green **"Use this template"** button to create a fresh, clean repository based on `rawww`.

### 2. Run with Docker / Podman

Build the container image:
```bash
podman build -t rawww-site .
```

Start the local development server with live folder mounting:
```bash
podman run -it --rm -p 8000:8000 -v .:/app rawww-site rake serve
```

Your site will be live at `http://localhost:8000`.

### 3. Local Automation (Alternative)

If you have Ruby, Pandoc, and Rake installed locally on your system, just use the CLI:

```bash
rake -T      # List all available automation tasks
rake build   # Compile raw content to production-ready HTML
rake serve   # Launch a lightweight local preview server
rake push    # Deploy the compiled static site to GitHub Pages
```

## Project Structure

* `/src` — Your raw content (Markdown, layout templates, modular CSS, and raw JS).
* `/www` — The generated, production-ready static website (ignored by git).
* `/rakelib` — Modular Rake tasks for build orchestration and deployments.
* `/lib` — Custom Ruby automation logic and helper scripts.

## Beyond the Basics

When your project grows beyond simple static pages, you can easily extend `rawww`:

* **Custom Tasks**: Add new file or rule tasks in `manifest.rake` to generate dynamic content maps.
* **Asset Optimization**: Integrate custom scripts to copy, compress, and optimize media folders (like photography assets) directly into the `:build` task chain.
* **AI Copilot**: Use the pre-configured Gemini prompt template located in `.github/copilot-prompt.md` to teach any LLM your exact automation workflow for quick feature expansion.

## Advanced Architecture & Layout Features

`rawww` leverages custom object-oriented Ruby 3.4 models combined with Pandoc's native power to give you flexible layout control directly inside your Markdown files.

### 1. Dynamic Layout Switching

By default, pages compile using `src/templates/default.html`. You can create any alternative layout file inside `src/templates/` (e.g., `gallery.html`) and mount it seamlessly via Front Matter:
```yaml
---
title: My Photography Work
layout: gallery
---
```

### 2. URL Slug Overriding

The engine reads file boundaries and automatically generates clean URL addresses. If you want to force an explicit URL path regardless of the original filename, use the `slug` variable:

```yaml
---
title: Contact Information
slug: get-in-touch
---
```
*Result:* The file compiles cleanly straight to `www/get-in-touch.html` and hooks into the automated `sitemap.xml` with zero configuration.

### 3. Modular Partials Injection (e.g., Google Analytics)

To maintain complete control over code cleanliness, you can isolate tracking pixels, scripts, or comments into dedicated HTML partials inside `src/templates/` (e.g., `analytics.html`). Inject them only into pages that require monitoring using the `include-before` hook:

```yaml
---
title: Welcome to RAWWW
layout: default
slug: home
include-before: src/templates/analytics.html
---

::: {.page-main-body-content}
# Raw Web Node
This specific page is now dynamically rendering your tracking layer, while other nodes remain completely clean.
:::
```


:::
