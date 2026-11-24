# Conv-020 : icônes communes et « Noorwan SARL » au pied de page (25/11/2026)

## Objectif

Brief transverse de Maestro « icônes communes et Noorwan SARL au pied de page » (M-120). Branche `chore/icones-et-pied` depuis `origin/main` (21bad95), non poussée.

## Ce qui a été fait

| Étape | Contenu | Commit |
|---|---|---|
| Icônes | Fichiers de `Maestro/annexes/chartes/charte-commune/icones/noorwan/` à la racine de `public/` : `favicon.svg`, `favicon.ico` (nouveau, répond à `/favicon.ico`), `apple-touch-icon.png` (180). Déclarés dans `app/layout/header.php` (seul `<head>` du site) avec la version par la date du fichier (`$asset`). `assets/images/favicon.svg` retiré | f21e1a6 |
| Ligne légale | `common.copy` : « © :year Noorwan SARL » (fr, en, ar) ; mentions légales : « Site édité par Noorwan SARL. », « Website published by Noorwan SARL. », « ينشر الموقع Noorwan SARL. » ; `docs/CONTENUS.md` suit | 67a6b7e |
| Tests | `tests/run.sh` : `/favicon.ico`, `/favicon.svg`, `/apple-touch-icon.png` en 200, liens versionnés, ancienne icône en 404, ligne « © année Noorwan SARL » | 19468a3 |

## Vérifications

- `tests/run.sh` avec `php -S 127.0.0.1:8010 -t public tests/router.php` : 1096 contrôles verts ; 10 échecs, tous liés à la base absente (formulaire de contact et purge), connus.

## Décisions

- **Pas de manifeste** : noorwan.com n'est pas installable ; pas d'icônes 192 et 512.
- **Icônes à la racine** comme le dit la charte, adresses relatives (le site tourne aussi sous un sous-dossier MAMP).
- **Texte changé hors de CONTENUS.md à l'origine** : la ligne légale et l'éditeur viennent du brief de Maestro (titulaire unique « Noorwan SARL ») ; CONTENUS.md mis à jour dans le même commit.

## Ce qui reste

- Relecture de la phrase arabe des mentions légales par un arabophone (nom latin gardé, comme « Noorwan » ailleurs).
- Rien sur le Mac, rien sur le VPS (fichiers statiques déployés avec le reste).
