# RAWWW

> Raw Markdown to WWW. Driven by Rake and Pandoc.

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

