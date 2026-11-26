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
- Choix de cookies commun à tous les sites Noorwan (M-129, règle `charte-commune/consentement.md` de Maestro, mêmes choix que Connect) : cookie `nw_consent`, valeur `v1.a{0|1}.m{0|1}` (a : mesure d'audience, m : publicité), six mois (`Max-Age=15552000`), `Path=/`, `SameSite=Lax`, `Secure` en https, jamais `HttpOnly`, posé sur `.noorwan.com` quand l'hôte est noorwan.com ou un sous-domaine, sinon sur l'hôte seul. Lu et écrit par les seules fonctions `consent_*()` de `app/bootstrap.php` ; ancienne valeur du site (« granted », « denied ») recopiée en `v1.a1.m0` ou `v1.a0.m0` à la première page vue, l'ancien cookie de l'hôte effacé. Bandeau en bas sans voile (« Tout accepter », « Tout refuser » de même forme, « Choisir ») et volet `#consent-panel` de fin de ligne (deux interrupteurs, « Enregistrer »), rouvert par « Gérer les cookies » ; sans JavaScript, ancre et `public/consent.php`. Google Tag Manager (`GTM_ID` dans `.env`, vide = ni bandeau, ni volet, ni lien, et la CSP reste fermée à Google) seulement après `a1` ; mode consentement de Google tout refusé par défaut, puis `analytics_storage` accordé et la publicité seulement si `m1`. La CSP ne s'ouvre qu'à `www.googletagmanager.com`, `*.google-analytics.com` et `*.analytics.google.com`. Le jeton du formulaire est signé, sans session.
- Thème du visiteur (socle du lanceur L6) : choix gardé six mois dans le cookie `nw_theme` (`dark` ou `light`, non chiffré, sans donnée personnelle), posé par `theme-init.js` ; jamais `localStorage` seul. Avec `nw_consent`, ce sont les seuls cookies du site hors Google Analytics.
- OnePay n'apparaît nulle part (confidentiel), sauf dans le lanceur des sites (M-123) ; Noor est marqué « Confidentiel ». Contrôlé par `tests/run.sh`.
- Icônes communes (M-120) : `favicon.svg`, `favicon.ico`, `apple-touch-icon.png` à la racine de `public/`, déclarées dans `app/layout/header.php` avec leur version (date du fichier). Ligne légale « © année Noorwan SARL », éditeur « Noorwan SARL ».
- Lanceur des sites (M-121) : bouton « grille » de l'en-tête, entre le thème et « Connexion », qui ouvre le volet `#launcher-panel` (plein écran en fin de ligne au téléphone, panneau sous l'en-tête dès 640 px, ancre `:target` sans JavaScript). Liste publique seulement (noorwan.com n'a pas de session Connect), par `launcher_sites()` : Noorwan (site courant, marqué, vers l'accueil), Connect (lettre « c », pastille #248A3D), Reserva, Inteek, OnePay, toujours tous les cinq (M-124) : adresses `LAUNCHER_*_URL` dans `.env` (les anciennes `ECOSYSTEM_*_URL` lues en repli), sinon adresses par défaut, https seulement (une adresse non https prend l'adresse par défaut, aucun site n'est masqué) ; chaque tuile porte l'icône du site, copie sans modification de la charte commune servie par le site (`public/images/sites/<clé>.svg`, jamais sous `/icons/`, réservé par Apache), et sa pastille couleur et lettre, montrée par `site.js` si l'icône ne se charge pas ; « Mon compte Connect » vers l'adresse de Connect, jamais déduite de `COMPTE_URL`. OnePay y paraît après Inteek (M-123, environnement de développement, `LAUNCHER_ONEPAY_URL`, défaut https://dev.onepay.noorwan.com, pastille #5B34C7 lettre « o »), jamais un autre projet confidentiel. Plus de ligne « Écosystème Noorwan » ni au pied de page ni dans le volet du menu.
- Charte commune (M-118, M-120) : en-tête fixe de 48 px (Menu, logo, langue, thème, lanceur des sites, « Connexion »), volet du menu en début de ligne, volet de connexion en fin de ligne, jamais de fenêtre surgissante. Leur script est dans `public/assets/js/site.js` ; sans JavaScript, les volets s'ouvrent par leur ancre (`:target`) et le menu des langues reste un `<details>`.
- Nom du compte (M-116) : « Connect » dans tout texte affiché, jamais « Noorwan Connect » ni « Compte Noorwan » ; le bouton est « Continuer avec Noorwan », toujours bleu. Les noms techniques (`COMPTE_*`, `/connect`, classes) ne changent pas.
- Aucun secret dans le dépôt : tout passe par `.env` (modèle : `.env.example`).
- SQL : PDO et requêtes préparées uniquement.

## Arborescence

- `public/` : racine web (pages et `assets/`). Rien d'autre ne doit être servi.
- `app/` : amorçage (CSP, nonce, `GTM_ID`, choix de consentement), i18n, gabarits (`app/layout/` : en-tête, pied de page, produits, bandeau contact, bandeau de consentement, écosystème, pages légales), classes (`Db`, `Csrf`, `RateLimit`, `ContactForm`), données des livres.
- `public/consent.php` : enregistre le choix de mesure d'audience (jeton signé, retour vers une page du site seulement).
- `lang/` : tableaux de chaînes `fr.php`, `en.php`, `ar.php`.
- `bin/purge-contacts.php` : purge des demandes de plus de 3 ans et des fichiers de limite d'envoi de plus d'une heure (ligne de commande, cron du VPS).
- `deploy/deploy.sh`, `.github/workflows/deploy.yml` : déploiement en production sur noorwan.com (`docs/Tech-Notes/Deploiement-VPS.md`).
- `mobile/` : application Android (M-122), enveloppe Capacitor 8 qui affiche noorwan.com (`package.json`, `capacitor.config.json`, page hors ligne `www/`, projet `android/`). Jamais servie ni dans `public/` ; le site reste sans outil de build hors de ce dossier ; clés de signature jamais dans le dépôt ; `npx cap` se lance depuis `mobile/` ; l'identifiant `com.noorwan.site` ne change plus après la première publication. Mode d'emploi : `docs/Tech-Notes/Application-Android.md`.
- `database/schema.sql`, `tests/run.sh`, `tests/router.php` (serveur intégré de PHP en CI), `storage/` (non versionné : limites d'envoi, journaux).

## Git

- Une branche par chantier, fusion par `git merge --no-ff`. Pas de fusion sans relecture de Marwan.
- Messages de commit en français, à l'impératif (« Ajouter… », « Corriger… »).

## Lancer en local (MAMP)

1. `cp .env.example .env` puis renseigner les valeurs (MAMP : `DB_HOST=127.0.0.1:8889`, `root` / `root`).
2. Créer la base : `mysql -uroot -proot -h127.0.0.1 -P8889 -e "CREATE DATABASE noorwan_site CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"`, puis importer `database/schema.sql`.
3. Ouvrir `http://localhost:8888/noorwan-site/public/`.
4. Tests : `tests/run.sh`.
