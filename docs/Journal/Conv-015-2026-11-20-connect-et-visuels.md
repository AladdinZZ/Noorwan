# Conv-015 : Noorwan Connect dans Solutions, visuels sans texte (20/11/2026)

## Objectif

Brief de Maestro (20/11/2026), d'après deux décisions de Marwan : Noorwan Connect sort du menu principal et devient un produit de l'univers Solutions ; les images n'ont jamais de texte dedans, le texte est posé en HTML par-dessus. Branche `feat/connect-et-visuels` depuis `main` à jour (expertises illustrées fusionnées, #9).

## Décisions

- **Menu** : Consulting, Solutions, Contact, dans l'en-tête comme dans le menu du téléphone. Le pied de page garde Noorwan Connect (colonne Noorwan) et l'Écosystème est inchangé (D63). Sur `/connect`, aucun onglet n'est marqué actif : la page n'est plus un onglet, et `aria-current="page"` sur Solutions serait inexact.
- **Carte Noorwan Connect** : même gabarit que Reserva et Noor (`app/layout/products.php`), placée entre les deux, ton clair (produit en service). Nom en lettres latines dans les trois langues (`home.products.connect`). Aucun texte nouveau : la carte reprend l'introduction de `/connect` (`connect.lead`, lue par la clé plutôt que recopiée) et le lien « En savoir plus » vers sa page ; la catégorie, vide dans `home.products`, affiche `todo('solutions.connect_cat')`. Illustration : `connect-hero` (celle du haut de sa page), sans miroir en arabe (pas de classe `illus`).
- **Grille à trois cartes** : une colonne au téléphone, deux dès 834 px avec la dernière seule sur toute la largeur, trois dès 1024 px.
- **Phrase sous l'introduction de Solutions** (« Un seul compte pour tous les services Noorwan. Découvrir Noorwan Connect ») gardée : le brief ne la retire pas. À trancher par Marwan maintenant que la carte existe.
- **Accueil** : pas de liste des produits depuis la v6, donc pas de carte. Son résumé « 03 Noorwan Connect » reste (le brief n'en parle pas).
- **Photos d'en-tête** : un seul emplacement, `hero_photo($nom, $cleAlt)` dans `app/bootstrap.php`, utilisé par Consulting, Solutions et Édition. Fichiers `public/assets/img/<page>-hero-1440.webp` et `<page>-hero-780.webp` (convention de la photo de contact, `contact-reunion-600.webp` et `-1200.webp`), `srcset` 780w et 1440w, `sizes="100vw"`, dimensions lues sur la grande image, `fetchpriority="high"`. Tant qu'une des deux largeurs manque, la fonction rend une chaîne vide et la page garde son rendu ; Consulting garde alors son illustration (`universe-consulting`), qui disparaît quand la photo arrive. Classe `has-photo` sur l'en-tête : image en fond (`object-fit: cover`), voile noir dégradé, titre, introduction et boutons en blanc dans les deux thèmes (couleurs fixes `--night-*` et `--white`, donc rien à ajouter aux blocs sombres), bouton principal blanc. Jamais en miroir en arabe.
- **Textes alternatifs** : `consulting.hero_alt`, `solutions.hero_alt`, `edition.hero_alt` restent en `[À FOURNIR : …]` dans les trois langues, faute d'avoir vu les images.

## Ce qui a été fait (commits)

1. `Retirer Noorwan Connect du menu principal`
2. `Présenter Noorwan Connect parmi les produits de Solutions`
3. `Préparer les photos d'en-tête des pages Consulting, Solutions et Édition`
4. `Consigner Noorwan Connect dans Solutions et les photos d'en-tête` (CONTENUS.md, journal, captures)

## Vérifications

- `tests/run.sh` vert, 903 contrôles : serveur intégré de PHP (`tests/router.php`, port 8010), MariaDB jetable (port 3398, droits de la CI), `.env` temporaire non versionné. OnePay absent, Noor et Reserva « Confidentiel ». Nouveaux contrôles : menu à trois onglets (ordinateur et téléphone), aucun lien ni onglet actif Noorwan Connect dans le menu de `/connect` ; carte Noorwan Connect (nom latin, introduction, catégorie surlignée, lien, illustration, pas de badge confidentiel) ; grille à trois cartes ; nombre exact de `[À FOURNIR]` dans `lang/` (12) ; en-têtes inchangés sans image ; avec des images d'essai générées par GD dans un dossier temporaire (`HERO_PHOTO_DIR`) : classe, `srcset`, texte alternatif, dimensions, titre en HTML après l'image, plus d'illustration en tête de Consulting, rien si une seule largeur est déposée ; quand une vraie photo sera déposée : largeur exacte et moins de 300 Ko.
- Chrome sans écran (Playwright), 54 captures dans `docs/Audit/connect-et-visuels/` : accueil (haut de page, menu ouvert au téléphone), grille des produits de Solutions, haut de la page Consulting, à 390, 768 et 1440 px, en français, anglais et arabe, en clair et en sombre. Aucun débordement horizontal, aucune erreur de console. Quatre captures `essai-image-provisoire-*` montrent l'en-tête avec une image d'essai (dégradé sans texte, non versionnée, retirée après la capture).

## Quand l'image Canva arrive (Mac, dossier du dépôt)

Exporter l'image en PNG sans texte, au moins 1440 px de large, puis (ImageMagick, `brew install imagemagick`) :

```
magick consulting-hero.png -resize 1440x -strip -quality 78 public/assets/img/consulting-hero-1440.webp
magick consulting-hero.png -resize 780x -strip -quality 78 public/assets/img/consulting-hero-780.webp
```

Ou avec `cwebp` (`brew install webp`) : `cwebp -q 78 -resize 1440 0 consulting-hero.png -o public/assets/img/consulting-hero-1440.webp`, puis la même chose avec `780`. Même chose pour `solutions-hero` et `edition-hero`. Écrire ensuite `consulting.hero_alt` (et les autres) dans `lang/fr.php`, `en.php`, `ar.php`, et ajuster le contrôle « rien d'autre » de `tests/run.sh` (nombre de `[À FOURNIR]` restants). Viser moins de 300 Ko par fichier (contrôlé).

## Ce qui reste

- Marwan : catégorie de Noorwan Connect ; images des trois en-têtes et leurs textes alternatifs ; dire si la phrase « Découvrir Noorwan Connect » sous l'introduction de Solutions doit rester à côté de la carte, et si le résumé « 03 Noorwan Connect » de l'accueil doit rester tel quel maintenant que Connect est dans Solutions.
- Arabe à relire par un arabophone (aucun texte arabe nouveau, hors marqueurs `[À FOURNIR]`).
- Fusion par Marwan ; aucun réglage nouveau sur le VPS.

## Pièges

- `add_style_tag` de Playwright est refusé par la CSP (`style-src 'self'`) : pour masquer l'en-tête collant pendant la capture d'un bloc, passer par `element.style` en script.
- Une capture d'élément avec l'en-tête collant le fait apparaître au milieu de l'image : le masquer pendant la capture.
