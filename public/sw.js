// Service worker de noorwan.com (M-132) : l'application installée sans magasin a sa page hors ligne.
// Minimal : il ne garde que la page hors ligne, sa feuille et son icône, jamais une page du site ni une réponse du
// formulaire (aucune donnée personnelle). Les pages passent toujours par le réseau ; si le réseau manque, la page hors
// ligne les remplace. Chemins lus depuis l'adresse du worker : il marche à la racine du domaine comme dans un
// sous-dossier MAMP. Changer CACHE quand un fichier gardé change : l'ancien cache est effacé à l'activation.
'use strict';

var CACHE = 'noorwan-offline-v1';
var OFFLINE = new URL('offline.html', self.location).href;
var FILES = [OFFLINE, new URL('assets/css/offline.css', self.location).href, new URL('images/icons/icon-192.png', self.location).href];

self.addEventListener('install', function (event) {
    event.waitUntil(caches.open(CACHE).then(function (cache) {
        return cache.addAll(FILES);
    }).then(function () {
        return self.skipWaiting();
    }));
});

self.addEventListener('activate', function (event) {
    event.waitUntil(caches.keys().then(function (keys) {
        return Promise.all(keys.filter(function (key) {
            return key !== CACHE;
        }).map(function (key) {
            return caches.delete(key);
        }));
    }).then(function () {
        return self.clients.claim();
    }));
});

self.addEventListener('fetch', function (event) {
    var request = event.request;
    if (request.method !== 'GET') {
        return;
    }
    if (request.mode === 'navigate') {
        event.respondWith(fetch(request).catch(function () {
            return caches.match(OFFLINE);
        }));
        return;
    }
    // Fichiers de la page hors ligne : depuis le cache seulement quand le réseau manque.
    if (FILES.indexOf(request.url) !== -1) {
        event.respondWith(fetch(request).catch(function () {
            return caches.match(request);
        }));
    }
});
