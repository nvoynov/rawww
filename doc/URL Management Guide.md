---
title: "URL Management Guide: GitHub Pages & Custom Domains"
author: RAWWW Documentation
date: 2026-07-22
---

# Managing Paths and URLs in Static Websites

When building static websites that need to run in multiple environments (such as a local development server, GitHub Pages project subfolders, and unique custom domains), managing asset paths (`CSS`, `JS`, images) and internal links can be challenging. 

This guide outlines the three most effective architectural approaches for handling URLs cleanly within the **RAWWW** engine or any Pandoc-driven pipeline.

---

## The Core Challenge

1. **Local Preview (`localhost:8000`)**: The site runs at the root level. Paths should look like `/assets/css/style.css`.
2. **GitHub Pages Project (`user.github.io/project`)**: The site runs inside a subdirectory. Paths must include the project prefix: `/project/assets/css/style.css`.
3. **Custom Domain (`my-site.com`)**: The site returns to the root level. Paths must revert to `/assets/css/style.css`.

Hardcoding absolute paths breaks local preview or GitHub Pages. Using relative paths (`../assets`) becomes unmaintainable as your folder structure grows deeper.

---

## Approach 1: Dynamic Prefixes via Pandoc Variables (Recommended)

This approach uses a central variable (e.g., `root_path`) defined in your configuration layer (`rawww.yml`) and passes it directly to Pandoc during compilation.

### How it Works in Templates
In your HTML templates (e.g., `src/templates/default.html`), prepend all system paths with the Pandoc variable:

```html
<link rel="stylesheet" href="\(root_path\)/assets/css/style.css">
<a href="\(root_path\)/">Home</a>
<a href="\(root_path\)/series/vaseline.html">Gallery</a>
```

### How it Works in Markdown Content
To use variables inside your raw `.md` files, ensure Pandoc's `interpolated_variables` extension is enabled (enabled by default in most modern Markdown readers, or via `-f markdown+interpolated_variables`).

Write your content links using the variable placeholder syntax (`^variable^` or `$variable$` depending on your Pandoc version):

```markdown
Look at this image:
![](^root_path^/assets/images/vaseline/thumb/P1001495.webp)

Or check out the [Vaseline Project](^root_path^/series/vaseline.html).
```

### Environment Configuration Matrix

| Environment | Config Variable Value | Compiled HTML Result |
| :--- | :--- | :--- |
| **Local Dev** | `root_path: ""` | `/assets/css/style.css` |
| **GitHub Pages** | `production_root_path: "/project"` | `/project/assets/css/style.css` |
| **Custom Domain** | `production_root_path: ""` | `/assets/css/style.css` |

---

## Approach 2: Build-Time Content Pipeline Preprocessing (Ruby Layer)

If you prefer keeping your Markdown files completely pure and standard (without typing Pandoc variables like `^root_path^` manually in your text), you can leverage Ruby inside your `Rakefile` pipeline to alter paths on the fly.

### How it Works
1. You write standard root-relative paths in your Markdown files:
   ```markdown
   [Open Album](/series/vaseline.html)
   <img src="/assets/images/vaseline/thumb/P1001495.webp" />
   ```
2. Your Ruby build task reads the Markdown content and applies a regular expression (`gsub`) to inject the appropriate prefix before passing the string to Pandoc.

### Example Ruby Implementation snippet:
```ruby
# Inside your build.rake task
current_root = is_production ? config['production_root_path'] : config['root_path']

# Automatically prepend the root to image tags and markdown links
processed_md = markdown_content.gsub(/(src|href)="\/([^"]*)"/, "\\1=\"#{current_root}/\\2\"")
processed_md = processed_md.gsub(/\]\(\/([^)]*)\)/, "\](#{current_root}/\\1)")
```

**Pros**: Completely standard Markdown files. Seamless transition to custom domains (just flip `production_root_path` to `""`).  
**Cons**: Requires maintaining regex parsing logic in your build scripts.

---

## Approach 3: The HTML `<base>` Tag (Zero-Variable Alternative)

If you want a purely client-side solution without messing with variables in Markdown or Rake tasks, you can use the native HTML `<base>` element.

### How it Works
You insert the `<base>` tag into the `<head>` of your HTML template. This tag tells the browser how to resolve all **relative** links on the page.

```html
<head>
    <!-- For GitHub Pages Project Subfolder -->
    <base href="/project/">
    
    <!-- For Local Preview or Custom Domain, it switches to: -->
    <!-- <base href="/"> -->
</head>
```

When this tag is present, you must write your asset and page links as relative paths **without** a leading slash:

```html
<!-- Inside your pages or templates -->
<link rel="stylesheet" href="assets/css/style.css">
<img src="assets/images/vaseline/thumb/P1001495.webp" />
```
The browser automatically resolves `assets/css/style.css` to `/project/assets/css/style.css` regardless of how deep the current page is nested (e.g., even inside `/series/albums/vaseline.html`).

**Pros**: Native browser behavior, no build-step modifications required for content files.  
**Cons**: Can interfere with page-internal anchor jumps (e.g., `<a href="#section">` might resolve to `/project/#section` and trigger a reload in some older browsers).

---

## Summary for RAWWW Evolution

For a high-utility static engine like **RAWWW**, **Approach 1 (Pandoc Interpolated Variables)** provides the cleanest balance. It maintains explicit compilation control, matches Pandoc's core design principles, and allows you to switch from GitHub Pages subfolders to standalone unique domains by modifying a single line in `rawww.yml`.

