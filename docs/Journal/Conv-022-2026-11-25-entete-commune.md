# Conv-022 : en-tête aligné sur Connect (25/11/2026)

## Objectif

Corrections relevées par le contrôle visuel des en-têtes de Maestro (25/11/2026) : mot-symbole, icône du bouton thème et panneau du lanceur, pour que noorwan.com ait le même en-tête que Connect. Branche `fix/entete-commune` depuis `origin/main` (97bf57f), non poussée.

## Ce qui a été fait

| Étape | Contenu | Commit |
|---|---|---|
| Mot-symbole | `.logo` : 20 px, graisse 600, interlettrage -4,5 % (21 px et 700 avant), comme les autres sites | d879c90 |
| Bouton du thème | L'icône annonce le thème vers lequel on bascule : lune en clair, soleil en sombre (l'inverse avant, seul site à le faire) ; commentaires et `docs/CONTENUS.md` suivent | ad8cbc4 |
| Lanceur dès 640 px | Panneau de 328 px (344 avant), bord de fin aligné sur celui du bouton « grille » : `site.js` pose `--launcher-end` à l'ouverture et au redimensionnement (bord gauche en arabe) ; 8 px sans script. Il débordait de 104 px à droite du bouton (jusque sous « Connexion »). Croix masquée dès 640 px, gardée au téléphone (comme Connect). Focus sur la croix, ou sur la première tuile quand elle est masquée ; la boucle de tabulation ne compte que les éléments visibles | 0c69db6 |
| Tests | `tests/run.sh` : largeur 328, alignement par `--launcher-end`, croix masquée, mot-symbole 20 px et 600, règle lune et soleil | e578ef4 |

## Vérifications

- `tests/run.sh` vert (1136 contrôles) : `php -S 127.0.0.1:8010 -t public tests/router.php`, MariaDB jetable (port 3398, droits de la CI), `.env` non versionné.
- Playwright (Chromium) à 390 et 1440 px, clair et sombre, français et arabe : mot-symbole 20 px 600 ; lune en clair, soleil en sombre ; à 1440 px panneau de 328 px qui finit au bord droit du bouton (x 1000 à 1328, bouton 1284 à 1328), en arabe qui commence au bord gauche du bouton (82) ; pas de croix à 1440, croix à 390 ; « Mon compte Connect » centré ; Menu à 4 px du bord à 390 (comme Connect) ; aucune page plus large que l'écran.

## Décisions

- Sans JavaScript (ancre `:target`), le panneau garde 8 px de marge : la largeur de « Connexion » change selon la langue, la feuille de style seule ne peut pas suivre le bouton.
- `element.style.setProperty` (CSSOM) n'est pas un style en ligne au sens de la CSP (`style-src 'self'` inchangée).

## Ce qui reste

- Rien sur le Mac ni sur le VPS (fichiers statiques).
- Déjà là avant : en arabe, le « › » de « Mon compte Connect » (pseudo-élément) ne se retourne pas.
