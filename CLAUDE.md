# noorwan-site

Site institutionnel noorwan.com. C'est un produit Noorwan (M-15, M-26) : groupe à vocation internationale, trois univers (Consulting, Solutions, Édition).

## Sources qui font foi

- Contenus : `docs/CONTENUS.md`. Aucun texte du site ne s'écarte de ce document sans validation de Marwan.
- Direction visuelle : maquette A épurée (M-56), validée par Marwan le 6/11/2026 (copie chez Maestro, `briefs/maquettes-noorwan-site/`) : blanc, grande typographie, un message par écran. L'ancienne maquette `docs/maquette/maquette-accueil-v1.dc.html` reste pour l'historique des textes.
- Texte manquant : jamais inventé. Il reste en `[À FOURNIR : …]` dans `lang/*.php`, affiché surligné par `todo('cle')`.
- Journal des sessions : `docs/Journal/`.

## Conventions

- PHP 8.3 sans framework, sans dépendance Composer, sans outil de build.
- Commentaires en français, code (variables, fonctions, classes, clés) en anglais.
- Aucun tiret cadratin dans les textes, dans aucune langue. Jamais « djiboutien ».
- Mobile first : tout se conçoit et se vérifie d'abord à 390 px, puis 768 px et 1440 px.
- Trois langues : FR (défaut), EN, AR (RTL). Paramètre `?lang=` conservé dans tous les liens. Les chaînes sont dans `lang/*.php` ; `t('cle')` échappe toujours la sortie, `e()` pour tout le reste.
- CSS : une seule feuille `public/assets/css/site.css`, propriétés logiques (`margin-inline`, `inset-inline`, `text-align: start`) pour que le RTL marche sans feuille séparée. Aucun style en ligne. Aucun script en ligne, sauf l'amorçage de Tag Manager, qui porte le nonce de la requête (`csp_nonce()`) ; jamais `unsafe-inline`.
- Mesure d'audience seulement avec accord (M-59) : Google Tag Manager (`GTM_ID` dans `.env`, vide = rien n'est chargé et la CSP reste fermée à Google) n'est chargé qu'après « Accepter » ; mode consentement de Google à `denied` par défaut. Le choix est gardé six mois dans `nw_consent`, seul cookie du site hors Google Analytics, posé par `public/consent.php` ; « Gérer les cookies » le rouvre. La CSP ne s'ouvre qu'à `www.googletagmanager.com`, `*.google-analytics.com` et `*.analytics.google.com`. Le jeton du formulaire est signé, sans session.
- OnePay n'apparaît nulle part (confidentiel) ; Noor est marqué « Confidentiel ». Contrôlé par `tests/run.sh`.
- Pied de page « Écosystème Noorwan » (D63) : adresses `ECOSYSTEM_*_URL` dans `.env`, entrée sans adresse masquée, noorwan.com nommé sans lien, jamais de projet confidentiel.
- Aucun secret dans le dépôt : tout passe par `.env` (modèle : `.env.example`).
- SQL : PDO et requêtes préparées uniquement.

## Arborescence

- `public/` : racine web (pages et `assets/`). Rien d'autre ne doit être servi.
- `app/` : amorçage (CSP, nonce, `GTM_ID`, choix de consentement), i18n, gabarits (`app/layout/` : en-tête, pied de page, produits, bandeau contact, bandeau de consentement, écosystème, pages légales), classes (`Db`, `Csrf`, `RateLimit`, `ContactForm`), données des livres.
- `public/consent.php` : enregistre le choix de mesure d'audience (jeton signé, retour vers une page du site seulement).
- `lang/` : tableaux de chaînes `fr.php`, `en.php`, `ar.php`.
- `bin/purge-contacts.php` : purge des demandes de plus de 3 ans et des fichiers de limite d'envoi de plus d'une heure (ligne de commande, cron du VPS).
- `deploy/deploy.sh`, `.github/workflows/deploy.yml` : déploiement en production sur noorwan.com (`docs/Tech-Notes/Deploiement-VPS.md`).
- `database/schema.sql`, `tests/run.sh`, `tests/router.php` (serveur intégré de PHP en CI), `storage/` (non versionné : limites d'envoi, journaux).

## Git

- Une branche par chantier, fusion par `git merge --no-ff`. Pas de fusion sans relecture de Marwan.
- Messages de commit en français, à l'impératif (« Ajouter… », « Corriger… »).

## Lancer en local (MAMP)

1. `cp .env.example .env` puis renseigner les valeurs (MAMP : `DB_HOST=127.0.0.1:8889`, `root` / `root`).
2. Créer la base : `mysql -uroot -proot -h127.0.0.1 -P8889 -e "CREATE DATABASE noorwan_site CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"`, puis importer `database/schema.sql`.
3. Ouvrir `http://localhost:8888/noorwan-site/public/`.
4. Tests : `tests/run.sh`.
