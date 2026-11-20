# Conv-016 : page Solutions, un produit par ligne ; catégorie de Noorwan Connect (20/11/2026)

## Objectif

Brief de Maestro (20/11/2026), d'après deux décisions de Marwan : la catégorie de Noorwan Connect (« Numérique », « Digital », « رقمي ») et la disposition A de la page Solutions (un produit par ligne, image et texte alternés, même poids pour tous). Branche `feat/solutions-une-ligne` depuis `main` à jour (#10 fusionnée).

## Décisions

- **Catégorie** : posée dans `home.products.connect.cat`, comme celles des autres produits. La clé `solutions.connect_cat` et le repli `todo()` de la carte disparaissent (pas de code mort).
- **Ordre des lignes** : Inteek, Reserva, Noorwan Connect, Noor (ordre du brief), fixé dans `app/layout/products.php` (`$productRows`), indépendamment de l'ordre de `home.products`.
- **Gabarit commun** : `<article id="product-<id>" class="product-row">`, illustration puis texte dans le document (donc au-dessus sur téléphone), catégorie en petit titre du ton Solutions, nom en `h2` (les produits sont des sections de la page), texte au même corps pour tous. Inteek ajoute son texte et ses modules dans sa ligne. Ancre `#inteek` remplacée par `#product-inteek` (aucun lien ne la visait).
- **Liens** : « En savoir plus » seulement pour Noorwan Connect (seul produit qui a sa page) ; Reserva et Noor gardent « Demander une présentation » ; Inteek, détaillé sur place, n'a pas de lien, comme avant.
- **Alternance** : dès 834 px (seuil ordinateur du site), grille à deux colonnes ; une ligne sur deux, l'illustration prend `order: 1`. La grille suit le sens de la page : à gauche puis à droite en français et en anglais, à droite puis à gauche en arabe, sans aucune règle `left` ni `right`. À 768 px, une colonne comme au téléphone.
- **Même poids** : plus de carte sombre pour Noor ni de cartes claires ; toutes les lignes sur le fond de page, séparées par un filet et beaucoup d'air (88 px puis 128 px en haut et en bas).
- **Pastille « Confidentiel »** : texte `--sol-text` au lieu de `--sol-light`, trop pâle sur le fond de page clair (contraste AA, clair et sombre).
- **Miroir** : Inteek en miroir en arabe (`mirror-rtl`), comme avant ; Reserva, Noor et Noorwan Connect jamais.
- **Inchangés** : la phrase « Un seul compte… Découvrir Noorwan Connect » et le résumé « 03 Noorwan Connect » de l'accueil.

## Ce qui a été fait (commits)

1. `Donner à Noorwan Connect la catégorie « Numérique »`
2. `Présenter les produits de Solutions un par ligne`
3. `Consigner la page Solutions en lignes` (CONTENUS.md, journal, captures)

## Vérifications

- `tests/run.sh` vert, 911 contrôles : serveur intégré de PHP (`tests/router.php`, port 8010), MariaDB jetable (port 3398, droits de la CI, utilisateurs anonymes retirés), `.env` temporaire non versionné. Contrôles nouveaux ou revus : quatre lignes dans l'ordre, deux confidentielles ; ligne Inteek (catégorie, introduction, texte, cinq modules, sans lien) ; catégorie « Numérique » de Noorwan Connect ; plus de grille de cartes dans la page ni dans la feuille ; alternance dès 834 px ; propriétés logiques seulement dans les styles des lignes ; une illustration par ligne, Inteek seule en miroir ; plus aucune « catégorie de Noorwan Connect » à fournir (9 marqueurs restants : textes alternatifs des photos d'en-tête).
- Chrome sans écran (Playwright), 18 captures des lignes des produits dans `docs/Audit/solutions-une-ligne/` : 390, 768 et 1440 px, français, anglais, arabe, clair et sombre. Aucun débordement horizontal, aucune erreur de console ; position des illustrations mesurée : au-dessus à 390 et 768 px, gauche, droite, gauche, droite à 1440 px (droite, gauche… en arabe).

## Ce qui reste

- Marwan : relire et fusionner ; dire si la phrase « Découvrir Noorwan Connect » sous l'introduction et le résumé « 03 Noorwan Connect » de l'accueil restent.
- Images des trois en-têtes et leurs textes alternatifs (inchangé depuis Conv-015).
- Aucun réglage nouveau sur le VPS.

## Pièges

- MariaDB local crée des utilisateurs anonymes (`''@'localhost'`) qui prennent le pas sur `noorwan_site_maint'@'%'` : les retirer avant les tests, sinon refus d'accès dans la purge.
- Le contrôle des mots interdits de `tests/run.sh` parcourt aussi les commentaires du code : ne pas y nommer le produit de paiement confidentiel, même pour dire qu'il est absent.
