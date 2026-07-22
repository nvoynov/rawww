---
title: "Static Site Caching Guide: Balancing Performance and Freshness"
author: RAWWW Documentation
date: 2026-07-22
---

# Static Site Caching Strategy

When deploying static websites to platforms like GitHub Pages, implementing a proper caching strategy is essential. It minimizes bandwidth consumption, speeds up page load times for returning visitors, and ensures your site remains highly performant.

However, over-caching can lead to "stale content" issues, where users cannot see your latest updates. This guide explains how to balance performance and content freshness within the **RAWWW** engine environment.

---

## The Core Concept: Assets vs. Content

A common architectural mistake is treating all website files equally in your caching manifest. For optimal results, you must separate your files into two distinct categories:

### 1. Static Assets (`/assets/...`)

* **What they are**: Images (`.webp`, `.jpg`), stylesheets (`.css`), scripts (`.js`), vector graphics (`.svg`), and fonts.
* **Characteristics**: These files are typically heavy and rarely change. If a style or photo does change, it usually happens during a major redesign.
* **Caching Strategy**: **Cache Aggressively**. These files should be kept in the browser's hard cache as long as possible to save bandwidth.

### 2. HTML Content Pages (`.html`)

* **What they are**: `index.html`, `about.html`, `404.html`, and individual photo album pages.
* **Characteristics**: These files contain your actual text, layout structure, and links. They change whenever you fix a typo, update a phone number, or publish a new post.
* **Caching Strategy**: **Never Cache Hard**. The browser must always check the server to see if a page has been updated.

---

## Why Hard-Caching HTML Breaks Your Updates

If you include HTML files in a strict caching manifest (like a Service Worker cache list or long-lived HTTP headers), the following issue occurs:

1. You edit `src/about.md` to update your contact information.
2. You run `rake build` and push the changes to GitHub Pages.
3. A returning visitor opens your website.
4. Their browser sees the hard-cached version of `about.html` stored locally on their device. **The browser does not even attempt to query the server.**
5. The visitor sees your old information until they manually clear their browser cache or perform a hard reload (`Ctrl + F5`).

---

## The Ideal Workflow for RAWWW (GitHub Pages Optimization)

GitHub Pages handles basic caching out of the box using smart default HTTP headers. You can leverage this to create a seamless automation pipeline.

### Step 1: Exclude HTML from your Cache Manifests

If your Ruby scripts generate a JSON cache manifest for a Service Worker or asset-pipeline tracking, filter out all `.html` extensions. 

**Bad Manifest Approach:**
```json
{
  "/about.html": 1784653506,
  "/assets/css/style.css": 1784653506
}
```

**Good Manifest Approach (Assets Only):**
```json
{
  "/assets/css/style.css": 1784653506,
  "/assets/images/gallery/photo.webp": 1784653506
}
```

### Step 2: Let GitHub Handle HTML Revalidation

When HTML files are not hard-cached, GitHub Pages serves them with a `Cache-Control: must-revalidate` behavior. 

* Every time a user visits, the browser sends a lightweight request to GitHub asking: *"Has `about.html` changed since my last visit?"*
* If **no changes** were made, the server instantly responds with a `304 Not Modified` status. The data transferred is virtually zero bytes, and the browser displays the local page.
* If **changes exist**, the server transmits the new HTML file (usually only 2–10 KB of text). The user instantly sees your fresh content.

### Step 3: Implement Cache Busting for Updated Assets

Since your assets (`/assets/css/style.css`) are heavily cached, what happens if you change your site design? The user's browser might still use the old cached CSS file with the new HTML, breaking the layout.

To solve this, use **Cache Busting** in your templates by appending your manifest timestamp or a version query parameter:

```html
<!-- Inside src/templates/default.html -->
<link rel="stylesheet" href="/assets/css/style.css?v=1784653506">
```

When you update your styles and rebuild the site, the timestamp changes (e.g., `?v=1784653999`). The browser recognizes this as a completely new URL, bypasses the old cache, and downloads the fresh stylesheet immediately.

---

## Summary Checklist for New Sites

* [ ] **Images and CSS**: Included in the build manifest, cached aggressively.
* [ ] **HTML Pages**: Excluded from the hard-cache manifest, left to default server revalidation.
* [ ] **Cache Busting**: Query parameters (`?v=...`) or hashes applied to asset links inside templates during compilation.

