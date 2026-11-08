// 🎵 Seventh-day Adventist (SDA) Hymnal Service Worker
// Enables 100% offline access to all 695 hymn lyrics and cached MP3 audio files.

const CACHE_NAME = 'sda-hymnal-v2';
const STATIC_URLS_TO_CACHE = [
  '/',
  '/hymns.html',
  '/books.html',
  '/support.html',
  '/contact.html',
  '/api/hymns?limit=695',
  '/static/audio/hymns/108.mp3'
];

// 1. Install & Pre-cache
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      console.log('[SW] Pre-caching SDA Hymnal core assets...');
      return cache.addAll(STATIC_URLS_TO_CACHE).catch(err => {
        console.warn('[SW] Some initial assets could not be pre-cached:', err);
      });
    })
  );
  self.skipWaiting();
});

// 2. Activate & Clear Old Caches
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames
          .filter(name => name.startsWith('sda-hymnal-') && name !== CACHE_NAME)
          .map(name => caches.delete(name))
      );
    })
  );
  self.clients.claim();
});

// 3. Fetch Strategy:
// - Audio Files (.mp3): Cache-First strategy for instant, offline playback
// - API & Pages: Network-First with fallback to Cache
self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);

  // Audio files (.mp3) -> Cache First
  if (url.pathname.endsWith('.mp3') || url.pathname.includes('/audio')) {
    event.respondWith(
      caches.open(CACHE_NAME).then(async cache => {
        const cachedResponse = await cache.match(event.request);
        if (cachedResponse) {
          return cachedResponse;
        }
        try {
          const networkResponse = await fetch(event.request);
          if (networkResponse && networkResponse.status === 200) {
            cache.put(event.request, networkResponse.clone());
          }
          return networkResponse;
        } catch (error) {
          return cachedResponse || new Response('Offline audio not available in cache.', { status: 503 });
        }
      })
    );
    return;
  }

  // HTML / API / Static -> Network First with Cache Fallback
  event.respondWith(
    fetch(event.request)
      .then(networkResponse => {
        if (networkResponse && networkResponse.status === 200) {
          const responseToCache = networkResponse.clone();
          caches.open(CACHE_NAME).then(cache => {
            cache.put(event.request, responseToCache);
          });
        }
        return networkResponse;
      })
      .catch(async () => {
        const cachedResponse = await caches.match(event.request);
        if (cachedResponse) {
          return cachedResponse;
        }
        // Fallback to hymns.html if navigating
        if (event.request.mode === 'navigate') {
          return caches.match('/hymns.html');
        }
        return new Response(JSON.stringify({ offline: true, message: "Network unavailable. Serving from offline cache." }), {
          headers: { 'Content-Type': 'application/json' }
        });
      })
  );
});

