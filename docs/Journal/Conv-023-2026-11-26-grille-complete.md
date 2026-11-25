# Conv-023 : grille des sites complète et icônes (26/11/2026)

## Objectif

Brief Maestro `_brief_grille-complete-maestro-crm-noorwan.md` (M-124, M-128) : même grille des sites que Reserva, Inteek, OnePay et Connect. Branche `fix/grille-complete` depuis `origin/main` (6a78a01), non poussée.

## Ce qui a été fait

| Étape | Contenu | Commit |
|---|---|---|
| Icônes | `public/images/sites/{noorwan,connect,reserva,inteek,onepay}.svg`, copies sans modification des `favicon.svg` de la charte commune (Connect au point vert #30D158) ; jamais sous `/icons/` | b91b5c0 |
| Liste toujours complète | `launcher_sites()` : une adresse de `.env` non https prend l'adresse par défaut au lieu de masquer le site ; pastille de Connect #248A3D ; chemin de l'icône par site | 499eabd |
| Tuiles | Icône de 48 px (coins de l'icône, trait fin en sombre) et pastille couleur et lettre cachée ; `site.js` pose `.is-failed` si l'image ne se charge pas (écoute en capture, et image déjà en erreur rattrapée), la pastille la remplace | 80bcb0a |
| Tests | `tests/run.sh` : adresse non https, icônes, absence de `public/icons`, couleurs de Connect, icônes servies, repli, groupe de fin de l'en-tête | 374757f |

## Points du brief

1. Liste publique complète, ordre Noorwan, Connect, Reserva, Inteek, OnePay, adresses par défaut, `.env` prioritaire, Noorwan marqué et vers son accueil : fait.
2. Personne connectée : sans objet, noorwan.com n'a pas de session Connect.
3. Icônes et repli par pastille : fait.
4. « CRM » : sans objet, le Référentiel n'arrive que par la liste de Connect.
5. `img-src` : sans objet, les icônes sont servies par le site (`'self'`).
6. Groupe de fin en bout de ligne : déjà le cas (la marge automatique du logo pousse le groupe), désormais testé.

## Vérifications

- `tests/run.sh` vert (1144 contrôles) : `php -S 127.0.0.1:8010 -t public tests/router.php`, MariaDB jetable (port 3398, droits de la CI).
- Playwright (Chromium) à 390 et 1440 px, clair et sombre, français et arabe, grille ouverte : cinq icônes chargées, aucune page plus large que l'écran, groupe de fin à 4 px du bord (390) et 24 px (1440), aucune erreur de console. Repli : icône de Reserva en 404, pastille affichée. Captures dans `Conv-023-captures/`.

## Décisions

- Connect garde l'adresse par défaut `https://compte.noorwan.com/home` (comme Reserva et Inteek) ; le brief écrit `https://compte.noorwan.com`, même origine.
- Sans JavaScript, une icône qui ne se charge pas laisse une case vide (la pastille ne paraît qu'avec le script).

## Ce qui reste

- Rien sur le Mac ni sur le VPS (fichiers statiques).
