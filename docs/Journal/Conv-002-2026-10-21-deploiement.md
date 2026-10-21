# Conv-002 : déploiement sur dev.noorwan.com (21/10/2026)

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
7. VPS : cron de purge à 3 h 45.
8. GITHUB : `VPS_HOST`, `VPS_USER`, `VPS_SSH_KEY`, `APP_PUBLIC_URL`, puis `DEPLOY_ENABLED=true` en dernier.
9. GITHUB : « Run workflow », puis vérifications.

## Points à trancher

1. **Page Confidentialité et purge.** La page dit « 3 ans après votre dernier contact avec Noorwan » ; la purge compte 3 ans après la dernière demande envoyée **par le formulaire** avec la même adresse. Un échange ultérieur par e-mail ou téléphone ne repousse pas la suppression. La purge supprime donc au plus tard à la date annoncée, jamais après, mais le texte n'est pas « exactement » le comportement. Deux options : préciser le texte (« 3 ans après votre dernière demande envoyée par ce formulaire », FR, EN, AR) ou garder la formule, qui couvrira aussi le futur CRM. Texte non modifié en attendant ta décision.
2. **« Données de limitation des envois : 1 heure ».** Les fichiers de `storage/ratelimit/` ne sont effacés que lors d'un envoi suivant ; sans nouvel envoi, une empreinte peut rester plus d'une heure. À choisir : faire aussi nettoyer ces fichiers par la purge nocturne (au plus environ 25 heures), ajouter un second cron horaire, ou ajuster le texte.
3. **Journaux Apache.** Le format `combined` enregistre l'adresse IP de chaque visiteur (conservée environ 14 jours par la rotation par défaut d'Ubuntu). La page Confidentialité dit que l'adresse IP n'est jamais enregistrée (à propos du formulaire) et qu'aucune autre donnée n'est collectée. À choisir : journal sans IP (format personnalisé dans l'hôte virtuel) ou mention des journaux techniques dans la politique.
4. **Clé privée `noorwan-site-deploy` sur le Mac** après enregistrement du secret GitHub : la supprimer ou la garder pour relancer un déploiement à la main.
5. **Heure du cron** : 3 h 45 à l'heure du serveur (fuseau du VPS à vérifier, `timedatectl`).
6. **Tests à chaque poussée sur toutes les branches** : une pull request ouverte depuis une branche du dépôt lance donc les tests deux fois (poussée et pull request). Sans gravité ; à restreindre à `main` si cela gêne.
