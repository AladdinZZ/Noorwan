# noorwan-site : déploiement GitHub et VPS

> Note technique du 2026-10-21 (Conv-002). Même principe qu'Inteek et OnePay : on ne modifie jamais le code sur le serveur, tout passe par GitHub. Claude Code ne se connecte jamais au VPS : les commandes serveur ci-dessous sont exécutées par Marwan.

## Chaîne de livraison

1. Le code est écrit et testé sur le Mac (`tests/run.sh` sous MAMP), puis poussé sur `main` du dépôt `AladdinZZ/Noorwan`.
2. GitHub Actions (`.github/workflows/deploy.yml`), à chaque poussée et pull request :
   - job `tests` : PHP 8.3, service MySQL 8 créé à partir de `database/schema.sql`, les deux utilisateurs MySQL avec les mêmes droits que sur le VPS, site servi par `php -S 127.0.0.1:8000 -t public tests/router.php`, puis `tests/run.sh` ;
   - job `deploy`, seulement sur `main`, après des tests verts et si la variable `DEPLOY_ENABLED` vaut `true` : connexion au VPS avec une clé SSH **limitée au seul script** `deploy/deploy.sh`.
3. `deploy/deploy.sh` sur le VPS : verrou, refus si un fichier suivi a été modifié sur place, refus si `.env` manque, `git fetch` puis avance rapide sur `origin/main`, `php -l` sur tous les fichiers PHP (retour à la version de départ en cas d'erreur), dossiers `storage/` au groupe `www-data`. Ni Composer, ni Node, ni mode maintenance : le site est sans état. Aucun `sudo`.
4. Le workflow vérifie que `/` et `/?lang=ar` répondent 200 et, hors `noorwan.com`, que l'en-tête `X-Robots-Tag` est présent.

## Choix

| Sujet | Choix |
|---|---|
| Serveur | VPS existant `212.132.106.181` (Apache, PHP 8.3 en module, MySQL 8), celui d'Inteek et d'OnePay |
| Adresse | `https://dev.noorwan.com`. `noorwan.com` et `www` ne changent pas. |
| Dossier | `/var/www/noorwan-site`, racine web `/var/www/noorwan-site/public` |
| Utilisateur de déploiement | `marwan` (groupes `sudo` et `www-data`) |
| Base | `noorwan_site`, deux utilisateurs : `noorwan_site` (le site : `INSERT` sur `contact_requests`, il ne lit jamais la table) et `noorwan_site_maint` (la maintenance : `SELECT`, `DELETE` sur `contact_requests`) |
| Environnement | `APP_ENV=staging` : erreurs masquées, `X-Robots-Tag: noindex, nofollow` sur toutes les réponses PHP, `robots.txt` en `Disallow: /`. Seul `APP_ENV=production` rend le site indexable (`robots.txt` ouvert, avec `Sitemap:`). |
| Tâche de fond | Purge des demandes de plus de 3 ans chaque nuit à 3 h 45 (`bin/purge-contacts.php`) |

## Installation initiale

Une seule fois, dans l'ordre. Chaque bloc indique où il s'exécute : **MAC**, **VPS** (connecté en `marwan`), **GITHUB** (interface web) ou **DNS** (interface du registraire). Aucun mot de passe n'est écrit dans cette note : ils sont tirés au hasard sur le VPS et ne vont que dans `.env`.

### 0. Préalable : fusionner `feat/deploiement`

**MAC**, après relecture :

```bash
cd /Applications/MAMP/htdocs/noorwan-site && git checkout main && git merge --no-ff feat/deploiement && git push origin main
```

Le clonage de l'étape 2 doit trouver `deploy/deploy.sh` et `bin/purge-contacts.php` sur `main`. Tant que `DEPLOY_ENABLED` n'est pas à `true`, cette poussée lance seulement les tests (onglet Actions : le job `tests` doit être vert).

### 1. DNS

**DNS** : enregistrement `A` `dev` (soit `dev.noorwan.com`) vers `212.132.106.181`. Ne toucher ni à `noorwan.com` ni à `www`.

**MAC**, vérification (peut prendre quelques minutes) :

```bash
dig +short dev.noorwan.com
```

Réponse attendue : `212.132.106.181`.

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

### 4. Fichier `.env` de démonstration

Clés : `DB_HOST`, `DB_NAME`, `DB_USER`, `DB_PASS`, `DB_MAINT_USER`, `DB_MAINT_PASS`, `APP_ENV` (`staging`), `APP_URL` (`https://dev.noorwan.com`), `APP_SECRET` (64 caractères hexadécimaux tirés au hasard).

**VPS**, même terminal que l'étape 3 :

```bash
cd /var/www/noorwan-site && umask 027 && cat > .env <<ENV
DB_HOST=127.0.0.1
DB_NAME=noorwan_site
DB_USER=noorwan_site
DB_PASS=${SITE_PASS}
DB_MAINT_USER=noorwan_site_maint
DB_MAINT_PASS=${MAINT_PASS}
APP_ENV=staging
APP_URL=https://dev.noorwan.com
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

### 5. Hôte virtuel Apache et HTTPS

Les en-têtes de sécurité (CSP, `X-Frame-Options`, etc.) et `X-Robots-Tag` sont envoyés par le site. La ligne `Header` ci-dessous ajoute `X-Robots-Tag` aux fichiers servis sans PHP (images, CSS, polices) : à retirer le jour du passage en production.

**VPS** :

```bash
sudo tee /etc/apache2/sites-available/dev.noorwan.com.conf > /dev/null <<'EOF'
<VirtualHost *:80>
    ServerName dev.noorwan.com
    DocumentRoot /var/www/noorwan-site/public

    <Directory /var/www/noorwan-site/public>
        AllowOverride All
        Require all granted
    </Directory>

    # Démonstration : aucun fichier ne doit être indexé, même ceux servis sans PHP.
    Header always set X-Robots-Tag "noindex, nofollow"

    ErrorLog ${APACHE_LOG_DIR}/dev.noorwan.com-error.log
    CustomLog ${APACHE_LOG_DIR}/dev.noorwan.com-access.log combined
</VirtualHost>
EOF
```

**VPS** : modules (déjà actifs pour Inteek en principe), activation, contrôle, rechargement :

```bash
sudo a2enmod rewrite headers && sudo a2ensite dev.noorwan.com.conf && sudo apache2ctl configtest && sudo systemctl reload apache2
```

**VPS** : certificat Let's Encrypt (renouvellement automatique, comme Inteek) :

```bash
sudo certbot --apache -d dev.noorwan.com
```

Accepter la redirection HTTP vers HTTPS si certbot la propose.

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

### 7. Purge nocturne

**VPS** : essai à blanc (attendu : `... purge-contacts simulation : 0 demande(s) à supprimer, rien n'est supprimé`) :

```bash
cd /var/www/noorwan-site && php bin/purge-contacts.php --dry-run
```

**VPS** : ajouter la ligne au cron de `marwan` (heure du serveur) :

```bash
(crontab -l 2>/dev/null; echo '45 3 * * * cd /var/www/noorwan-site && php bin/purge-contacts.php >> storage/logs/purge.log 2>&1') | crontab -
```

**VPS** : contrôle :

```bash
crontab -l | grep purge-contacts
```

Le journal `storage/logs/purge.log` reçoit une ligne par nuit (date UTC, nombre de demandes supprimées), ou une ligne `ERREUR` si la base refuse.

### 8. Secrets et variables GitHub

**GITHUB** : `AladdinZZ/Noorwan` > Settings > Secrets and variables > Actions, ou **MAC** avec `gh`, une commande par valeur :

```bash
gh secret set VPS_HOST -R AladdinZZ/Noorwan -b 212.132.106.181
```

```bash
gh secret set VPS_USER -R AladdinZZ/Noorwan -b marwan
```

```bash
gh secret set VPS_SSH_KEY -R AladdinZZ/Noorwan < ~/.ssh/noorwan-site-deploy
```

```bash
gh variable set APP_PUBLIC_URL -R AladdinZZ/Noorwan -b https://dev.noorwan.com
```

Puis, **en dernier**, une fois les étapes 1 à 7 faites :

```bash
gh variable set DEPLOY_ENABLED -R AladdinZZ/Noorwan -b true
```

La clé privée `~/.ssh/noorwan-site-deploy` n'est plus utile sur le Mac une fois le secret enregistré : la supprimer, ou la garder pour relancer un déploiement à la main (étape 6).

### 9. Premier déploiement et vérifications

**GITHUB** : onglet Actions > « Tests et déploiement VPS » > Run workflow sur `main`. Ou **MAC** :

```bash
gh workflow run deploy.yml -R AladdinZZ/Noorwan --ref main
```

Les jobs `tests` puis `deploy` doivent être verts ; l'étape « Vérifier le site » contrôle `/`, `/?lang=ar` et `X-Robots-Tag`.

**MAC** : en-têtes (attendu : `HTTP/2 200` et `x-robots-tag: noindex, nofollow`) :

```bash
curl -sI https://dev.noorwan.com/ | grep -iE '^HTTP|x-robots-tag|content-security-policy'
```

**MAC** : robots (attendu : `Disallow: /`) et fichiers protégés (attendu : `404` puis `404`) :

```bash
curl -s https://dev.noorwan.com/robots.txt; for p in .env ../.env; do curl -s -o /dev/null -w "$p %{http_code}\n" "https://dev.noorwan.com/$p"; done
```

**MAC** : envoyer une demande par le formulaire de `https://dev.noorwan.com/contact.php` avec une adresse `@example.invalid`, puis **VPS** : la retrouver et la supprimer :

```bash
sudo mysql noorwan_site -e "SELECT id, created_at, lang, universe, email FROM contact_requests ORDER BY id DESC LIMIT 3; DELETE FROM contact_requests WHERE email LIKE '%@example.invalid';"
```

## Fonctionnement courant

- **Déployer** : fusionner sur `main` et pousser. Tests puis déploiement automatiques.
- **Relancer à la main** : Actions > Run workflow, ou étape 6 depuis le Mac.
- **Échec « fichiers suivis modifiés sur le VPS »** : quelqu'un a corrigé sur place. Reporter la correction sur le Mac et la pousser, puis sur le VPS `git -C /var/www/noorwan-site checkout -- <fichier>`.
- **Échec de syntaxe PHP** : le script est revenu tout seul à la version précédente ; corriger sur le Mac et pousser.
- **Purge** : `storage/logs/purge.log`. Simulation à tout moment : `php bin/purge-contacts.php --dry-run`.

## Passage en production (plus tard)

`APP_ENV=production` et `APP_URL=https://noorwan.com` dans le `.env` de production, hôte virtuel sans la ligne `Header ... X-Robots-Tag`, variable `APP_PUBLIC_URL` à `https://noorwan.com` (le workflow cesse alors d'exiger `X-Robots-Tag`). `robots.txt` autorise alors tout et indique `https://noorwan.com/sitemap.xml`.
