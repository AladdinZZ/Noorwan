#!/usr/bin/env bash
# Tests du site, en local (MAMP) comme en intégration continue. Usage : tests/run.sh
# Variables facultatives, lues dans l'environnement puis dans .env :
#   BASE_URL (défaut : APP_URL du .env, sinon l'adresse MAMP), DB_HOST, DB_NAME, DB_USER, DB_PASS,
#   DB_MAINT_USER, DB_MAINT_PASS (défaut : DB_USER et DB_PASS, comme sur un poste local),
#   APP_ENV (doit être celui du site testé), PHP, MYSQL (défaut : le client MySQL de MAMP s'il existe, sinon mysql).
# En CI : BASE_URL=http://127.0.0.1:8000 avec le site servi par « php -S 127.0.0.1:8000 -t public ».
# Attention : vide storage/ratelimit/ et supprime de la base les envois de test (@example.invalid).

set -u
cd "$(dirname "$0")/.."

env_value() { [[ -f .env ]] && grep -E "^$1=" .env | head -n 1 | cut -d= -f2- | sed -e "s/^[\"']//" -e "s/[\"']$//"; }
# Valeur de l'environnement si elle est définie, sinon celle du .env, sinon la valeur par défaut.
config() { local value="${!1:-}"; [[ -n "$value" ]] || value="$(env_value "$1")"; printf '%s' "${value:-${2:-}}"; }

MAMP_MYSQL="/Applications/MAMP/Library/bin/mysql80/bin/mysql"
PHP="${PHP:-php}"
MYSQL="${MYSQL:-$([[ -x "$MAMP_MYSQL" ]] && echo "$MAMP_MYSQL" || echo mysql)}"
BASE_URL="$(config BASE_URL "$(config APP_URL http://localhost:8888/noorwan-site/public)")"
BASE_URL="${BASE_URL%/}"
DB_HOST_PORT="$(config DB_HOST 127.0.0.1)"
DB_HOST="${DB_HOST_PORT%%:*}"
DB_PORT="3306"
[[ "$DB_HOST_PORT" == *:* ]] && DB_PORT="${DB_HOST_PORT##*:}"
DB_NAME="$(config DB_NAME noorwan_site)"
DB_USER="$(config DB_USER)"
DB_PASS="$(config DB_PASS)"
APP_ENV="$(config APP_ENV production)"
DB_MAINT_USER="$(config DB_MAINT_USER "$DB_USER")"
DB_MAINT_PASS="$(config DB_MAINT_PASS "$DB_PASS")"
TEST_EMAIL="test-run@example.invalid"

failures=0
pass() { printf '  ok   %s\n' "$1"; }
fail() { printf '  ECHEC %s\n' "$1"; failures=$((failures + 1)); }
expect() { # expect LIBELLÉ ATTENDU OBTENU
    if [[ "$2" == "$3" ]]; then pass "$1 ($3)"; else fail "$1 : attendu $2, obtenu $3"; fi
}
# sql : utilisateur de maintenance (lecture, suppression). sql_site : utilisateur du site (insertion).
sql() {
    MYSQL_PWD="$DB_MAINT_PASS" "$MYSQL" -h"$DB_HOST" -P"$DB_PORT" -u"$DB_MAINT_USER" -N -B "$DB_NAME" -e "$1" 2>/dev/null
}
sql_site() {
    MYSQL_PWD="$DB_PASS" "$MYSQL" -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -N -B "$DB_NAME" -e "$1" 2>/dev/null
}
token() { curl -s "$BASE_URL/contact.php?lang=fr" | grep -o 'name="token" value="[^"]*"' | sed -e 's/.*value="//' -e 's/"$//'; }

echo "1. Syntaxe PHP"
while IFS= read -r file; do
    if "$PHP" -l "$file" >/dev/null 2>&1; then :; else fail "php -l $file"; fi
done < <(find app bin lang public -name '*.php')
[[ $failures -eq 0 ]] && pass "php -l sur tous les fichiers"

echo "2. Pages (code 200 attendu) sur $BASE_URL"
for page in "" edition.php contact.php mentions-legales.php confidentialite.php cookies.php; do
    for lang in fr en ar; do
        code=$(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/$page?lang=$lang")
        expect "/${page:-index} lang=$lang" 200 "$code"
    done
done
expect "langue inconnue retombe sur fr" 200 "$(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/?lang=xx")"
grep -q '<html lang="ar" dir="rtl">' <(curl -s "$BASE_URL/?lang=ar") && pass "arabe en RTL" || fail "arabe en RTL"
expect "fichier .env inaccessible" 404 "$(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/../.env")"
expect "dossier app/ inaccessible" 404 "$(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/../app/bootstrap.php")"
expect "dossier bin/ inaccessible" 404 "$(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/../bin/purge-contacts.php")"

echo "2 bis. Ressources"
for lang in fr en ar; do
    html=$(curl -s "$BASE_URL/?lang=$lang")
    external=$(echo "$html" | grep -oE '<(link|script|img)[^>]+(href|src)="https?://[^"]+"' | grep -v "rel=\"canonical\"\|rel=\"alternate\"")
    if [[ -z "$external" ]]; then pass "aucune ressource externe ($lang)"; else fail "ressource externe ($lang) : $external"; fi
    if echo "$html" | grep -qE '>(À propos|About|من نحن)<'; then fail "« À propos » encore dans le menu ($lang)"; else pass "pas de « À propos » ($lang)"; fi
done
for weight in Regular Medium SemiBold Bold; do
    expect "police IBMPlexSansArabic-$weight.woff2" 200 "$(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/assets/fonts/IBMPlexSansArabic-$weight.woff2")"
done
hero_size=$(curl -s -o /dev/null -w '%{size_download}' "$BASE_URL/assets/images/hero.webp")
if [[ "$hero_size" -gt 0 && "$hero_size" -lt 256000 ]]; then pass "hero.webp sous 250 Ko ($hero_size octets)"; else fail "hero.webp : $hero_size octets"; fi

echo "2 ter. Indexation (APP_ENV=$APP_ENV)"
if [[ "$APP_ENV" == "production" ]]; then
    for path in "/" "/?lang=ar" "/robots.txt"; do
        if curl -sI "$BASE_URL$path" | grep -qi '^X-Robots-Tag:'; then fail "X-Robots-Tag présent en production ($path)"; else pass "pas de X-Robots-Tag en production ($path)"; fi
    done
    grep -q '^Sitemap: ' <(curl -s "$BASE_URL/robots.txt") && pass "robots.txt indique le plan du site" || fail "robots.txt sans plan du site"
else
    for path in "/" "/?lang=ar" "/contact.php?lang=en" "/robots.txt" "/sitemap.xml"; do
        if curl -sI "$BASE_URL$path" | grep -qi '^X-Robots-Tag: noindex, nofollow'; then pass "X-Robots-Tag noindex ($path)"; else fail "X-Robots-Tag absent ($path)"; fi
    done
    expect "robots.txt interdit tout" "User-agent: *|Disallow: /" "$(curl -s "$BASE_URL/robots.txt" | paste -sd '|' -)"
fi
expect "robots.txt en texte" "text/plain; charset=utf-8" "$(curl -s -o /dev/null -w '%{content_type}' "$BASE_URL/robots.txt")"
# Contenu de production, calculé hors serveur : autorise tout et indique le plan du site.
robots_prod=$("$PHP" -r 'require "app/bootstrap.php"; require "app/seo.php"; echo robots_txt(true);' 2>&1)
if [[ "$robots_prod" == $'User-agent: *\nAllow: /\n\nSitemap: '*'/sitemap.xml' ]]; then pass "robots.txt de production"; else fail "robots.txt de production : $robots_prod"; fi
sitemap=$(curl -s "$BASE_URL/sitemap.xml")
expect "sitemap.xml : 6 pages x 3 langues" 18 "$(grep -c '<loc>' <<< "$sitemap")"
expect "sitemap.xml : 4 versions par adresse (fr, en, ar, x-default)" 72 "$(grep -c 'hreflang=' <<< "$sitemap")"
if command -v xmllint >/dev/null; then
    xmllint --noout - <<< "$sitemap" 2>/dev/null && pass "sitemap.xml bien formé" || fail "sitemap.xml mal formé"
fi

echo "2 ter. Pages légales"
for lang in fr en ar; do
    html=$(curl -s "$BASE_URL/confidentialite.php?lang=$lang")
    if grep -q 'COMPLÉTER' <<< "$html"; then fail "Confidentialité ($lang) : marqueur [À COMPLÉTER] restant"; else pass "Confidentialité ($lang) : aucun [À COMPLÉTER]"; fi
    grep -q 'href="mailto:contact@noorwan.com"' <<< "$html" && pass "Confidentialité ($lang) : adresse de contact" || fail "Confidentialité ($lang) : adresse de contact absente"
done

echo "3. Formulaire de contact"
rm -f storage/ratelimit/contact-*.log
sql "DELETE FROM contact_requests WHERE email = '$TEST_EMAIL'"
before=$(sql "SELECT COUNT(*) FROM contact_requests WHERE email = '$TEST_EMAIL'")

code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE_URL/contact.php?lang=fr" \
    --data-urlencode "token=$(token)" -d 'name=A&email=pas-un-email&universe=inconnu&message=court')
expect "envoi invalide refusé" 422 "$code"

code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE_URL/contact.php?lang=fr" \
    -d "token=1.2.3&name=Test&email=$TEST_EMAIL&universe=consulting&message=Message+de+test+automatique")
expect "jeton invalide refusé" 400 "$code"

code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE_URL/contact.php?lang=fr" \
    --data-urlencode "token=$(token)" -d "name=Robot&email=$TEST_EMAIL&universe=consulting&message=Message+de+robot+automatique&website=http%3A%2F%2Fspam")
expect "champ piège : réponse de succès" 303 "$code"

code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE_URL/contact.php?lang=en" \
    --data-urlencode "token=$(token)" \
    -d "name=Test+run.sh&email=$TEST_EMAIL&phone=%2B33+1+23+45+67+89&universe=edition&message=Message+de+test+automatique&consent_offers=1")
expect "envoi valide accepté" 303 "$code"

row=$(sql "SELECT CONCAT_WS('|', lang, universe, consent_offers, consent_partners, LENGTH(ip_hash)) FROM contact_requests WHERE email = '$TEST_EMAIL'")
expect "une seule ligne enregistrée (le robot est ignoré)" 1 "$(( $(sql "SELECT COUNT(*) FROM contact_requests WHERE email = '$TEST_EMAIL'") - before ))"
expect "contenu enregistré (langue, univers, accords, empreinte IP)" "en|edition|1|0|64" "$row"

for i in 2 3 4 5; do
    curl -s -o /dev/null -X POST "$BASE_URL/contact.php?lang=fr" --data-urlencode "token=$(token)" \
        -d "name=Test+run.sh&email=$TEST_EMAIL&universe=autre&message=Envoi+de+test+numero+$i"
done
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE_URL/contact.php?lang=fr" --data-urlencode "token=$(token)" \
    -d "name=Test+run.sh&email=$TEST_EMAIL&universe=autre&message=Envoi+de+test+en+trop")
expect "envoi au-delà de 5 dans l'heure bloqué" 429 "$code"

sql "DELETE FROM contact_requests WHERE email = '$TEST_EMAIL'"
rm -f storage/ratelimit/contact-*.log

echo "3 bis. Droits en base et purge à 3 ans"
if [[ "$DB_MAINT_USER" != "$DB_USER" ]]; then
    if sql_site "SELECT COUNT(*) FROM contact_requests" >/dev/null; then fail "l'utilisateur du site peut lire la table"; else pass "l'utilisateur du site ne lit pas la table"; fi
    if sql_site "DELETE FROM contact_requests WHERE email = '$TEST_EMAIL'"; then fail "l'utilisateur du site peut supprimer"; else pass "l'utilisateur du site ne supprime pas"; fi
else
    echo "  (DB_MAINT_USER non défini : contrôle des droits sauté, un seul utilisateur en local)"
fi
# Trois adresses aux dates fabriquées : anciennes seulement, ancienne et récente, récente seulement.
PURGE_OLD="purge-old@example.invalid"
PURGE_MIXED="purge-mixed@example.invalid"
PURGE_RECENT="purge-recent@example.invalid"
purge_emails="'$PURGE_OLD','$PURGE_MIXED','$PURGE_RECENT'"
purge_row() { # purge_row EMAIL ÂGE_EN_JOURS (3 ans font 1095 ou 1096 jours)
    sql_site "INSERT INTO contact_requests (created_at, lang, universe, name, email, message, consent_text_version, ip_hash)
        VALUES (UTC_TIMESTAMP() - INTERVAL $2 DAY, 'fr', 'autre', 'Test purge', '$1', 'Demande de test pour la purge', 'test', REPEAT('0', 64))"
}
purge_count() { sql "SELECT COUNT(*) FROM contact_requests WHERE email = '$1'"; }
sql "DELETE FROM contact_requests WHERE email IN ($purge_emails)"
purge_row "$PURGE_OLD" 1900
purge_row "$PURGE_OLD" 1100
purge_row "$PURGE_MIXED" 1500
purge_row "$PURGE_MIXED" 1090
purge_row "$PURGE_RECENT" 60

output=$("$PHP" bin/purge-contacts.php --dry-run 2>&1)
if [[ "$output" =~ ^[0-9-]+T[0-9:]+Z\ purge-contacts\ simulation\ :\ ([0-9]+)\ demande ]] && [[ "${BASH_REMATCH[1]}" -ge 2 ]]; then
    pass "simulation : journal et nombre ($output)"
else
    fail "simulation : $output"
fi
expect "simulation : rien supprimé" "2|2|1" "$(purge_count "$PURGE_OLD")|$(purge_count "$PURGE_MIXED")|$(purge_count "$PURGE_RECENT")"

output=$("$PHP" bin/purge-contacts.php 2>&1)
if [[ "$output" =~ ^[0-9-]+T[0-9:]+Z\ purge-contacts\ ([0-9]+)\ demande\(s\)\ supprimée ]] && [[ "${BASH_REMATCH[1]}" -ge 2 ]]; then
    pass "purge : journal et nombre ($output)"
else
    fail "purge : $output"
fi
expect "purge : seule l'adresse dont le dernier envoi a plus de 3 ans est supprimée" "0|2|1" \
    "$(purge_count "$PURGE_OLD")|$(purge_count "$PURGE_MIXED")|$(purge_count "$PURGE_RECENT")"
expect "purge : option inconnue refusée" 2 "$("$PHP" bin/purge-contacts.php --tout >/dev/null 2>&1; echo $?)"
sql "DELETE FROM contact_requests WHERE email IN ($purge_emails)"

echo "4. Textes interdits"
files=(app bin lang public database CLAUDE.md)
if grep -rn $'—' "${files[@]}" >/dev/null 2>&1; then
    fail "tiret cadratin présent :"; grep -rn $'—' "${files[@]}"
else
    pass "aucun tiret cadratin"
fi
# CLAUDE.md énonce la règle « jamais djiboutien » : il est exclu de cette recherche.
for word in djiboutien PromptEspace "Labo Tech" CEREBRO Reserva googleapis gstatic; do
    if grep -rni "$word" app bin lang public database >/dev/null 2>&1; then
        fail "« $word » présent :"; grep -rni "$word" app bin lang public database
    else
        pass "aucune occurrence de « $word »"
    fi
done

echo
if [[ $failures -eq 0 ]]; then echo "Tous les tests passent."; else echo "$failures test(s) en échec."; fi
exit $(( failures > 0 ))
