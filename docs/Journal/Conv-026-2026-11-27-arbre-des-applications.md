# Conv-026 : arbre des applications sur l'accueil (27/11/2026)

## Objectif

Demande de Marwan, brief de Maestro : « une illustration d'un arbre avec les différentes applications » sur noorwan.com. Branche `feat/arbre-des-applications` depuis `origin/main` (3c0cf7f).

## Décisions

- **Place** : accueil, section `#arbre` juste après les trois résumés d'univers (Consulting, Solutions, Connect), avant « De l'idée à l'action ». L'arbre rassemble ce que ces trois écrans viennent de présenter ; il ne coupe ni la méthode ni « Pourquoi Noorwan ».
- **Textes** : rien dans `docs/CONTENUS.md` pour cette section : titre et phrase en `[À FOURNIR : …]` (`home.tree_h`, `home.tree_text`, trois langues), affichés par `todo()`. Les seuls mots du dessin sont des noms déjà sur le site (Noorwan, Consulting, Solutions, Édition, Reserva, Inteek, Connect).
- **Contenu de l'arbre** : tronc Noorwan (sans lien), trois branches vers leur page (`/consulting`, `solutions.php`, `edition.php`, langue gardée), et sous Solutions les applications publiques Reserva, Inteek, Connect (CONTENUS.md : Connect est un produit de Solutions). Liste fermée `TREE_APPS` dans `app/bootstrap.php` : jamais OnePay, jamais Noor ni son moteur, même si le lanceur évolue.
- **Liens des applications** : adresse du lanceur (`launcher_sites()`, réglable par `LAUNCHER_*_URL`), puis `?lang=` (nouvelle fonction `with_lang()`, lu par Reserva et le Compte, ignoré par Inteek) et `?via=launcher` (`with_origin()`, comme la grille). `rel="noopener"`.
- **Dessin** : SVG original dans la page, décoratif (`aria-hidden`), deux versions (verticale 360 x 520 au téléphone, large 1000 x 560 dès 768 px). Noms et liens en HTML par-dessus, placés en pourcentage du dessin (`.tree-at-*`) : texte sélectionnable, traduit, nommé pour les lecteurs d'écran (liste imbriquée tronc, branches, applications, nommée par le titre). Icônes : copies de la famille commune déjà servies (`images/sites/<clé>.svg`) avec la pastille de secours de la grille (`site.js`).
- **Charte** : fond blanc (`--paper`), branches et feuilles aux couleurs des univers, écorce et houppier par deux nouvelles variables (`--tree-bark`, `--tree-canopy`) dans les trois blocs de thème. Pastilles de 44 px au moins. Miroir du dessin en arabe, positions en `inset-inline-start`. Aucune animation ni transition (rien à couper pour `prefers-reduced-motion`). Aucun style ni script en ligne.

## Ce qui a été fait

| Étape | Contenu | Commit |
|---|---|---|
| Section | `app/layout/tree.php`, `tree_apps()` et `with_lang()` dans `app/bootstrap.php`, appel dans `public/index.php`, clés `home.tree_*` des trois langues, styles dans `site.css` | 22c03b5 |
| Tests | Section « 8. Arbre des applications » de `tests/run.sh` (place, liens, langue, liste fermée sans OnePay ni Noor ni Cerebro même avec toutes les adresses réglées, icônes, dessins décoratifs, aucun style ni script ni image tierce, propriétés logiques, thème sombre) ; contrôles « À FOURNIR » mis à jour (accueil : deux, tous dans l'arbre ; `lang/` : neuf) | 7635809 |
| Documentation | Ce journal, `docs/CONTENUS.md`, `CLAUDE.md` (gabarit et règle de l'arbre), captures | (ce commit) |

## Vérifications

- `tests/run.sh` vert (1255 contrôles) : `php -S 127.0.0.1:8010 -t public tests/router.php`, MariaDB jetable (port 3398, droits de la CI).
- Chrome sans tête (Playwright), 390, 768 et 1440 px, fr et ar, clair et sombre : aucune page plus large que l'écran, aucun nœud hors de l'écran, aucun chevauchement entre nœuds, toutes les cibles de 44 px au moins, aucune erreur de console.
- Captures (en-tête fixe masqué pour la prise de vue) : `docs/Audit/arbre-des-applications/arbre-<largeur>-<langue>-<clair|sombre>.png` (douze images). Le brief disait `docs/audit/` : le dossier existant `docs/Audit/` est gardé, un second dossier ne différant que par la casse casserait le dépôt sur le Mac.

## Ce qui reste

- Marwan : titre et phrase de la section (trois langues).
- En arabe, le texte à fournir (en français) s'affiche avec ses crochets dans le sens de l'arabe, comme les autres textes à fournir ; il disparaîtra avec le vrai texte.
- Mac et VPS : aucune commande (ni migration ni build).

## Pièges rencontrés

- Un nœud placé en `transform` devient le bloc de référence de ses enfants positionnés : le tronc est donc un `span` positionné, pas le `li` qui contient les branches.
- `translate(-50%)` ne suit pas le sens de lecture : en arabe, le décalage horizontal des nœuds passe à `+50%`.
