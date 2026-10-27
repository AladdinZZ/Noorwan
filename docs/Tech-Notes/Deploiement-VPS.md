# noorwan-site : déploiement GitHub et VPS

> Note technique du 2026-10-21 (Conv-002), mise à jour le 2026-10-27 : déploiement direct en production sur `noorwan.com`, plus de `dev.noorwan.com`. Même principe qu'Inteek et OnePay : on ne modifie jamais le code sur le serveur, tout passe par GitHub. Claude Code ne se connecte jamais au VPS : les commandes serveur ci-dessous sont exécutées par Marwan.

## Chaîne de livraison

1. Le code est écrit et testé sur le Mac (`tests/run.sh` sous MAMP), puis poussé sur `main` du dépôt `AladdinZZ/Noorwan`.
2. GitHub Actions (`.github/workflows/deploy.yml`), à chaque poussée et pull request :
   - job `tests` : PHP 8.3, service MySQL 8 créé à partir de `database/schema.sql`, les deux utilisateurs MySQL avec les mêmes droits que sur le VPS, site servi par `php -S 127.0.0.1:8000 -t public tests/router.php`, puis `tests/run.sh` ;
   - job `deploy`, seulement sur `main`, après des tests verts et si la variable `DEPLOY_ENABLED` vaut `true` : connexion au VPS avec une clé SSH **limitée au seul script** `deploy/deploy.sh`.
3. `deploy/deploy.sh` sur le VPS : verrou, refus si un fichier suivi a été modifié sur place, refus si `.env` manque, `git fetch` puis avance rapide sur `origin/main`, `php -l` sur tous les fichiers PHP (retour à la version de départ en cas d'erreur), dossiers `storage/` au groupe `www-data`. Ni Composer, ni Node, ni mode maintenance : le site est sans état. Aucun `sudo`.
4. Le workflow vérifie que `https://noorwan.com/` et `https://noorwan.com/?lang=ar` répondent 200, qu'aucun en-tête `X-Robots-Tag` n'est envoyé (production indexable) et que `https://www.noorwan.com/` renvoie en 301 vers `https://noorwan.com/`.

## Choix

| Sujet | Choix |
|---|---|
| Serveur | VPS existant `212.132.106.181` (Apache, PHP 8.3 en module, MySQL 8), celui d'Inteek et d'OnePay. L'ancien site `noorwan.com` y tourne déjà (constaté le 22/10/2026 : `noorwan.com` et `www` pointent sur cette adresse) |
| Adresse | `https://noorwan.com`, en production directe. `www.noorwan.com` renvoie en 301 vers `noorwan.com`. |
| Dossier | `/var/www/noorwan-site`, racine web `/var/www/noorwan-site/public` |
| Utilisateur de déploiement | `marwan` (groupes `sudo` et `www-data`) |
| Base | `noorwan_site`, deux utilisateurs : `noorwan_site` (le site : `INSERT` sur `contact_requests`, il ne lit jamais la table) et `noorwan_site_maint` (la maintenance : `SELECT`, `DELETE` sur `contact_requests`) |
| Environnement | `APP_ENV=production`, `APP_URL=https://noorwan.com` : erreurs masquées, site indexable (`robots.txt` ouvert, avec `Sitemap: https://noorwan.com/sitemap.xml`), aucun `X-Robots-Tag`. |
| Journaux Apache | Format `noorwan_noip` : ni adresse IP dans le journal d'accès, ni dans le journal d'erreurs (politique de confidentialité). |
| Tâche de fond | Toutes les heures, à la 17e minute (`bin/purge-contacts.php`) : demandes de plus de 3 ans, fichiers de limite d'envoi de plus d'une heure |

## Installation initiale

Une seule fois, dans l'ordre. Chaque bloc indique où il s'exécute : **MAC**, **VPS** (connecté en `marwan`), **GITHUB** (interface web) ou **DNS** (espace IONOS du domaine). Le nouveau site remplace l'ancien à l'étape 5 ; tout ce qui précède se fait sans coupure. Aucun mot de passe n'est écrit dans cette note : ils sont tirés au hasard sur le VPS et ne vont que dans `.env`.

### 0. Préalable : fusionner `feat/deploiement`

**MAC**, après relecture :

```bash
cd /Applications/MAMP/htdocs/noorwan-site && git checkout main && git merge --no-ff feat/deploiement && git push origin main
```

Le clonage de l'étape 2 doit trouver `deploy/deploy.sh` et `bin/purge-contacts.php` sur `main`. Tant que `DEPLOY_ENABLED` n'est pas à `true`, cette poussée lance seulement les tests (onglet Actions : le job `tests` doit être vert).

### 0 bis. Sauvegarder l'ancien site avant la bascule

L'ancien site (site d'auteur, avec `/test/`) est servi par un autre hôte virtuel Apache de ce VPS. Il disparaît à l'étape 5 : on le sauvegarde d'abord, avec sa configuration, pour pouvoir revenir en arrière.

**VPS** : retrouver le ou les fichiers d'hôte virtuel de l'ancien site et leur racine web :

```bash
grep -ilE '^\s*Server(Name|Alias).*noorwan\.com' /etc/apache2/sites-available/*.conf
```

```bash
sudo apache2ctl -S 2>/dev/null | grep -i noorwan
```

**VPS** : afficher la racine web de chaque fichier trouvé (remplacer `ANCIEN.conf` par chaque nom affiché ci-dessus) :

```bash
grep -iE 'ServerName|ServerAlias|DocumentRoot' /etc/apache2/sites-available/ANCIEN.conf
```

Noter les noms des fichiers (le port 80 et, s'il existe, le port 443, souvent `...-le-ssl.conf`) et la racine web : ils servent à l'archive ci-dessous et à l'étape 5.

**VPS** : archive des fichiers de l'ancien site et de sa configuration (remplacer `/CHEMIN/RACINE` et les noms de fichiers par les valeurs notées) :

```bash
sudo tar czf ~/sauvegarde-ancien-noorwan-$(date +%F).tar.gz /CHEMIN/RACINE /etc/apache2/sites-available/ANCIEN.conf /etc/apache2/sites-available/ANCIEN-le-ssl.conf && sudo chown marwan: ~/sauvegarde-ancien-noorwan-*.tar.gz && tar tzf ~/sauvegarde-ancien-noorwan-*.tar.gz | head
```

**VPS** : l'ancien site utilise-t-il une base de données (formulaire « Nous contacter ») ? Rechercher une connexion MySQL dans ses fichiers :

```bash
grep -rlE 'mysqli_connect|new PDO|new mysqli' /CHEMIN/RACINE | head
```

Si un fichier apparaît, y lire le nom de la base, puis l'exporter (remplacer `ANCIENNE_BASE`) :

```bash
sudo mysqldump --single-transaction ANCIENNE_BASE | gzip > ~/sauvegarde-ancienne-base-$(date +%F).sql.gz
```

**MAC** : rapatrier les sauvegardes hors du VPS :

```bash
scp 'marwan@212.132.106.181:~/sauvegarde-ancien*' ~/Documents/
```

**VPS** : certificat actuel (pour information ; certbot le reprendra ou l'étendra à l'étape 5) :

```bash
sudo certbot certificates 2>/dev/null | grep -A3 -i noorwan
```

### 1. DNS : vérifier, ne rien modifier d'autre

Seuls les enregistrements `A` de `noorwan.com` et de `www.noorwan.com` concernent le site : ils doivent pointer vers `212.132.106.181`. **Ne jamais toucher aux enregistrements MX (messagerie IONOS), TXT (SPF, vérifications Google, Brevo), NS ni à aucun autre.**

**MAC** :

```bash
for n in noorwan.com www.noorwan.com; do printf '%s A=%s AAAA=%s\n' "$n" "$(dig +short $n A | paste -sd, -)" "$(dig +short $n AAAA | paste -sd, -)"; done
```

Attendu : `A=212.132.106.181` pour les deux et `AAAA=` vide. C'était déjà le cas le 22/10/2026 : **rien à modifier**. Si un `A` diffère, corriger ce seul enregistrement dans l'espace IONOS. Si un `AAAA` apparaît, ne pas basculer : une partie des visiteurs irait ailleurs (à trancher avant de continuer).

### 2. Accès du VPS au dépôt et clonage

**VPS** : clé dédiée au dépôt (GitHub refuse la même clé de déploiement sur deux dépôts, celle d'Inteek ne peut pas servir) :

```bash
ssh-keygen -t ed25519 -f ~/.ssh/github_noorwan_site -N "" -C "vps-noorwan-site"
```

**VPS** : alias SSH pour que `git` utilise cette clé sur ce dépôt :

```bash
cat >> ~/.ssh/config <<'EOF'

Host github-noorwan-site
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_noorwan_site
    IdentitiesOnly yes
EOF
```

**VPS** : afficher la clé publique à copier :

```bash
cat ~/.ssh/github_noorwan_site.pub
```

**GITHUB** : `AladdinZZ/Noorwan` > Settings > Deploy keys > Add deploy key. Titre `vps-noorwan-site`, la clé publique ci-dessus, **« Allow write access » décoché** (lecture seule).

**VPS** : dossier du site, à `marwan`, groupe `www-data` (seule commande avec `sudo` de cette étape) :

```bash
sudo install -d -o marwan -g www-data -m 2755 /var/www/noorwan-site
```

**VPS** : clonage :

```bash
git clone git@github-noorwan-site:AladdinZZ/Noorwan.git /var/www/noorwan-site
```

### 3. Base et utilisateurs MySQL

Les étapes 3 et 4 se font **dans le même terminal** : les mots de passe tirés à l'étape 3 sont écrits dans `.env` à l'étape 4, sans jamais être affichés.

**VPS** : tirer les deux mots de passe au hasard :

```bash
SITE_PASS=$(openssl rand -hex 24); MAINT_PASS=$(openssl rand -hex 24)
```

**VPS** : base, schéma, utilisateurs et droits exacts :

```bash
sudo mysql <<SQL
CREATE DATABASE noorwan_site CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE noorwan_site;
SOURCE /var/www/noorwan-site/database/schema.sql;
CREATE USER 'noorwan_site'@'localhost' IDENTIFIED BY '${SITE_PASS}';
GRANT INSERT ON noorwan_site.contact_requests TO 'noorwan_site'@'localhost';
CREATE USER 'noorwan_site_maint'@'localhost' IDENTIFIED BY '${MAINT_PASS}';
GRANT SELECT, DELETE ON noorwan_site.contact_requests TO 'noorwan_site_maint'@'localhost';
SQL
```

**VPS** : contrôle des droits :

```bash
sudo mysql -e "SHOW GRANTS FOR 'noorwan_site'@'localhost'; SHOW GRANTS FOR 'noorwan_site_maint'@'localhost';"
```

Attendu : `GRANT INSERT ON noorwan_site.contact_requests` pour le site, `GRANT SELECT, DELETE ON noorwan_site.contact_requests` pour la maintenance, et rien d'autre que `USAGE`.

### 4. Fichier `.env` de production

Clés : `DB_HOST`, `DB_NAME`, `DB_USER`, `DB_PASS`, `DB_MAINT_USER`, `DB_MAINT_PASS`, `APP_ENV` (`production`), `APP_URL` (`https://noorwan.com`), `APP_SECRET` (64 caractères hexadécimaux tirés au hasard).

**VPS**, même terminal que l'étape 3 :

```bash
cd /var/www/noorwan-site && umask 027 && cat > .env <<ENV
DB_HOST=127.0.0.1
DB_NAME=noorwan_site
DB_USER=noorwan_site
DB_PASS=${SITE_PASS}
DB_MAINT_USER=noorwan_site_maint
DB_MAINT_PASS=${MAINT_PASS}
APP_ENV=production
APP_URL=https://noorwan.com
APP_SECRET=$(openssl rand -hex 32)
ENV
```

**VPS** : droits 640, groupe `www-data`, puis oubli des mots de passe dans le terminal :

```bash
chgrp www-data .env && chmod 640 .env && unset SITE_PASS MAINT_PASS && ls -l .env
```

Attendu : `-rw-r----- 1 marwan www-data ... .env`.

**VPS** : dossiers d'écriture (le script de déploiement les recrée à chaque fois s'ils manquent) :

```bash
mkdir -p storage/ratelimit storage/logs && chgrp -R www-data storage && chmod -R 2770 storage
```

### 5. Hôte virtuel Apache, bascule et HTTPS

C'est l'étape de la bascule : entre la désactivation de l'ancien hôte virtuel et la fin de certbot, `https://noorwan.com` peut répondre avec un mauvais certificat pendant une à deux minutes. Les en-têtes de sécurité (CSP, `X-Frame-Options`, etc.) sont envoyés par le site ; aucun `X-Robots-Tag` en production.

**VPS** : nouvel hôte virtuel (nom distinct de l'ancien, pour ne rien écraser) :

```bash
sudo tee /etc/apache2/sites-available/noorwan-site.conf > /dev/null <<'EOF'
<VirtualHost *:80>
    ServerName noorwan.com
    ServerAlias www.noorwan.com
    DocumentRoot /var/www/noorwan-site/public

    <Directory /var/www/noorwan-site/public>
        AllowOverride All
        Require all granted
    </Directory>

    # Une seule adresse publique : www renvoie définitivement vers noorwan.com.
    # Recopié par certbot dans l'hôte HTTPS, donc valable aussi pour https://www.
    RewriteEngine On
    RewriteCond %{HTTP_HOST} ^www\.noorwan\.com$ [NC]
    RewriteRule ^ https://noorwan.com%{REQUEST_URI} [R=301,L]

    # Journaux sans adresse IP (politique de confidentialité). Défini dans l'hôte virtuel
    # pour que certbot le recopie dans l'hôte HTTPS.
    # Accès : date, requête, statut, taille, page d'origine, navigateur.
    LogFormat "%t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" noorwan_noip
    # Erreurs : sans l'adresse du client (le format par défaut l'ajoute).
    ErrorLogFormat "[%{u}t] [%-m:%l] [pid %P] %M"
    ErrorLog ${APACHE_LOG_DIR}/noorwan.com-error.log
    CustomLog ${APACHE_LOG_DIR}/noorwan.com-access.log noorwan_noip
</VirtualHost>
EOF
```

**VPS** : modules (déjà actifs pour Inteek en principe), désactivation de l'ancien hôte virtuel (les noms notés à l'étape 0 bis, port 80 et 443), activation du nouveau, contrôle, rechargement :

```bash
sudo a2enmod rewrite headers && sudo a2dissite ANCIEN.conf ANCIEN-le-ssl.conf && sudo a2ensite noorwan-site.conf && sudo apache2ctl configtest && sudo systemctl reload apache2
```

**VPS**, aussitôt : certificat Let's Encrypt pour les deux noms (renouvellement automatique, comme Inteek) :

```bash
sudo certbot --apache -d noorwan.com -d www.noorwan.com
```

Si certbot propose de réutiliser ou d'étendre le certificat existant, accepter ; accepter aussi la redirection HTTP vers HTTPS.

**MAC** : contrôle rapide (attendu : `200`, puis `301 https://noorwan.com/` deux fois) :

```bash
curl -s -o /dev/null -w '%{http_code}\n' https://noorwan.com/; for u in https://www.noorwan.com/ http://www.noorwan.com/; do curl -s -o /dev/null -w '%{http_code} %{redirect_url}\n' "$u"; done
```

**Retour arrière** si le nouveau site ne répond pas : réactiver l'ancien hôte virtuel (fichiers sauvegardés à l'étape 0 bis) :

```bash
sudo a2dissite noorwan-site.conf noorwan-site-le-ssl.conf; sudo a2ensite ANCIEN.conf ANCIEN-le-ssl.conf && sudo apache2ctl configtest && sudo systemctl reload apache2
```

### 6. Clé SSH de déploiement `noorwan-site-deploy`

**MAC** : nouvelle paire dédiée, sans phrase de passe (GitHub Actions l'utilise sans intervention) :

```bash
ssh-keygen -t ed25519 -f ~/.ssh/noorwan-site-deploy -N "" -C "noorwan-site-deploy"
```

**MAC** : copier la clé publique :

```bash
pbcopy < ~/.ssh/noorwan-site-deploy.pub
```

**VPS** : l'autoriser, **limitée au script** (remplacer `ssh-ed25519 AAAA...` par la clé copiée, sur une seule ligne) :

```bash
echo 'restrict,command="bash /var/www/noorwan-site/deploy/deploy.sh" ssh-ed25519 AAAA... noorwan-site-deploy' >> ~/.ssh/authorized_keys
```

**MAC** : essai. Quelle que soit la commande demandée, seul le script tourne :

```bash
ssh -i ~/.ssh/noorwan-site-deploy marwan@212.132.106.181 deploy
```

Attendu : `== Déploiement noorwan-site ...` puis `== Déploiement terminé.`

**MAC** : enregistrer la clé privée comme secret GitHub :

```bash
gh secret set VPS_SSH_KEY -R AladdinZZ/Noorwan < ~/.ssh/noorwan-site-deploy
```

**MAC** : vérifier que le secret existe (attendu : une ligne `VPS_SSH_KEY`), puis **supprimer la clé privée du Mac** : elle ne doit plus exister ailleurs que dans GitHub. Pour relancer un déploiement, passer par GitHub (étape 9).

```bash
gh secret list -R AladdinZZ/Noorwan | grep VPS_SSH_KEY && rm -f ~/.ssh/noorwan-site-deploy
```

### 7. Purge horaire

**VPS** : essai à blanc (attendu : `... purge-contacts simulation : 0 demande(s) et 0 fichier(s) de limite d'envoi à supprimer, rien n'est supprimé`) :

```bash
cd /var/www/noorwan-site && php bin/purge-contacts.php --dry-run
```

**VPS** : ajouter la ligne au cron de `marwan` (heure du serveur) :

```bash
(crontab -l 2>/dev/null; echo '17 * * * * cd /var/www/noorwan-site && php bin/purge-contacts.php >> storage/logs/purge.log 2>&1') | crontab -
```

**VPS** : contrôle :

```bash
crontab -l | grep purge-contacts
```

Toutes les heures, et non une fois par nuit, pour coller à la page Confidentialité (données de limitation des envois : 1 heure) : un fichier sans nouvel envoi disparaît entre 1 et 2 heures après le dernier envoi, au lieu de 25 heures au plus avec une purge nocturne. Le journal `storage/logs/purge.log` reçoit une ligne par heure (date UTC, nombre de demandes supprimées, nombre de fichiers de `storage/ratelimit/` de plus d'une heure supprimés), ou une ligne `ERREUR` si la base refuse.

### 8. Secrets et variables GitHub

**GITHUB** : `AladdinZZ/Noorwan` > Settings > Secrets and variables > Actions, ou **MAC** avec `gh`, une commande par valeur :

```bash
gh secret set VPS_HOST -R AladdinZZ/Noorwan -b 212.132.106.181
```

```bash
gh secret set VPS_USER -R AladdinZZ/Noorwan -b marwan
```

Puis, **en dernier**, une fois les étapes 1 à 7 faites :

```bash
gh variable set DEPLOY_ENABLED -R AladdinZZ/Noorwan -b true
```

Le secret `VPS_SSH_KEY` a été enregistré à l'étape 6. L'adresse vérifiée par le workflow (`https://noorwan.com`) est écrite dans `deploy.yml` : plus de variable `APP_PUBLIC_URL`.

### 9. Premier déploiement et vérifications

**GITHUB** : onglet Actions > « Tests et déploiement VPS » > Run workflow sur `main`. Ou **MAC** :

```bash
gh workflow run deploy.yml -R AladdinZZ/Noorwan --ref main
```

Les jobs `tests` puis `deploy` doivent être verts ; l'étape « Vérifier le site » contrôle `https://noorwan.com/`, `https://noorwan.com/?lang=ar`, l'absence de `X-Robots-Tag` et la redirection de `www`.

**MAC** : en-têtes (attendu : `HTTP/2 200`, une ligne `content-security-policy`, aucune ligne `x-robots-tag`) :

```bash
curl -sI https://noorwan.com/ | grep -iE '^HTTP|x-robots-tag|content-security-policy'
```

**MAC** : robots (attendu : `Allow: /` et `Sitemap: https://noorwan.com/sitemap.xml`) et fichiers protégés (attendu : `404` puis `404`) :

```bash
curl -s https://noorwan.com/robots.txt; for p in .env ../.env; do curl -s -o /dev/null -w "$p %{http_code}\n" "https://noorwan.com/$p"; done
```

**MAC** : envoyer une demande par le formulaire de `https://noorwan.com/contact.php` avec une adresse `@example.invalid`, puis **VPS** : la retrouver et la supprimer :

```bash
sudo mysql noorwan_site -e "SELECT id, created_at, lang, universe, email FROM contact_requests ORDER BY id DESC LIMIT 3; DELETE FROM contact_requests WHERE email LIKE '%@example.invalid';"
```

**VPS** : journal d'accès sans adresse IP (attendu : chaque ligne commence par la date entre crochets) :

```bash
sudo tail -n 3 /var/log/apache2/noorwan.com-access.log
```

## Fonctionnement courant

- **Déployer** : fusionner sur `main` et pousser. Tests puis déploiement automatiques.
- **Relancer à la main** : Actions > Run workflow (la clé de déploiement n'existe plus sur le Mac).
- **Échec « fichiers suivis modifiés sur le VPS »** : quelqu'un a corrigé sur place. Reporter la correction sur le Mac et la pousser, puis sur le VPS `git -C /var/www/noorwan-site checkout -- <fichier>`.
- **Échec de syntaxe PHP** : le script est revenu tout seul à la version précédente ; corriger sur le Mac et pousser.
- **Purge** : `storage/logs/purge.log`. Simulation à tout moment : `php bin/purge-contacts.php --dry-run`.
