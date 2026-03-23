const CACHE_NAME = 'mydonelist-v1';
const ASSETS = [
  '/My-done-list/',
  '/My-done-list/index.html',
  '/My-done-list/manifest.json',
  '/My-done-list/icon-192.png',
  '/My-done-list/icon-512.png',
  'https://fonts.googleapis.com/css2?family=Outfit:wght@200;300;400;500;600&display=swap',
];

// Install — cache shell
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(ASSETS))
  );
  self.skipWaiting();
});

// Activate — clean old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)))
    )
  );
  self.clients.claim();
});

// Fetch — cache-first for assets, network-first for navigation
self.addEventListener('fetch', (event) => {
  const { request } = event;

  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request).catch(() => caches.match('/My-done-list/index.html'))
    );
    return;
  }

  event.respondWith(
    caches.match(request).then((cached) => cached || fetch(request))
  );
});
