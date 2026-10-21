# noorwan-site

Site institutionnel noorwan.com. C'est un produit Noorwan (M-15, M-26) : groupe à vocation internationale, trois univers (Consulting, Solutions, Édition).

## Sources qui font foi

- Contenus : `docs/CONTENUS.md`. Aucun texte du site ne s'écarte de ce document sans validation de Marwan.
- Accueil : maquette validée `docs/maquette/maquette-accueil-v1.dc.html` (textes FR, EN, AR dans son script).
- Journal des sessions : `docs/Journal/`.

## Conventions

- PHP 8.3 sans framework, sans dépendance Composer, sans outil de build.
- Commentaires en français, code (variables, fonctions, classes, clés) en anglais.
- Aucun tiret cadratin dans les textes, dans aucune langue. Jamais « djiboutien ».
- Mobile first : tout se conçoit et se vérifie d'abord à 390 px, puis 768 px et 1440 px.
- Trois langues : FR (défaut), EN, AR (RTL). Paramètre `?lang=` conservé dans tous les liens. Les chaînes sont dans `lang/*.php` ; `t('cle')` échappe toujours la sortie, `e()` pour tout le reste.
- CSS : une seule feuille `public/assets/css/site.css`, propriétés logiques (`margin-inline`, `inset-inline`, `text-align: start`) pour que le RTL marche sans feuille séparée. Aucun style ni script en ligne (la CSP les bloque).
- Aucun cookie, aucune mesure d'audience. Le jeton du formulaire est signé, sans session.
- Aucun secret dans le dépôt : tout passe par `.env` (modèle : `.env.example`).
- SQL : PDO et requêtes préparées uniquement.

## Arborescence

- `public/` : racine web (pages et `assets/`). Rien d'autre ne doit être servi.
- `app/` : amorçage, i18n, gabarits, classes (`Db`, `Csrf`, `RateLimit`, `ContactForm`), données des livres.
- `lang/` : tableaux de chaînes `fr.php`, `en.php`, `ar.php`.
- `database/schema.sql`, `tests/run.sh`, `storage/` (non versionné : limites d'envoi).

## Git

- Une branche par chantier, fusion par `git merge --no-ff`. Pas de fusion sans relecture de Marwan.
- Messages de commit en français, à l'impératif (« Ajouter… », « Corriger… »).

## Lancer en local (MAMP)

1. `cp .env.example .env` puis renseigner les valeurs (MAMP : `DB_HOST=127.0.0.1:8889`, `root` / `root`).
2. Créer la base : `mysql -uroot -proot -h127.0.0.1 -P8889 -e "CREATE DATABASE noorwan_site CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"`, puis importer `database/schema.sql`.
3. Ouvrir `http://localhost:8888/noorwan-site/public/`.
4. Tests : `tests/run.sh`.
