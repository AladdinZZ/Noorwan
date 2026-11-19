# Conv-013 : v9, thème sombre et bascule soleil et croissant (19/11/2026)

## Objectif

Brief de Maestro (19/11/2026, demande de Marwan) : thème sombre sur tout le site, versions sombres des illustrations, bouton de bascule dans l'en-tête et le menu mobile. Branche `feat/theme-sombre` depuis `main` à jour (v8 fusionnée).

## Décisions

- **Couleurs** : toutes les valeurs sombres dans deux blocs identiques de `site.css`, `:root[data-theme="dark"]` (choix manuel) et `@media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) }` (appareil). Un test vérifie que les deux blocs restent identiques.
- **Nouveaux rôles de couleur** : `--paper` servait aussi de « texte blanc » sur le bleu et sur les boutons noirs ; il devient sombre en v9. D'où `--white` (texte sur le bleu), `--on-ink` et `--ink-hover` (boutons noirs, inversés en sombre : fond clair, texte noir), `--nav-text`, `--header-bg`, `--header-line`, `--hairline`, `--consent-bg`, `--logo-dot`. Plus aucune couleur fixe hors variables dans les rôles concernés.
- **Illustrations** : versions sombres générées par `bin/illustrations-dark.php` (table de correspondance des couleurs, aucun tracé modifié) ; `connect-code` et `noor`, dessinés pour le fond noir, sont copiés tels quels. `tests/run.sh` vérifie qu'elles sont à jour (`--check`). Servies par `<picture>` (fonction `illustration()` dans `app/bootstrap.php`) ; `picture { display: contents }` garde la mise en page.
- **Bascule** : `assets/js/theme-init.js` chargé dans `<head>` sans `defer`, avant la feuille de style (CSP inchangée : `script-src 'self'`). Le choix forcé réécrit le `media` des `<source>` et des deux `theme-color` (`all` ou `not all`) ; un `MutationObserver` corrige les images dès leur insertion pendant la lecture de la page. Bouton masqué sans JavaScript (le site suit alors l'appareil).
- **Choix oublié** : au clic, au changement de l'appareil (si l'appareil rejoint le choix gardé) et entre onglets (`storage`).
- Bouton présent à la fois dans la barre (toutes largeurs) et dans le menu mobile, comme le dit le brief.

## Ce qui a été fait (commits)

1. `Donner à chaque couleur du site sa valeur sombre`
2. `Créer la version sombre de chaque illustration`
3. `Servir les illustrations sombres par <picture>`
4. `Ajouter la bascule soleil et croissant dans l'en-tête et le menu`
5. `Contrôler le bouton du thème, les illustrations sombres et les contrastes`
6. `Consigner l'état v9 dans CONTENUS.md et le journal de séance`

## Vérifications

- `tests/run.sh` vert (842 contrôles) : serveur intégré de PHP (`tests/router.php`, port 8018), MariaDB jetable (port 3318, droits de la CI), `.env` temporaire retiré à la fin. Nouveaux contrôles : bouton dans la barre et le menu sur les 9 pages × 3 langues, `theme-init.js` avant la feuille, `theme-color` et `color-scheme`, chaque illustration de chaque page appariée à sa version sombre, versions sombres à jour, aucun cookie posé par le script, blocs sombres identiques, contraste AA en sombre.
- Chrome sans écran (Playwright) : accueil, Consulting, Solutions, Noorwan Connect, Contact, clair et sombre, 390 px (FR et AR) et 1440 px (FR). Aucun débordement horizontal, aucune erreur de console (donc aucune violation CSP). Bascule testée : appareil sombre, clic vers clair (gardé, rechargement compris), clic vers sombre (choix oublié), puis appareil passé en clair (le site suit).

## Ce qui reste

- Marwan : relire le rendu sombre et les libellés arabes ; décider si la page Cookies doit mentionner le réglage gardé dans le navigateur (pas un cookie, aucune donnée transmise).
- Fusion par Marwan ; aucune migration, aucun réglage nouveau sur le VPS.

## Pièges

- `--paper` avait deux rôles (panneau blanc et texte blanc) : le passer en sombre rendait illisibles les boutons bleus. Repérer les `color: var(--paper)` avant de changer une variable.
- Le scanner de préchargement de Chrome peut télécharger la version de l'appareil avant que le script ne force l'autre : coût d'un fichier de quelques Ko, aucun effet visible.
