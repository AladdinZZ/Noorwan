# Application Android de noorwan.com

Décision Maestro M-122. L'application est une enveloppe Capacitor 8 qui affiche le site en ligne (`server.url`) : rien du site n'est copié dans l'application. Quand le site est injoignable, la page `mobile/www/index.html` (sur le téléphone) prend le relais.

Le site n'a pas d'outil de build (PHP sans framework, sans Composer) : tout ce qui sert à l'application vit dans `mobile/`, hors de la racine web `public/`. Rien de `mobile/` n'est servi.

## Ce qui est dans le dépôt

| Élément | Où |
|---|---|
| Paquets | `mobile/package.json` : `@capacitor/core`, `@capacitor/cli`, `@capacitor/android` en 8.x (verrou `mobile/package-lock.json`) |
| Réglages | `mobile/capacitor.config.json` : `appId` `com.noorwan.site`, `appName` « Noorwan », `webDir` `www`, `server.url` `https://noorwan.com`, `cleartext` faux, `androidScheme` `https`, `allowMixedContent` faux, `allowNavigation` vers `compte.noorwan.com` (l'entrée passe par Connect), `errorPath` `index.html` |
| Page hors ligne | `mobile/www/` (`index.html`, `offline.css`, `offline.js`) : sans script en ligne, sans ressource externe ; « Réessayer » renvoie vers le site, l'adresse de `offline.js` doit rester celle de `server.url` |
| Projet Android | `mobile/android/` (modèle Capacitor), icônes du lanceur et écrans de démarrage de la famille commune, fond #1D1D1F, barre d'état #1D1D1F |
| Test | section « 6. Application Android (M-122) » de `tests/run.sh` |

Ne sont pas versionnés : `mobile/node_modules`, `mobile/android/app/build`, `mobile/android/.gradle`, `mobile/android/app/src/main/assets/public` et les deux fichiers de configuration générés à côté, `local.properties`, les clés de signature (`*.jks`, `*.keystore`, `keystore.properties`).

## Construire sur le Mac

1. `cd /Applications/MAMP/htdocs/noorwan-site/mobile && npm install` (le dossier du dépôt est celui de `noorwan-site` sur le Mac)
2. `npx cap sync android` (copie la page hors ligne et la configuration dans `android/app/src/main/assets`, fichiers générés et ignorés par git)
3. `npx cap open android` : Android Studio ouvre le projet, Gradle se synchronise (SDK Android installé par Android Studio).
4. Essai sur un téléphone ou un émulateur : l'application doit afficher le site ; en mode avion, la page « Pas de connexion » ; « Continuer avec Noorwan » doit rester dans l'application (le Compte est dans `allowNavigation`).

Toutes les commandes `npx cap` se lancent depuis `mobile/`.

## Version et signature

- `mobile/android/app/build.gradle` : `versionCode` (entier, **à augmenter à chaque envoi** sur Google Play) et `versionName` (texte affiché).
- Signature : créer une clé d'envoi dans Android Studio (Build, Generate Signed App Bundle) ou avec `keytool`. La garder **hors du dépôt** (déjà ignorée) et la sauvegarder : sa perte bloque les mises à jour. Activer « Play App Signing » dans la console Play.
- Produire un `.aab` signé (Build, Generate Signed App Bundle), l'envoyer dans Google Play Console (piste interne d'abord, puis production).

## Publication

Fiche Play : nom Noorwan, description en français, captures d'écran, icône 512 (`icon-512.png` de `annexes/chartes/charte-commune/icones/noorwan/` du dépôt Maestro), politique de confidentialité (`/confidentialite.php` du site). Si l'adresse du site change, modifier `server.url`, l'adresse de `mobile/www/offline.js` et le test, puis publier une nouvelle version.

## Attention

**L'identifiant `com.noorwan.site` ne change plus après la première publication** sur Google Play : une autre valeur serait une autre application, sans les installations ni les avis. Le vérifier avant d'envoyer la première version.
