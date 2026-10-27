#!/usr/bin/env bash
# Déploiement de noorwan-site sur le VPS (production : noorwan.com).
# Lancé par GitHub Actions via une clé SSH dédiée, limitée à ce seul script
# (authorized_keys : restrict,command="bash /var/www/noorwan-site/deploy/deploy.sh").
# Site sans état : ni Composer, ni Node, ni mode maintenance.
# Ne touche qu'au dossier du site. Aucun sudo, jamais de suppression de données.
set -euo pipefail

main() {
    local app_dir="${NOORWAN_SITE_DIR:-/var/www/noorwan-site}"
    local branch="main"
    local lock="/tmp/noorwan-site-deploy.lock"

    exec 9>"$lock"
    if ! flock -n 9; then
        echo "ERREUR : un déploiement est déjà en cours." >&2
        exit 1
    fi

    cd "$app_dir"
    echo "== Déploiement noorwan-site $(date '+%Y-%m-%d %H:%M:%S %Z')"
    local previous
    previous="$(git rev-parse HEAD)"
    echo "Version actuelle : $(git log -1 --format='%h %s')"

    # Règle du projet : on ne corrige jamais le code directement sur le VPS.
    if [ -n "$(git status --porcelain --untracked-files=no)" ]; then
        echo "ERREUR : des fichiers suivis ont été modifiés directement sur le VPS :" >&2
        git status --short --untracked-files=no >&2
        echo "Déploiement annulé. Reporter ces changements en local puis via GitHub." >&2
        exit 1
    fi

    if [ ! -f .env ]; then
        echo "ERREUR : $app_dir/.env est absent. Le créer à partir de .env.example" >&2
        echo "(voir docs/Tech-Notes/Deploiement-VPS.md), puis relancer le déploiement." >&2
        exit 1
    fi

    git fetch --quiet origin "$branch"
    git merge --ff-only --quiet "origin/$branch"
    echo "Nouvelle version : $(git log -1 --format='%h %s')"

    # Contrôle de syntaxe de tous les fichiers PHP suivis ; en cas d'erreur, retour à la version de départ.
    local file failed=0
    while IFS= read -r -d '' file; do
        if ! php -l "$file" > /dev/null 2>&1; then
            echo "ERREUR de syntaxe PHP : $file" >&2
            php -l "$file" >&2 || true
            failed=1
        fi
    done < <(git ls-files -z -- '*.php')
    if [ "$failed" -ne 0 ]; then
        git reset --hard --quiet "$previous"
        echo "Retour à la version précédente : $(git log -1 --format='%h %s')" >&2
        exit 1
    fi

    # Dossiers d'écriture partagés avec Apache (groupe www-data), fermés aux autres utilisateurs
    mkdir -p storage/ratelimit storage/logs
    chgrp -R www-data storage 2>/dev/null || true
    chmod -R g+rwX,o-rwx storage 2>/dev/null || true
    find storage -type d -exec chmod g+s {} + 2>/dev/null || true

    echo "== Déploiement terminé."
}

main "$@"
