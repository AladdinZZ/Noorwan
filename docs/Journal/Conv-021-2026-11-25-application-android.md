# Conv-021 : application Android de noorwan.com (25/11/2026)

## Objectif

Brief transverse de Maestro « application Android » (M-122), partie noorwan.com. Branche `feat/application-android` depuis `main`, non poussée. Modèle : la branche du même nom d'Inteek, Reserva et OnePay.

## Ce qui a été fait

| Étape | Contenu | Commit |
|---|---|---|
| Paquets | `mobile/package.json` (`@capacitor/core`, `cli`, `android` en 8.x) et son verrou ; règles d'ignorance (dépendances, compilation, clés de signature) | d20b4ea |
| Réglages et page hors ligne | `mobile/capacitor.config.json` (`com.noorwan.site`, « Noorwan », `https://noorwan.com`, navigation vers `compte.noorwan.com`), `mobile/www` (page « Pas de connexion », encre et brume de la charte, bouton noir inversé en sombre) | ed00b6f |
| Projet Android | `npx cap add android` lancé depuis `mobile/` (modèle du paquet) | 426918d |
| Icônes | Lanceur carré et rond, premier plan adaptatif sur fond #1D1D1F, écrans de démarrage, depuis `favicon.svg` de la famille commune | f2dc533 |
| Barre d'état | `colors.xml` (#1D1D1F, accent bleu du groupe) et `statusBarColor` du thème | a267002 |
| Tests | section « 6. Application Android (M-122) » de `tests/run.sh` | dernier commit de code |
| Documentation | note `docs/Tech-Notes/Application-Android.md`, ce journal, CLAUDE.md | dernier commit |

## Décisions

- **Tout dans `mobile/`** : le dépôt n'a ni Composer ni outil de build, `package.json` et `node_modules` n'ont rien à faire à la racine. `webDir` vaut donc `www` (relatif à `mobile/`) et les commandes `npx cap` se lancent depuis `mobile/`. Rien de `mobile/` n'est dans `public/` (racine web), un test le vérifie.
- **Bleu du groupe (#2997FF)** pour le point du logo et l'accent, comme le favicon ; boutons noirs inversés, comme le site.
- **Pas de manifeste web** : noorwan.com n'est pas installable, l'application ne change pas cela. Le service worker n'existe pas ici.
- **Page hors ligne sans script en ligne** : la CSP du site l'interdit ; le script est un fichier voisin, avec l'adresse de `server.url` en dur.

## Vérifications

- `tests/run.sh` avec `php -S 127.0.0.1:8833 -t public tests/router.php` : section Android toute verte (24 contrôles) ; au total 1120 contrôles verts et 10 échecs, tous liés à la base absente (formulaire de contact et purge), connus.
- Pas de compilation Gradle (pas de SDK Android ici).

## Ce qui reste

- Mac : `cd mobile`, `npm install`, `npx cap sync android`, `npx cap open android`, essai sur téléphone (site, mode avion, « Continuer avec Noorwan » qui reste dans l'application), signature et envoi Play : `docs/Tech-Notes/Application-Android.md`.
- Rien sur le VPS : `mobile/` n'est pas servi (le déploiement copie le dépôt, `public/` reste la racine web).
- L'identifiant `com.noorwan.site` ne change plus après la première publication sur Google Play.

## Pièges

- `npx cap add android` écrit `capacitor.config.json` dans `mobile/android/app/src/main/assets` (ignoré par git) : refaire `npx cap sync android` après tout changement de configuration.
- Disque presque plein : cache npm et fichiers temporaires dans `/home/claude/noorwan-tmp`, supprimés à la fin ; `mobile/node_modules` (ignoré) supprimé aussi.
