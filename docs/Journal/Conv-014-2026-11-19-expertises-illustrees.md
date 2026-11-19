# Conv-014 : « Nos expertises » illustrées, variante 1 (19/11/2026)

## Objectif

Brief de Maestro (19/11/2026) : appliquer la variante 1 de la planche « Nos expertises », validée par Marwan. Une carte blanche par expertise avec un pictogramme dans une pastille, puis une sixième carte sombre « Clarifier avant d'accélérer. ». Branche `feat/expertises-illustrees` depuis `main` à jour (thème sombre fusionné, #8).

## Décisions

- **Pictogrammes** : `public/assets/img/expertises/{strategy,marketing,ecommerce,web,training}.svg` et leur `-dark.svg`. Tracés repris de la planche sans retouche (grille 32 x 32, trait 2) ; chaque fichier porte aussi sa pastille de 64 px aux coins de 18 px, le pictogramme agrandi à 34 px comme sur la planche. Les couleurs sombres sont celles du brief (trait `#CDB98A`, accent `#E6D3A3`, pastille `#2A2A2C`) : elles ne viennent pas de la table de `bin/illustrations-dark.php`, qui ne lit que le dossier `img/` lui-même ; le sous-dossier `expertises/` n'est donc pas régénéré par ce script.
- **Gabarit commun** : `app/layout/expertises.php` (liste des cinq cartes et carte sombre), inclus dans la section « Nos expertises » de `public/consulting.php`. Pictogrammes servis par `illustration()` (même `<picture>` que les autres dessins, bascule du thème comprise), classe propre `expertise-icon`, donc pas de miroir en arabe.
- **Carte sombre** : `#1D1D1F` en clair ; en sombre, les cartes blanches deviennent `#1C1C1E`, presque la même couleur, d'où une variable `--motto-card` qui passe à `#000000` dans les deux blocs sombres, avec un filet (`--hairline`) pour la détacher.
- **Colonnes** : une à 390 px, deux dès 768 px, trois dès 1024 px (donc trois à 1440 px, comme le brief).
- **Note sous la liste** (`universe-note`) retirée : sa phrase est maintenant dans la carte sombre. Règle CSS supprimée, elle ne servait nulle part ailleurs.
- **Accueil non touché** : il n'a pas de section « Nos expertises » depuis la v6 (CONTENUS.md, « Quittent l'accueil : les cinq expertises ») et `tests/run.sh` vérifie qu'il n'en a pas. Le gabarit commun permet de l'y ajouter en une ligne si Marwan le décide.
- **Illustration `universe-consulting`** gardée : elle sert encore en tête de la page Consulting et dans le résumé Consulting de l'accueil.

## Ce qui a été fait (commits)

1. `Dessiner les pictogrammes des cinq expertises, en clair et en sombre`
2. `Présenter les expertises en cartes illustrées avec la carte « Clarifier avant d'accélérer. »`
3. `Contrôler les cartes des expertises et leurs pictogrammes`
4. `Consigner les expertises illustrées dans CONTENUS.md et le journal de séance`

## Vérifications

- `tests/run.sh` vert (882 contrôles) : serveur intégré de PHP (`tests/router.php`, port 8010), MariaDB jetable (port 3398, droits de la CI), `.env` temporaire non versionné. Nouveaux contrôles : cinq cartes et une carte sombre sur `/consulting` en trois langues, chaque pictogramme apparié à sa version sombre dans le même `<picture>`, titre et ligne de la carte sombre, plus de `universe-note`, fichiers servis, sans texte ni script, couleurs claires et sombres, aucune règle de miroir sur `.expertise-icon`.
- Chrome sans écran (Playwright) : section « Nos expertises » à 390, 768 et 1440 px, en français, anglais et arabe, en clair et en sombre (18 captures dans `Conv-014-captures/`). Une, deux et trois colonnes comme prévu, pictogrammes sans transformation en arabe, version sombre chargée en thème sombre et après clic sur la bascule, aucun débordement horizontal, aucune erreur de console.

## Ce qui reste

- Marwan : relire le rendu ; dire si l'accueil doit aussi porter les cartes (le brief le cite, la v6 les en a retirées) ; noter que « Clarifier avant d'accélérer. » figure deux fois sur la page Consulting (titre de la page et carte sombre), comme sur la planche.
- Fusion par Marwan ; aucun réglage nouveau sur le VPS.

## Pièges

- `grep -c '<li>'` comptait les expertises : avec une classe sur chaque `<li>`, le contrôle aurait compté zéro. Le test compte maintenant `<li class="expertise">` et la carte sombre à part.
- Le contrôle « chaque illustration a sa version sombre » de `tests/run.sh` ne lit que les noms sans `/` : les pictogrammes du sous-dossier ont leur propre contrôle.
