# Conv-002 : déploiement sur le VPS (21/10/2026, corrections du 27/10/2026)

**Cible changée le 27/10/2026 : production directe sur `https://noorwan.com`, plus de `dev.noorwan.com`** (voir « Corrections avant fusion »). Les sections suivantes décrivent la version du 21/10 ; la note technique est à jour.

Branche `feat/deploiement`, non fusionnée : relecture de Marwan, puis `git merge --no-ff feat/deploiement` et push. Tant que `DEPLOY_ENABLED` n'est pas à `true`, la poussée lance seulement les tests.

## Livré

| Palier | Commit | Contenu |
|---|---|---|
| 1 | Rendre les tests utilisables en intégration continue | `tests/run.sh` lit `BASE_URL`, `DB_*` dans l'environnement puis dans `.env` ; client MySQL de MAMP s'il existe, sinon `mysql` |
| 2 | Séparer les droits en base et purger les demandes après 3 ans | `Db::maintenance()` (`DB_MAINT_USER`), `bin/purge-contacts.php` avec `--dry-run` et une ligne de journal, tests des droits et de la purge sur dates fabriquées, `.env.example` |
| 3 | Empêcher l'indexation du site de démonstration | `X-Robots-Tag: noindex, nofollow` hors production, `robots.txt` et `sitemap.xml` produits par PHP (`app/seo.php`), routeur `tests/router.php` pour `php -S` |
| 4 | Ajouter le script de déploiement sur le VPS | `deploy/deploy.sh` adapté d'Inteek |
| 5 | Ajouter le workflow de tests et de déploiement | `.github/workflows/deploy.yml` |
| Correction | Passer la purge en requête préparée, comme le veut CLAUDE.md | `prepare()` et `execute()` au lieu de `query()` et `exec()` |
| 6 | Ajouter la note de déploiement et le journal de Conv-002 | `docs/Tech-Notes/Deploiement-VPS.md`, ce journal, arborescence de `CLAUDE.md` |

## Vérifications

- `tests/run.sh` sous MAMP : 66 contrôles au vert (le contrôle des droits est sauté en local, un seul utilisateur MySQL).
- Même suite sur le serveur intégré de PHP (`php -S ... tests/router.php`) avec une base temporaire et les deux utilisateurs aux droits exacts du VPS, comme en CI : 68 contrôles au vert. Le formulaire enregistre avec `INSERT` seul, la purge fonctionne avec `SELECT, DELETE`, l'utilisateur du site ne peut ni lire ni supprimer. Base et utilisateurs temporaires supprimés ensuite.
- `deploy/deploy.sh` dans un bac à sable (dépôt nu + clone, `flock` simulé car absent de macOS) : arrêt sans `.env`, déploiement sans changement, avance rapide, erreur de syntaxe PHP avec retour à la version de départ, refus sur fichier modifié sur place, reprise après réparation.
- Workflow : YAML valide, empreintes `known_hosts` identiques à celles d'Inteek. **Pas encore exécuté sur GitHub** : il le sera à la première poussée.

## Choix techniques à connaître

- **`robots.txt` et `sitemap.xml` dynamiques** (`public/robots.php`, `public/sitemap.php`, réécrits dans `public/.htaccess`) plutôt qu'un fichier `sitemap.xml` statique : les adresses suivent `APP_URL` et la liste `PAGES`, sans rien recopier.
- **Indexation seulement si `APP_ENV=production` est écrit** : un `.env` sans `APP_ENV` donne un site non indexé.
- **`tests/router.php`** : `php -S` ne lit pas `.htaccess` ; le routeur reproduit les deux réécritures et refuse les fichiers cachés. Commande CI : `php -S 127.0.0.1:8000 -t public tests/router.php`.
- **La purge utilise `DB_MAINT_USER`** ; s'il est vide (poste local), `DB_USER` sert aux deux.
- **`.env` vérifié avant la mise à jour du code** dans `deploy.sh` (et non après) : sans `.env`, rien ne bouge.
- **`storage/` fermé aux autres utilisateurs** (`o-rwx`) en plus du groupe `www-data` en écriture.
- **Workflow : « démonstration » = toute adresse autre que `https://noorwan.com` ou `https://www.noorwan.com`.** Le contrôle `X-Robots-Tag` s'arrête de lui-même quand `APP_PUBLIC_URL` passe à `noorwan.com`.
- **Hôte virtuel** : ligne `Header always set X-Robots-Tag` pour couvrir aussi images, CSS et polices, servies sans PHP.

## Étapes serveur pour Marwan, dans l'ordre

Détail et commandes : `docs/Tech-Notes/Deploiement-VPS.md`.

0. MAC : fusionner `feat/deploiement` dans `main` et pousser (le job `tests` doit être vert).
1. DNS : `A dev.noorwan.com` vers `212.132.106.181`.
2. VPS + GITHUB : clé de déploiement en lecture seule sur `AladdinZZ/Noorwan`, clonage dans `/var/www/noorwan-site`.
3. VPS : base `noorwan_site`, schéma, utilisateurs `noorwan_site` (`INSERT`) et `noorwan_site_maint` (`SELECT`, `DELETE`).
4. VPS : `.env` de démonstration, 640, groupe `www-data`.
5. VPS : hôte virtuel `dev.noorwan.com.conf`, `certbot --apache -d dev.noorwan.com`.
6. MAC + VPS : clé `noorwan-site-deploy` limitée à `deploy/deploy.sh`.
7. VPS : cron de purge toutes les heures (`17 * * * *`, changé le 27/10/2026 ; à l'origine 3 h 45).
8. GITHUB : `VPS_HOST`, `VPS_USER`, `VPS_SSH_KEY`, `APP_PUBLIC_URL`, puis `DEPLOY_ENABLED=true` en dernier.
9. GITHUB : « Run workflow », puis vérifications.

## Points à trancher (état au 21/10/2026)

Tranchés le 27/10/2026 : 1 (texte précisé), 2 (purge horaire des fichiers de limite), 3 (journaux sans IP), 4 (clé supprimée du Mac), 5 (sans objet : la purge tourne toutes les heures, le fuseau du VPS ne compte plus). Reste 6 (tests sur toutes les branches), plus les nouveaux points en fin de journal.

1. **Page Confidentialité et purge.** La page dit « 3 ans après votre dernier contact avec Noorwan » ; la purge compte 3 ans après la dernière demande envoyée **par le formulaire** avec la même adresse. Un échange ultérieur par e-mail ou téléphone ne repousse pas la suppression. La purge supprime donc au plus tard à la date annoncée, jamais après, mais le texte n'est pas « exactement » le comportement. Deux options : préciser le texte (« 3 ans après votre dernière demande envoyée par ce formulaire », FR, EN, AR) ou garder la formule, qui couvrira aussi le futur CRM. Texte non modifié en attendant ta décision.
2. **« Données de limitation des envois : 1 heure ».** Les fichiers de `storage/ratelimit/` ne sont effacés que lors d'un envoi suivant ; sans nouvel envoi, une empreinte peut rester plus d'une heure. À choisir : faire aussi nettoyer ces fichiers par la purge nocturne (au plus environ 25 heures), ajouter un second cron horaire, ou ajuster le texte.
3. **Journaux Apache.** Le format `combined` enregistre l'adresse IP de chaque visiteur (conservée environ 14 jours par la rotation par défaut d'Ubuntu). La page Confidentialité dit que l'adresse IP n'est jamais enregistrée (à propos du formulaire) et qu'aucune autre donnée n'est collectée. À choisir : journal sans IP (format personnalisé dans l'hôte virtuel) ou mention des journaux techniques dans la politique.
4. **Clé privée `noorwan-site-deploy` sur le Mac** après enregistrement du secret GitHub : la supprimer ou la garder pour relancer un déploiement à la main.
5. **Heure du cron** : 3 h 45 à l'heure du serveur (fuseau du VPS à vérifier, `timedatectl`).
6. **Tests à chaque poussée sur toutes les branches** : une pull request ouverte depuis une branche du dépôt lance donc les tests deux fois (poussée et pull request). Sans gravité ; à restreindre à `main` si cela gêne.

## Corrections avant fusion (27/10/2026)

| Commit | Correction |
|---|---|
| Compléter la page Confidentialité | conservation « 3 ans après votre dernière demande envoyée par ce formulaire » (comme la purge), partenaires « aucune donnée transmise à ce jour, liste publiée avant toute transmission », responsable Noorwan, hébergement IONOS ; plus aucun `[À COMPLÉTER]` (FR, EN, AR) |
| Corriger l'adresse de contact de la page Confidentialité | l'adresse est `contact@noorwan.com`, pas l'adresse Gmail du commit précédent |
| Remplacer les champs manquants des Mentions légales par un encadré | encadré « Page en cours de mise à jour » : site édité par Noorwan, `contact@noorwan.com`, serveur IONOS ; sections Éditeur, Directeur de la publication, Hébergement, Droit applicable retirées ; commentaire juriste conservé |
| Purger aussi les fichiers de limite d'envoi de plus d'une heure | `RateLimit::purgeExpired()`, nombre de fichiers dans la ligne de journal et dans `--dry-run`, test dédié |
| Déployer directement en production sur noorwan.com | note technique (étape 0 bis sauvegarde, DNS en lecture seule, hôte virtuel `noorwan-site.conf`, certbot pour les deux noms, journaux sans IP, suppression de la clé privée à l'étape 6), workflow sur `https://noorwan.com` |
| Lancer la purge toutes les heures | cron `17 * * * *` au lieu de `45 3 * * *` dans la note technique (étape 7) |

Vérifications :

- `tests/run.sh` sous MAMP : 85 contrôles au vert (pages légales sans marqueur, adresse et encadré dans les 3 langues, purge des fichiers de limite en simulation puis réelle).
- Hôte virtuel de la note testé avec l'Apache de MAMP (2.4.62, port de test, copie isolée) : `apache2ctl -t` équivalent OK, `www` renvoie `301 https://noorwan.com/<chemin>?<requête>`, journal d'accès et journal d'erreurs sans adresse IP. `%b` (taille de la réponse) au lieu de `%O` pour ne pas dépendre du module `logio`.
- Workflow : YAML valide. **Toujours pas exécuté sur GitHub.**
- DNS lu le 22/10/2026 : `noorwan.com` et `www` déjà en `A 212.132.106.181`, aucun `AAAA`, MX `mx00/mx01.ionos.fr`. **L'ancien site tourne donc déjà sur ce VPS** : la bascule se fait par les hôtes virtuels Apache (étape 5), pas par le DNS.

Points à trancher :

1. **Fichiers de limite d'envoi et « 1 heure » : tranché le 27/10/2026.** purge toutes les heures (`17 * * * *`). Un fichier sans nouvel envoi disparaît désormais entre 1 et 2 heures après le dernier envoi (25 heures au plus avec la purge nocturne). Le journal `purge.log` passe à 24 lignes par jour (de l'ordre de 1 Mo par an).
2. **Hébergement et transferts hors UE** : la phrase `[À COMPLÉTER]` sur le lieu d'hébergement a été retirée de la Confidentialité faute d'information. À rétablir quand la localisation du serveur IONOS est connue.
3. **Mentions légales** : raison sociale, siège, immatriculation, directeur de la publication, adresse de l'hébergeur et droit applicable restent à fournir ; l'encadré les remplace en attendant.
4. **Ancien site** : il disparaît à la bascule, `/test/` compris. S'il enregistrait les messages de son formulaire dans une base, l'étape 0 bis l'exporte ; décider ensuite de leur sort.
5. **Coupure HTTPS** : une à deux minutes avec un mauvais certificat entre la désactivation de l'ancien hôte virtuel et la fin de certbot (étape 5). À faire à une heure creuse.
6. **`AGENTS.md`** : copie de `CLAUDE.md` créée par Codex Desktop le 22/10/2026. Tranché le 27/10/2026 : réduit à une ligne qui renvoie à `CLAUDE.md` et versionné, pour qu'il n'y ait qu'une seule source de règles.

