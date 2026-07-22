/* ==========================================================================
   PRODUCTION SERVICE WORKER - PATH-AGNOSTIC GRANULAR CACHE ENGINE
   ========================================================================== */

const CACHE_NAME = 'gallery-core-v1';
const IMAGE_CACHE_NAME = 'gallery-images-v1';

// Dynamically resolves the base path (e.g., "/" or "/exposure/") from the SW scope
const BASE_SCOPE = new URL(self.registration.scope).pathname;

// Clean helper to build valid absolute paths inside the current environment
const getAbsPath = (file) => `${BASE_SCOPE.replace(/\/$/, '')}/${file.replace(/^\//, '')}`;

// 1. Install Event: Pre-cache core application shell
self.addEventListener('install', (event) => {
  const assetsToPrecache = [
    getAbsPath('/'),
    getAbsPath('/index.html'),
    getAbsPath('/cache_manifest.json'),
    getAbsPath('/assets/css/style.css'),
    getAbsPath('/assets/css/modules/base.css'),
    getAbsPath('/assets/css/modules/content.css'),
    getAbsPath('/assets/css/modules/header.css'),
    getAbsPath('/assets/css/modules/about.css'),
    getAbsPath('/assets/css/modules/error.css')
  ];

  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(assetsToPrecache))
      .then(() => self.skipWaiting())
  );
});

// 2. Activate Event: Granular image eviction based on the compiled assets-manifest.json
self.addEventListener('activate', (event) => {
  event.waitUntil(
    // Force immediate initialization of the images cache database context
    caches.open(IMAGE_CACHE_NAME).then((imageCache) => {
      
      return fetch(getAbsPath('/cache_manifest.json'), { cache: 'no-store' })
        .then((response) => {
          if (!response.ok) throw new Error(`Manifest fetch failed with status: ${response.status}`);
          return response.json();
        })
        .then((manifest) => {
          return imageCache.keys().then((requests) => {
            const manifestAssets = manifest.assets || {};

            // Map full request URLs back to the manifest relative path keys
            const cleanupPromises = requests.map((request) => {
              const url = new URL(request.url);
              
              // Standardize key format: e.g., "/series/almaznoe/full/DP0Q0624.webp"
              const manifestKey = url.pathname.replace(BASE_SCOPE, '/');

              // If a cached file is missing or has a modified timestamp, evict it
              if (!manifestAssets[manifestKey]) {
                console.log(`[SW] Evicting outdated or deleted asset: ${manifestKey}`);
                return imageCache.delete(request);
              }
            });
            return Promise.all(cleanupPromises);
          });
        })
        .catch((err) => {
          // Soft failure bypass: if the server stalls, we keep the service worker active
          console.warn('[SW Activation] Manifest sync bypassed. Core image cache preserved.', err.message);
        });
    })
    .then(() => {
      // Legacy system cache cleanup pass
      return caches.keys().then((keys) => {
        return Promise.all(keys.map((key) => {
          if (key !== CACHE_NAME && key !== IMAGE_CACHE_NAME) {
            return caches.delete(key);
          }
        }));
      });
    })
    .then(() => self.clients.claim())
  );
});

// 3. Fetch Event: Intercept image networks loads with explicit cache-first layer
self.addEventListener('fetch', (event) => {
  const requestUrl = new URL(event.request.url);

  if (requestUrl.pathname.match(/\.(webp|jpg|jpeg|png)$/i)) {
    event.respondWith(
      caches.open(IMAGE_CACHE_NAME).then((imageCache) => {
        return imageCache.match(event.request).then((cachedResponse) => {
          if (cachedResponse) {
            // Hot cache match: return instantly from local device sandbox storage
            return cachedResponse;
          }

          // Cold cache fallback: fetch from remote web server network streams
          return fetch(event.request).then((networkResponse) => {
            if (!networkResponse || networkResponse.status !== 200) {
              return networkResponse;
            }
            // Clone and save the fresh image stream into the device storage cache
            imageCache.put(event.request, networkResponse.clone());
            return networkResponse;
          }).catch(() => new Response('Offline Image Unavailable', { status: 404 }));
        });
      })
    );
  } else {
    // Network-First strategy with fallback to cache for critical HTML/CSS shell files
    event.respondWith(
      fetch(event.request)
        .then((networkResponse) => {
          if (networkResponse && networkResponse.status === 200) {
            const responseToCache = networkResponse.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(event.request, responseToCache));
          }
          return networkResponse;
        })
        .catch(() => caches.match(event.request))
    );
  }
});
