#!/usr/bin/env bash
# Tests du site en local (MAMP). Usage : tests/run.sh
# Variables facultatives : BASE_URL (défaut : APP_URL du .env), PHP, MYSQL.
# Attention : vide storage/ratelimit/ et supprime de la base les envois de test (@example.invalid).

set -u
cd "$(dirname "$0")/.."

env_value() { grep -E "^$1=" .env | head -n 1 | cut -d= -f2- | sed -e "s/^[\"']//" -e "s/[\"']$//"; }

PHP="${PHP:-php}"
MYSQL="${MYSQL:-/Applications/MAMP/Library/bin/mysql80/bin/mysql}"
BASE_URL="${BASE_URL:-$(env_value APP_URL)}"
DB_HOST_PORT="$(env_value DB_HOST)"
DB_HOST="${DB_HOST_PORT%%:*}"
DB_PORT="3306"
[[ "$DB_HOST_PORT" == *:* ]] && DB_PORT="${DB_HOST_PORT##*:}"
TEST_EMAIL="test-run@example.invalid"

failures=0
pass() { printf '  ok   %s\n' "$1"; }
fail() { printf '  ECHEC %s\n' "$1"; failures=$((failures + 1)); }
expect() { # expect LIBELLÉ ATTENDU OBTENU
    if [[ "$2" == "$3" ]]; then pass "$1 ($3)"; else fail "$1 : attendu $2, obtenu $3"; fi
}
sql() {
    MYSQL_PWD="$(env_value DB_PASS)" "$MYSQL" -h"$DB_HOST" -P"$DB_PORT" -u"$(env_value DB_USER)" \
        -N -B "$(env_value DB_NAME)" -e "$1" 2>/dev/null
}
token() { curl -s "$BASE_URL/contact.php?lang=fr" | grep -o 'name="token" value="[^"]*"' | sed -e 's/.*value="//' -e 's/"$//'; }

echo "1. Syntaxe PHP"
while IFS= read -r file; do
    if "$PHP" -l "$file" >/dev/null 2>&1; then :; else fail "php -l $file"; fi
done < <(find app lang public -name '*.php')
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

echo "4. Textes interdits"
files=(app lang public database CLAUDE.md)
if grep -rn $'—' "${files[@]}" >/dev/null 2>&1; then
    fail "tiret cadratin présent :"; grep -rn $'—' "${files[@]}"
else
    pass "aucun tiret cadratin"
fi
# CLAUDE.md énonce la règle « jamais djiboutien » : il est exclu de cette recherche.
for word in djiboutien PromptEspace "Labo Tech" CEREBRO Reserva googleapis gstatic; do
    if grep -rni "$word" app lang public database >/dev/null 2>&1; then
        fail "« $word » présent :"; grep -rni "$word" app lang public database
    else
        pass "aucune occurrence de « $word »"
    fi
done

echo
if [[ $failures -eq 0 ]]; then echo "Tous les tests passent."; else echo "$failures test(s) en échec."; fi
exit $(( failures > 0 ))
