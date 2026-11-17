# Conv-010 : v6, une page par onglet, Consulting a sa page, Édition rangée, fond blanc cassé (17/11/2026)

## Objectif

Brief v6 de Maestro (17/11/2026, d'après huit constats de Marwan) : navigation cohérente, page Consulting, Édition présentée dans Consulting, Inteek une seule fois sur Solutions, Reserva en « eBusiness », fond moins blanc, bandeau final de `/connect`, Compte Noorwan retiré de l'écosystème. Branche `feat/v6-navigation` depuis `origin/main` (v5 bis fusionnée), sans poussée.

## Décisions

- **Une page par onglet** (choix de Maestro) : menu Consulting, Solutions, Noorwan Connect, Contact. L'accueil résume Consulting, Solutions et Noorwan Connect en un écran chacun (textes existants) avec « En savoir plus ». Contact reste le bandeau final.
- **Page `/consulting`** (réécriture `.htaccess` et `tests/router.php`, comme `/connect`) : contenu de l'ancienne section de l'accueil, puis « Accompagnement et édition » (livres en bref, lien vers la page Édition). Seuls nouveaux libellés : « Noorwan Consulting », « Nos expertises », « Accompagnement et édition » (ce dernier venant du brief). L'accompagnement à l'écriture n'est décrit nulle part : `[À FOURNIR : …]`, surligné, en français dans les trois langues.
- **Quittent l'accueil** : expertises, grille des produits, écran Édition, étagère {méta}Physique. Les anciennes ancres (`#consulting`, `#edition-univers`, `#edition`) portent `data-hash-redirect` ; `site.js` envoie vers `/consulting` ou `/consulting#accompagnement`, en gardant la langue.
- **Page Édition** : hors menu, gardée dans le pied de page et le plan du site (9 pages).
- **Solutions** : Inteek présenté une fois, en détail, avant les autres produits, avec l'illustration de son ancienne carte. **Choix de l'exécutant, à confirmer** : la carte Noorwan Édition quitte aussi la grille (l'Édition étant dans Consulting) ; la grille garde Reserva et Noor, ce qui évite aussi un trou à 1440 px. `edition.svg` et les chaînes `home.products.edition` sont retirés (pas de code mort ; git garde l'historique).
- **Fond blanc cassé** : variable `--page` `#F6F5F1` pour le fond, `--mist` `#EEEDE8`, `--muted` `#66666B` pour garder AA ; `--paper` reste blanc pour les panneaux et le texte sur fond sombre. Contrôle de contraste ajouté à `tests/run.sh`.
- **Écosystème** : entrée `account` et `ECOSYSTEM_ACCOUNT_URL` retirées ; une ancienne variable restée dans un `.env` est sans effet.

## Ce qui a été fait (commits)

1. `Retirer « Consulting, Solutions, Édition » au-dessus de la devise de l'accueil`
2. `Créer la page Consulting à l'adresse /consulting, avec « Accompagnement et édition »`
3. `Mener chaque onglet du menu à sa page : Consulting, Solutions, Noorwan Connect, Contact`
4. `Résumer chaque onglet sur l'accueil avec « En savoir plus » vers sa page`
5. `Présenter Inteek une seule fois sur la page Solutions`
6. `Remplacer la catégorie « Réservation » de Reserva par « eBusiness »`
7. `Titrer le bandeau final de /connect « Créez votre compte Noorwan Connect »`
8. `Retirer le Compte Noorwan du bloc « Écosystème Noorwan » et ECOSYSTEM_ACCOUNT_URL`
9. `Passer le fond clair en blanc cassé, contraste AA gardé`
10. `Mettre les tests à jour pour la v6`
11. `Consigner l'état v6 du 17/11/2026 dans CONTENUS.md`, puis ce journal.

## Vérifications

- `tests/run.sh` vert, 566 contrôles, deux fois (`COMPTE_LINK_ENABLED` à `true` puis absent) : serveur intégré de PHP sur 127.0.0.1:8000 avec `tests/router.php`, MariaDB jetable (port 3307, utilisateurs et droits de la CI), `.env` temporaire retiré à la fin. Sur `origin/main`, avant les changements : vert.
- Anciennes ancres vérifiées dans Chrome sans tête (Playwright) : `index.php?lang=en#consulting` mène à `consulting?lang=en`, `#edition` et `#edition-univers` à `consulting?lang=…#accompagnement`, `#solutions` et `#methode` ne bougent pas.
- Captures pleine page 390 et 1440 px, clair et sombre (accueil FR et EN, Consulting FR et AR, Solutions FR, `/connect` FR lien activé) : aucun débordement horizontal. Clair et sombre identiques : le site n'a pas de thème sombre.

## Ce qui reste

- Marwan : relire les nouveaux libellés (CONTENUS.md, section v6) et fournir le texte de l'accompagnement à l'écriture ; arabe à relire (« eBusiness » laissé en latin).
- Marwan, à trancher : la carte Noorwan Édition doit-elle revenir dans la grille de Solutions ? Faut-il un thème sombre (les captures « sombre » montrent le même rendu) ?
- Fusion par Marwan ; aucune migration, aucun réglage nouveau sur le VPS. `ECOSYSTEM_ACCOUNT_URL` peut être retirée du `.env` du serveur (sans effet sinon).

## Pièges

- `"    'solutions' => ["` apparaît aussi, en sous-chaîne, dans `home.univers` (indentation plus profonde) : pour insérer avant la clé de premier niveau, chercher la ligne entière.
- Capture pleine page avec images `loading="lazy"` : il faut faire défiler la page avant la capture, sinon couvertures et illustrations restent vides.
- Un `cat >> /dev/null` égaré dans une commande attend l'entrée standard et bloque l'outil jusqu'au délai.
