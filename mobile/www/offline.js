// Adresse du site en ligne : à garder identique à server.url dans capacitor.config.json
var SITE_URL = 'https://noorwan.com/';

function retry() {
    window.location.href = SITE_URL;
}

document.getElementById('retry').addEventListener('click', retry);
// Nouvelle tentative automatique dès que le téléphone retrouve le réseau
window.addEventListener('online', retry);
