# Conv-025 : installer noorwan.com sans magasin (26/11/2026)

## Objectif

Décision M-132 de Marwan (« sans avoir besoin de passer sur le store ») : noorwan.com s'installe depuis le navigateur comme une application, avec le même comportement que Reserva (Conv 198, branche `feat/installer-sans-magasin` de Reserva, note `Installer-Sans-Magasin` de Maestro). Branche `feat/installer-sans-magasin` depuis `origin/main` (defe250).

## Ce qui a été fait

| Étape | Contenu | Commit |
|---|---|---|
| Application installable | `public/manifest.json` : `id`, `start_url` et `scope` à `./` (même fichier à la racine et dans le sous-dossier MAMP), `display: standalone`, `theme_color` #1D1D1F, `background_color` #F6F5F1, `prefer_related_applications` faux, icônes de la famille commune (`public/images/icons/`, copies de `charte-commune/icones/noorwan`, maskable 192 réduite de la 512), captures `narrow` 540 x 960 et `wide` 1280 x 720 de l'accueil. Déclaré par `<link rel="manifest" href="manifest.json" crossorigin="use-credentials">`. `public/sw.js` : garde seulement `offline.html`, `assets/css/offline.css` et l'icône 192 ; navigations par le réseau, page hors ligne en secours ; aucune page ni réponse gardée. Page hors ligne trilingue, sans script ni style en ligne. CSP : `worker-src 'self'; manifest-src 'self'`. | d637056 |
| Barre et menu | `app/layout/install.php` après le bandeau des cookies (attribut `hidden`, rien sans JavaScript). Fonctions `install_available()`, `install_postponed()`, `install_origin()`, `install_auto()`, `with_origin()`, `in_native_app()` dans `app/bootstrap.php`. `site.js` : enregistre le service worker, garde `beforeinstallprompt`, ouvre la barre d'elle-même seulement sur un téléphone (Android après l'événement, iPhone et iPad après le chargement) quand `data-auto` vaut 1, attend le choix des cookies (événement `nw-consent-closed` envoyé par le script du consentement), « Plus tard » en cookie `nw_install_later=1` six mois, entrée « Installer l'application » du volet du menu (lance l'installation ou montre le mode d'emploi, même après « Plus tard »), étape `app_installed` seulement avec `a1`. Textes dans `lang/*.php` (`install.*`, `offline.*`), section `nw_install_later` de la page Cookies. Application Android : `appendUserAgent` « NoorwanApp/Noorwan ». | 04a68ad |
| Grille des sites | `?via=launcher` sur Connect, Reserva, Inteek et OnePay ; jamais sur la tuile de noorwan.com ni sur « Mon compte Connect ». | 44ee123 |
| Tests | Section « 7. Installer le site sans magasin (M-132) » de `tests/run.sh` ; anciens contrôles de la grille mis à jour (`?via=launcher`). | 4f13704 |

## Vérifications

- `tests/run.sh` vert (1231 contrôles) : `php -S 127.0.0.1:8010 -t public tests/router.php`, MariaDB jetable (port 3398, droits de la CI, utilisateurs anonymes supprimés avant).
- Chrome (Playwright), émulation Pixel 8 à 390 px, profil persistant : `Page.getAppManifest` sans erreur, `Page.getInstallabilityErrors` vide (aucun obstacle à l'installation), service worker actif sur `/`, page « Pas de connexion » servie hors réseau.
- Comportement (événement `beforeinstallprompt` simulé) : barre ouverte sur l'accueil et par `?via=qr`, `?via=launcher`, absente sur une autre page, sur ordinateur, sans JavaScript et avec l'agent NoorwanApp ; « Installer » ouvre la fenêtre du navigateur ; « Plus tard » pose `nw_install_later=1` pour 180 jours et la barre ne revient pas ; l'entrée du menu la rouvre (iPhone) ; avec Tag Manager, la barre attend « Tout refuser » puis vient. Aucune erreur de console, aucune page plus large que l'écran.
- Captures 390 px, clair et sombre, français et arabe, formes Android et iPhone, volet du menu, page hors ligne : `Conv-025-captures/`.

## Écarts au modèle de Reserva

- Cookie « Plus tard » nommé `nw_install_later` (demande du brief) et non `<site>_install_later` comme le dit la note : il est posé sur l'hôte seul, donc ne se partage pas avec les autres sites.
- Pas de QR code sur noorwan.com : `?via=qr` est reconnu, aucune adresse n'est à marquer ici.
- L'application Android est reconnue par son agent seulement (pas de `window.Capacitor`) : le site ne nomme pas l'application (règle M-122 et test « le site ne connaît pas l'application »).
- Entrée du menu cachée sans JavaScript (Reserva mène alors à une page « Application mobile », que noorwan.com n'a pas) ; pas d'entrée dans le pied de page ni de toast « installée ».
- Barre pleine largeur comme le bandeau des cookies du site (Reserva : carte en bas à gauche sur grand écran).

## Ce qui reste

- Mac : `cd mobile && npx cap sync android` puis une nouvelle version de l'application Android pour l'agent NoorwanApp/Noorwan (sinon la barre et l'entrée du menu restent possibles dans l'application, l'installation n'y aboutit pas).
- VPS : aucune commande.
- Textes arabes et section `nw_install_later` de la page Cookies à faire relire (avec les autres pages légales).
