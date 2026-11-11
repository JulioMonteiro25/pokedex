const V = 'pokedex-v17';
const SHELL = ['./', 'index.html', 'data.json', 'pt.json', 'itens.json', 'insignias.json', 'manifest.webmanifest', 'apple-touch-icon.png', 'icon-512.png'];
const PACKS = Array.from({ length: 13 }, (_, i) => 'img-' + i + '.json').concat(['img-m0.json', 'img-m1.json']);

self.addEventListener('install', e => {
  e.waitUntil(caches.open(V).then(c => c.addAll(SHELL)).then(() => self.skipWaiting()));
});
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== V).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});
self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET' || new URL(e.request.url).origin !== location.origin) return;
  const path = new URL(e.request.url).pathname;
  const pack = /\/img-[^/]*\.json$/.test(path);
  const save = r => { if (r.ok) { const copy = r.clone(); caches.open(V).then(c => c.put(e.request, copy)); } return r; };
  if (pack) {   // pacotes de imagens (grandes): cache primeiro
    e.respondWith(caches.match(e.request).then(hit => hit || fetch(e.request).then(save).catch(() => Response.error())));
  } else {      // página e dados: rede primeiro (sempre a versão mais nova), cache só offline
    e.respondWith(fetch(e.request, { cache: 'no-cache' }).then(save).catch(() =>
      caches.match(e.request).then(hit => hit || (e.request.mode === 'navigate' ? caches.match('index.html') : Response.error()))));
  }
});

// Baixa todos os pacotes de imagens para uso offline e avisa a página do progresso.
self.addEventListener('message', e => {
  if (e.data !== 'precache') return;
  const client = e.source;
  e.waitUntil((async () => {
    const c = await caches.open(V);
    let done = 0;
    for (const p of PACKS) {
      if (!(await c.match(p))) {
        try { const r = await fetch(p); if (r.ok) await c.put(p, r); } catch (err) {}
      }
      done++;
      if (client) client.postMessage({ type: 'precache', done, total: PACKS.length });
    }
    const ok = (await Promise.all(PACKS.map(p => c.match(p)))).every(Boolean);
    if (client) client.postMessage({ type: 'precache', done: PACKS.length, total: PACKS.length, ok });
  })());
});