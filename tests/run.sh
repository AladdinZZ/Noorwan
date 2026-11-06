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
# Jeton du formulaire de contact (la page peut aussi contenir celui du bandeau de consentement).
token() { curl -s "$BASE_URL/contact.php?lang=fr" | sed -n '/<form class="contact-form"/,/<\/form>/p' | grep -o 'name="token" value="[^"]*"' | head -n 1 | sed -e 's/.*value="//' -e 's/"$//'; }
# Textes attendus par langue (bash 3.2 de macOS : pas de tableau associatif). by_lang LANGUE FR EN AR
by_lang() { case "$1" in fr) echo "$2" ;; en) echo "$3" ;; ar) echo "$4" ;; esac; }

echo "1. Syntaxe PHP"
while IFS= read -r file; do
    if "$PHP" -l "$file" >/dev/null 2>&1; then :; else fail "php -l $file"; fi
done < <(find app bin lang public -name '*.php')
[[ $failures -eq 0 ]] && pass "php -l sur tous les fichiers"

echo "2. Pages (code 200 attendu) sur $BASE_URL"
for page in "" solutions.php edition.php contact.php mentions-legales.php confidentialite.php cookies.php; do
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
expect "sitemap.xml : 7 pages x 3 langues" 21 "$(grep -c '<loc>' <<< "$sitemap")"
expect "sitemap.xml : 4 versions par adresse (fr, en, ar, x-default)" 84 "$(grep -c 'hreflang=' <<< "$sitemap")"
if command -v xmllint >/dev/null; then
    xmllint --noout - <<< "$sitemap" 2>/dev/null && pass "sitemap.xml bien formé" || fail "sitemap.xml mal formé"
fi

echo "2 quater. Pages légales"
for lang in fr en ar; do
    html=$(curl -s "$BASE_URL/confidentialite.php?lang=$lang")
    if grep -q 'COMPLÉTER' <<< "$html"; then fail "Confidentialité ($lang) : marqueur [À COMPLÉTER] restant"; else pass "Confidentialité ($lang) : aucun [À COMPLÉTER]"; fi
    grep -q 'href="mailto:contact@noorwan.com"' <<< "$html" && pass "Confidentialité ($lang) : adresse de contact" || fail "Confidentialité ($lang) : adresse de contact absente"
    # Fichiers de limite d'envoi purgés toutes les heures après une heure d'inactivité : 2 heures au plus.
    duration=$(by_lang "$lang" "2 heures au plus" "2 hours at most" "ساعتان على الأكثر")
    grep -q "$duration" <<< "$html" && pass "Confidentialité ($lang) : limite d'envoi, « $duration »" || fail "Confidentialité ($lang) : durée de la limite d'envoi"
    if grep -qE ': 1 heure\.|: 1 hour\.|: ساعة واحدة\.' <<< "$html"; then fail "Confidentialité ($lang) : ancienne durée « 1 heure » restante"; else pass "Confidentialité ($lang) : plus de « 1 heure »"; fi
done

for lang in fr en ar; do
    html=$(curl -s "$BASE_URL/mentions-legales.php?lang=$lang")
    if grep -q 'COMPLÉTER' <<< "$html"; then fail "Mentions légales ($lang) : marqueur [À COMPLÉTER] restant"; else pass "Mentions légales ($lang) : aucun [À COMPLÉTER]"; fi
    grep -q 'class="legal-notice"' <<< "$html" && grep -q 'href="mailto:contact@noorwan.com"' <<< "$html" && grep -q 'IONOS' <<< "$html" \
        && pass "Mentions légales ($lang) : encadré avec éditeur, contact et hébergement" || fail "Mentions légales ($lang) : encadré incomplet"
    grep -q 'A FAIRE RELIRE PAR UN JURISTE' <<< "$html" && pass "Mentions légales ($lang) : commentaire juriste conservé" || fail "Mentions légales ($lang) : commentaire juriste absent"
done

echo "2 quinquies. Menu des langues"
for lang in fr en ar; do
    header=$(curl -s "$BASE_URL/edition.php?lang=$lang" | sed -n '/<header/,/<\/header>/p')
    grep -q '<details class="lang-menu">' <<< "$header" && pass "menu des langues en <details> ($lang)" || fail "menu des langues absent ($lang)"
    if grep -q 'lang-switch' <<< "$header"; then fail "anciens boutons de langue encore présents ($lang)"; else pass "plus de boutons de langue ($lang)"; fi
    expect "trois langues dans leur propre langue ($lang)" "Français|English|العربية" \
        "$(grep -oE 'hreflang="(fr|en|ar)"[^>]*>[^<]+' <<< "$header" | sed 's/.*>//' | paste -sd '|' -)"
    expect "liens du menu sur la même page ($lang)" 3 "$(grep -cE 'href="edition\.php\?lang=(fr|en|ar)" lang=' <<< "$header")"
    expect "langue courante marquée ($lang)" "$lang" "$(grep -oE 'lang="[a-z]+" hreflang="[a-z]+" aria-current="true"' <<< "$header" | sed -E 's/lang="([a-z]+)".*/\1/')"
done

echo "2 sexies. Accueil, maquette A : haut de page et trois univers"
for lang in fr en ar; do
    home=$(curl -s "$BASE_URL/?lang=$lang")
    hero=$(sed -n '/<section id="top" class="screen hero"/,/<\/section>/p' <<< "$home")
    expect "haut de page : titre en deux temps, accroche, 2 liens, visuel ($lang)" "1|1|1|2|1" \
        "$(grep -c '<h1 id="hero-title" class="h1">' <<< "$hero")|$(grep -c 'class="h1-soft"' <<< "$hero")|$(grep -c 'class="lead"' <<< "$hero")|$(grep -c 'class="more"' <<< "$hero")|$(grep -c 'class="hero-visual"' <<< "$hero")"
    motto=$(by_lang "$lang" "Une vision claire." "A clear vision." "رؤية واضحة.")
    grep -qF "class=\"h1\">$motto <span" <<< "$hero" && pass "haut de page : « $motto » ($lang)" || fail "haut de page : devise ($lang)"
    expect "trois univers numérotés, un écran chacun ($lang)" "01|02|03" \
        "$(grep -o '<p class="num" aria-hidden="true">0[0-9]</p>' <<< "$home" | sed -E 's/.*>(0[0-9])<.*/\1/' | paste -sd '|' -)"
    expect "cinq expertises du Consulting ($lang)" 5 "$(sed -n '/<ul class="expertises">/,/<\/ul>/p' <<< "$home" | grep -c '<li>')"
    expect "approche : quatre étapes ($lang)" 4 "$(sed -n '/<ol class="steps">/,/<\/ol>/p' <<< "$home" | grep -c '<li>')"
    grep -q 'id="contact" class="screen screen-mist cta"' <<< "$home" && pass "bandeau contact en bas de l'accueil ($lang)" || fail "bandeau contact ($lang)"
done

echo "2 septies. Accueil : Édition et textes à fournir"
for lang in fr en ar; do
    home=$(curl -s "$BASE_URL/?lang=$lang")
    section=$(sed -n '/<section id="edition" class="screen tone-edition"/,/<\/section>/p' <<< "$home")
    tag=$(by_lang "$lang" "Noorwan Édition" "Noorwan Publishing" "نوروان للنشر")
    grep -q "<p class=\"eyebrow\">$tag</p>" <<< "$section" && pass "petit titre « $tag » ($lang)" || fail "petit titre de la section Édition ($lang)"
    expect "trilogie : deux couvertures et un tome à paraître ($lang)" "2|1" \
        "$(grep -c '<img class="cover"' <<< "$section")|$(grep -c 'class="cover-soon"' <<< "$section")"
    grep -q "href=\"edition.php?lang=$lang#catalogue\"" <<< "$section" && pass "lien vers le catalogue ($lang)" || fail "lien vers le catalogue absent ($lang)"
    grep -q "href=\"contact.php?lang=$lang&amp;universe=edition\"" <<< "$section" && pass "« Publier votre livre » vers le formulaire ($lang)" || fail "lien Publier votre livre ($lang)"
    # Textes manquants : visibles, surlignés, jamais inventés.
    expect "accueil : textes à fournir surlignés (phrase d'auteur, Pourquoi Noorwan) ($lang)" 2 "$(grep -c '<mark class="todo">\[À FOURNIR : ' <<< "$home")"
done

echo "2 octies. Page Édition : livre à paraître"
for lang in fr en ar; do
    html=$(curl -s "$BASE_URL/edition.php?lang=$lang")
    heading=$(by_lang "$lang" "Prochainement" "Coming soon" "قريبًا")
    grep -q "<h3 id=\"collection-upcoming\">$heading</h3>" <<< "$html" && pass "rubrique « $heading » ($lang)" || fail "rubrique « $heading » absente ($lang)"
    expect "rubrique placée après les deux collections ($lang)" "collection-metaphysique|collection-chemins|collection-upcoming" \
        "$(grep -oE '<h3 id="collection-[a-z]+"' <<< "$html" | sed -E 's/.*"(collection-[a-z]+)"/\1/' | paste -sd '|' -)"
    book=$(sed -n '/<article class="book" aria-labelledby="book-belles-manieres">/,/<\/article>/p' <<< "$html")
    grep -q '<bdi>Les belles manières du petit musulman</bdi>' <<< "$book" && pass "titre en français ($lang)" || fail "titre du livre à paraître ($lang)"
    grep -q 'src="assets/images/covers/couverture_belles_manieres.webp"' <<< "$book" && pass "couverture du livre à paraître ($lang)" || fail "couverture du livre à paraître ($lang)"
    expect "étiquette « À paraître », sans bouton « Acheter » ($lang)" "1|0" \
        "$(grep -c "<p class=\"book-flag\">$(by_lang "$lang" "À paraître" "Forthcoming" "سيصدر قريبًا")</p>" <<< "$book")|$(grep -c 'book-buy' <<< "$book")"
    expect "boutons « Acheter » des livres parus ($lang)" 5 "$(grep -c 'class="btn btn-dark book-buy"' <<< "$html")"
    expect "quatre étapes de la prestation ($lang)" 4 "$(sed -n '/<ol class="steps">/,/<\/ol>/p' <<< "$html" | grep -c '<li>')"
    expect "textes à fournir surlignés (ASIN, phrase d'auteur) ($lang)" 2 "$(grep -c '<mark class="todo">\[À FOURNIR : ' <<< "$html")"
done
expect "couverture_belles_manieres.webp servie" 200 "$(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/assets/images/covers/couverture_belles_manieres.webp")"

echo "2 nonies. Solutions : produits sur l'accueil et sur la page"
grep -q '/solutions.php?lang=fr</loc>' <<< "$sitemap" && pass "page Solutions dans le plan du site" || fail "page Solutions absente du plan du site"
for lang in fr en ar; do
    home=$(curl -s "$BASE_URL/?lang=$lang")
    nav=$(sed -n '/<nav class="nav-desktop"/,/<\/nav>/p' <<< "$home")
    grep -q "href=\"solutions.php?lang=$lang\">$(by_lang "$lang" "Solutions" "Solutions" "الحلول")<" <<< "$nav" && pass "menu : Solutions mène à solutions.php ($lang)" || fail "menu : lien Solutions ($lang)"
    for page in "" solutions.php; do
        html=$(curl -s "$BASE_URL/$page?lang=$lang")
        expect "produits Reserva, Inteek, Noor, Édition, un seul confidentiel (${page:-index}, $lang)" "reserva|inteek|noor|edition|1" \
            "$(grep -oE '<article id="product-[a-z]+"' <<< "$html" | sed -E 's/.*product-([a-z]+)"/\1/' | paste -sd '|' -)|$(grep -c 'class="badge-confidential"' <<< "$html")"
        grep -q 'id="product-noor"' <<< "$html" && sed -n '/id="product-noor"/,/<\/article>/p' <<< "$html" | grep -q 'badge-confidential' \
            && pass "Noor marqué « Confidentiel » (${page:-index}, $lang)" || fail "Noor sans mention Confidentiel (${page:-index}, $lang)"
        expect "Immobilier et Shopping « bientôt » (${page:-index}, $lang)" 2 "$(sed -n '/<div class="soon-row">/,/<\/ul>/p' <<< "$html" | grep -c '<li>')"
    done

    page=$(curl -s "$BASE_URL/solutions.php?lang=$lang")
    grep -q '<!-- TEXTES A VALIDER PAR MARWAN -->' <<< "$page" && pass "page Solutions : textes marqués à valider ($lang)" || fail "page Solutions : commentaire de validation absent ($lang)"
    grep -q "<h1 id=\"page-title\" class=\"h1 h1-page\">$(by_lang "$lang" "Des outils conçus pour les entreprises" "Tools built for businesses" "أدوات مصممة للمؤسسات")</h1>" <<< "$page" \
        && pass "page Solutions : titre ($lang)" || fail "page Solutions : titre ($lang)"
    expect "page Solutions : 3 principes, 5 modules d'Inteek ($lang)" "3|5" \
        "$(sed -n '/<ol class="principles">/,/<\/ol>/p' <<< "$page" | grep -c '<li>')|$(sed -n '/<ul class="modules">/,/<\/ul>/p' <<< "$page" | grep -c '<li>')"
    grep -q "href=\"#inteek\"" <<< "$page" && pass "page Solutions : carte Inteek mène à sa présentation ($lang)" || fail "page Solutions : lien vers #inteek ($lang)"
    expect "page Solutions : « Demander une présentation » vers le formulaire, univers Solutions ($lang)" 5 \
        "$(grep -c "href=\"contact.php?lang=$lang&amp;universe=solutions\">$(by_lang "$lang" "Demander une présentation" "Request a presentation" "اطلب عرضًا تقديميًا")" <<< "$page")"
    # Ni prix ni chiffres de clients : aucun montant ni symbole monétaire sur la page.
    if sed -n '/<main/,/<\/main>/p' <<< "$page" | grep -qiE '[0-9] ?(€|\$|FDJ|USD|EUR)|€|prix|price|clients'; then fail "page Solutions : prix ou clients cités ($lang)"; else pass "page Solutions : ni prix ni clients ($lang)"; fi
done
grep -q '<option value="solutions" selected>' <<< "$(curl -s "$BASE_URL/contact.php?lang=fr&universe=solutions")" && pass "formulaire : univers Solutions présélectionné" || fail "formulaire : univers Solutions non présélectionné"

echo "2 decies. Date de mise à jour des pages légales"
for page in mentions-legales.php confidentialite.php cookies.php; do
    for lang in fr en ar; do
        date=$(by_lang "$lang" "Dernière mise à jour : 6 novembre 2026" "Last updated: 6 November 2026" "آخر تحديث: 6 نوفمبر 2026")
        grep -q "<p class=\"legal-updated\">$date</p>" <<< "$(curl -s "$BASE_URL/$page?lang=$lang")" && pass "$page ($lang) : mise à jour du 6/11/2026" || fail "$page ($lang) : date de mise à jour"
    done
done

echo "2 undecies. Lien « Connexion » vers le Compte Noorwan"
# Rendu hors serveur, constantes fixées avant l'amorçage : les états se testent sans toucher au .env.
# render PAGE LANGUE ACTIVÉ [ADRESSE] [GTM_ID] [CHOIX]
# Écosystème sans adresse : les pages rendues ne dépendent pas des réglages du .env local.
render() {
    ECOSYSTEM_ACCOUNT_URL= ECOSYSTEM_RESERVA_URL= ECOSYSTEM_INTEEK_URL= "$PHP" -r '[, $page, $lang, $enabled, $url, $gtm, $consent] = $argv + [4 => "", 5 => "", 6 => ""];
        define("COMPTE_LINK_ENABLED", $enabled === "true");
        if ($url !== "") { define("COMPTE_URL", $url); }
        define("GTM_ID", $gtm);
        if ($consent !== "") { $_COOKIE["nw_consent"] = $consent; }
        $_GET["lang"] = $lang;
        require "public/" . $page;' "$@" 2>&1
}
COMPTE_DEFAULT="https://compte.noorwan.com"
for lang in fr en ar; do
    for page in index.php solutions.php edition.php; do
        html=$(render "$page" "$lang" false)
        expect "désactivé : aucun lien vers le Compte, $page ($lang)" 0 "$(grep -cE 'compte\.noorwan\.com|nav-account|btn-account|page-account' <<< "$html")"
    done

    label=$(by_lang "$lang" "Connexion" "Sign in" "الدخول")
    href="$COMPTE_DEFAULT/?lang=$lang"
    html=$(render solutions.php "$lang" true)
    expect "activé : pastille « $label » dans la barre ($lang)" "<a class=\"btn-account\" href=\"$href\">$label</a>" \
        "$(sed -n '/<div class="header-tools">/,/<details/p' <<< "$html" | grep -o '<a [^>]*>[^<]*</a>')"
    expect "activé : dernier élément du menu mobile ($lang)" "<a href=\"$href\" class=\"nav-account\">$label</a>" \
        "$(sed -n '/<nav id="nav-mobile"/,/<\/nav>/p' <<< "$html" | grep -o '<a [^>]*>[^<]*</a>' | tail -n 1)"
    expect "activé : colonne Noorwan du pied de page ($lang)" "<a href=\"$href\" class=\"nav-account\">$label</a>" \
        "$(sed -n '/<nav class="footer-cols"/,/<\/nav>/p' <<< "$html" | grep -o '<a [^>]*>[^<]*</a>' | tail -n 1)"
    phrase=$(by_lang "$lang" "Un seul compte pour tous les services Noorwan." "One account for all Noorwan services." "حساب واحد لجميع خدمات نوروان.")
    account=$(sed -n '/<section class="page-hero/,/<\/section>/p' <<< "$html" | grep 'class="page-account"')
    grep -qF "<p class=\"page-account\">$phrase <a href=\"$href\">$label " <<< "$account" \
        && pass "activé : page Solutions, phrase et lien sous l'introduction ($lang)" || fail "activé : phrase du Compte sur la page Solutions ($lang) : $account"
    expect "activé : 4 liens sur la page Solutions, tous dans la langue ($lang)" "4|4" \
        "$(grep -c 'compte\.noorwan\.com' <<< "$html")|$(grep -c "href=\"$href\"" <<< "$html")"
    if grep -q $'—' <<< "$html"; then fail "activé : tiret cadratin dans la page ($lang)"; else pass "activé : aucun tiret cadratin ($lang)"; fi
    html=$(render index.php "$lang" true)
    expect "activé : accueil, barre, menu mobile et pied de page, sans phrase ($lang)" "3|0" \
        "$(grep -c "href=\"$href\"" <<< "$html")|$(grep -c 'page-account' <<< "$html")"
done
expect "adresse du Compte modifiable sans toucher aux vues" 4 \
    "$(render solutions.php en true https://compte.example.invalid | grep -c 'href="https://compte.example.invalid/?lang=en"')"
# Site servi : l'état suit COMPTE_LINK_ENABLED (masqué par défaut).
served_links=$(curl -s "$BASE_URL/solutions.php?lang=fr" | grep -c 'nav-account\|btn-account\|page-account')
if [[ "$(config COMPTE_LINK_ENABLED false)" == "true" ]]; then
    expect "site servi : lien affiché (COMPTE_LINK_ENABLED=true)" 4 "$served_links"
else
    expect "site servi : lien masqué (COMPTE_LINK_ENABLED désactivé)" 0 "$served_links"
fi
grep -q '^COMPTE_LINK_ENABLED=false$' .env.example && pass ".env.example : lien désactivé par défaut" || fail ".env.example : COMPTE_LINK_ENABLED=false absent"

echo "2 duodecies. Consentement et Tag Manager (M-59)"
GTM_TEST="GTM-TEST000"
for lang in fr en ar; do
    for page in index.php contact.php cookies.php; do
        html=$(render "$page" "$lang" false "" "")
        expect "GTM_ID vide : ni Google, ni bandeau, ni « Gérer les cookies », $page ($lang)" 0 \
            "$(grep -cE 'googletagmanager|gtm-bootstrap|id="consent"|data-consent-open|consent-manage' <<< "$html")"
    done
    html=$(render index.php "$lang" false "" "$GTM_TEST")
    expect "sans accord : aucun script Tag Manager ($lang)" 0 "$(grep -c 'googletagmanager' <<< "$html")"
    grep -q "<script nonce=\"[A-Za-z0-9+/=]\{24\}\" id=\"gtm-bootstrap\" data-gtm-id=\"$GTM_TEST\">" <<< "$html" && pass "sans accord : amorçage avec nonce ($lang)" || fail "sans accord : amorçage absent ($lang)"
    grep -q "gtag('consent', 'default', { ad_storage: 'denied', ad_user_data: 'denied', ad_personalization: 'denied', analytics_storage: 'denied' });" <<< "$html" \
        && pass "sans accord : mode consentement « default » à « denied » ($lang)" || fail "sans accord : consentement par défaut ($lang)"
    banner=$(sed -n '/<section id="consent"/,/<\/section>/p' <<< "$html")
    title=$(by_lang "$lang" "Mesure d&apos;audience" "Audience measurement" "قياس عدد الزوار")
    grep -qF "$title" <<< "$banner" && pass "bandeau ouvert, « $title » ($lang)" || fail "bandeau absent ($lang)"
    if head -n 1 <<< "$banner" | grep -q ' hidden'; then fail "bandeau masqué avant tout choix ($lang)"; else pass "bandeau visible avant tout choix ($lang)"; fi
    expect "bandeau : Refuser et Accepter, même style ($lang)" "denied|granted" \
        "$(grep -oE 'class="btn btn-consent" type="submit" name="choice" value="[a-z]+"' <<< "$banner" | sed -E 's/.*value="([a-z]+)"/\1/' | paste -sd '|' -)"
    grep -q "data-consent-open>$(by_lang "$lang" "Gérer les cookies" "Manage cookies" "إدارة ملفات تعريف الارتباط")<" <<< "$html" && pass "« Gérer les cookies » dans le pied de page ($lang)" || fail "« Gérer les cookies » absent ($lang)"

    html=$(render index.php "$lang" false "" "$GTM_TEST" granted)
    grep -q "j.src = 'https://www.googletagmanager.com/gtm.js?id=' + i;" <<< "$html" && grep -q "'dataLayer', '$GTM_TEST');" <<< "$html" \
        && pass "après accord : script Tag Manager présent ($lang)" || fail "après accord : script Tag Manager absent ($lang)"
    grep -q "gtag('consent', 'update', { analytics_storage: 'granted' });" <<< "$html" && pass "après accord : « update » à « granted » ($lang)" || fail "après accord : mise à jour du consentement ($lang)"
    expect "après accord : tout script en ligne porte le nonce, un seul nonce ($lang)" "0|1" \
        "$(grep -E '<script( |>)' <<< "$html" | grep -v ' src=' | grep -vc 'nonce=')|$(grep -oE 'nonce="[^"]+"' <<< "$html" | sort -u | wc -l | tr -d ' ')"
    grep -q '<section id="consent" class="consent" aria-labelledby="consent-title" hidden data-state="granted">' <<< "$html" && pass "après accord : bandeau fermé ($lang)" || fail "après accord : bandeau encore ouvert ($lang)"
    html=$(render index.php "$lang" false "" "$GTM_TEST" denied)
    expect "après refus : aucun script Tag Manager, bandeau fermé ($lang)" "0|1" \
        "$(grep -c 'googletagmanager' <<< "$html")|$(grep -c 'hidden data-state="denied"' <<< "$html")"
    html=$(render cookies.php "$lang" false "" "$GTM_TEST" denied)
    grep -q '<section id="consent-manage"' <<< "$html" && grep -qF "$(by_lang "$lang" "mesure d&apos;audience refusée" "audience measurement declined" "رفض قياس عدد الزوار")" <<< "$html" \
        && pass "page Cookies : « Gérer vos choix » et état actuel ($lang)" || fail "page Cookies : gestion des choix ($lang)"
done
expect "identifiant mal formé ignoré" 0 "$(GTM_ID='GTM-x"><script>' "$PHP" -r '$_GET["lang"]="fr"; require "public/index.php";' 2>&1 | grep -c 'gtm-bootstrap')"
grep -q '^GTM_ID=$' .env.example && pass ".env.example : GTM_ID vide par défaut" || fail ".env.example : GTM_ID absent ou rempli"

echo "2 terdecies. CSP"
csp_served=$(curl -sI "$BASE_URL/?lang=fr" | grep -i '^Content-Security-Policy:')
if grep -q 'unsafe-inline' <<< "$csp_served"; then fail "CSP servie : unsafe-inline"; else pass "CSP servie : sans unsafe-inline"; fi
if [[ -z "$(config GTM_ID)" ]]; then
    if grep -qiE 'google|nonce-' <<< "$csp_served"; then fail "CSP servie sans GTM_ID : ouverte à Google"; else pass "CSP servie sans GTM_ID : fermée à Google"; fi
fi
csp_gtm=$(GTM_ID="$GTM_TEST" "$PHP" -r 'require "app/bootstrap.php"; echo content_security_policy();' 2>&1)
for part in "script-src 'self' 'nonce-" "https://www.googletagmanager.com" "img-src 'self' data: https://www.googletagmanager.com https://*.google-analytics.com" \
            "connect-src 'self' https://www.googletagmanager.com https://*.google-analytics.com https://*.analytics.google.com" "style-src 'self';"; do
    grep -qF "$part" <<< "$csp_gtm" && pass "CSP avec GTM_ID : $part" || fail "CSP avec GTM_ID : « $part » absent ($csp_gtm)"
done
if grep -q 'unsafe-inline\|unsafe-eval' <<< "$csp_gtm"; then fail "CSP avec GTM_ID : unsafe-inline ou unsafe-eval"; else pass "CSP avec GTM_ID : ni unsafe-inline ni unsafe-eval"; fi

echo "2 quaterdecies. Enregistrement du choix (consent.php)"
consent_token() { "$PHP" -r 'require "app/bootstrap.php"; echo Csrf::token("consent");' 2>/dev/null; }
expect "GET refusé" 405 "$(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/consent.php")"
expect "jeton absent refusé" 400 "$(curl -s -o /dev/null -w '%{http_code}' -X POST -d 'choice=granted' "$BASE_URL/consent.php")"
expect "choix inconnu refusé" 400 "$(curl -s -o /dev/null -w '%{http_code}' -X POST --data-urlencode "token=$(consent_token)" -d 'choice=peut-etre' "$BASE_URL/consent.php")"
response=$(curl -s -D - -o /dev/null -X POST --data-urlencode "token=$(consent_token)" -d 'choice=granted' --data-urlencode 'back=edition.php?lang=ar' "$BASE_URL/consent.php?lang=ar")
grep -q '^HTTP/[0-9.]* 303' <<< "$response" && pass "accord : redirection 303" || fail "accord : $(head -n 1 <<< "$response")"
grep -qi '^Location: edition.php?lang=ar' <<< "$response" && pass "accord : retour à la page d'origine" || fail "accord : mauvais retour"
cookie=$(grep -i '^Set-Cookie: nw_consent=' <<< "$response")
grep -q 'nw_consent=granted' <<< "$cookie" && grep -q 'Max-Age=15724800' <<< "$cookie" && grep -qi 'HttpOnly' <<< "$cookie" && grep -qi 'SameSite=Lax' <<< "$cookie" && grep -q 'path=/' <<< "$cookie" \
    && pass "accord : cookie nw_consent, six mois, HttpOnly, SameSite=Lax" || fail "accord : cookie $cookie"
expect "un seul cookie posé" 1 "$(grep -ci '^Set-Cookie:' <<< "$response")"
response=$(curl -s -D - -o /dev/null -X POST --data-urlencode "token=$(consent_token)" -d 'choice=granted' --data-urlencode 'back=https://exemple.invalid/' "$BASE_URL/consent.php")
grep -qi '^Location: ./?lang=fr' <<< "$response" && pass "retour vers un site externe refusé" || fail "retour externe : $(grep -i '^Location' <<< "$response")"
response=$(curl -s -D - -o /dev/null -X POST -H 'Accept: application/json' -H 'Cookie: _ga=GA1.1.1; _ga_ABC123=GS1.1' --data-urlencode "token=$(consent_token)" -d 'choice=denied' "$BASE_URL/consent.php")
grep -q '^HTTP/[0-9.]* 204' <<< "$response" && pass "refus en arrière-plan : réponse 204" || fail "refus en arrière-plan : $(head -n 1 <<< "$response")"
grep -q 'nw_consent=denied' <<< "$response" && pass "refus : cookie nw_consent=denied" || fail "refus : cookie absent"
expect "refus : cookies Google Analytics effacés" 2 "$(grep -ciE '^Set-Cookie: _ga(_ABC123)?=deleted' <<< "$response")"
expect "jeton signé : choix forgé refusé" 400 "$(curl -s -o /dev/null -w '%{http_code}' -X POST -d 'token=1.2.3&choice=granted' "$BASE_URL/consent.php")"

echo "2 sexdecies. OnePay absent de toutes les pages"
for page in "" solutions.php edition.php contact.php mentions-legales.php confidentialite.php cookies.php; do
    for lang in fr en ar; do
        if curl -s "$BASE_URL/$page?lang=$lang" | grep -qi 'onepay'; then fail "OnePay présent : /${page:-index} ($lang)"; else pass "OnePay absent : /${page:-index} ($lang)"; fi
    done
done
for lang in fr en ar; do
    if render index.php "$lang" true "" "$GTM_TEST" granted | grep -qi 'onepay'; then fail "OnePay présent, tout activé ($lang)"; else pass "OnePay absent, tout activé ($lang)"; fi
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

echo "3 ter. Purge des fichiers de limite d'envoi (plus d'une heure)"
mkdir -p storage/ratelimit
RL_OLD="storage/ratelimit/purgetest-old.log"
RL_RECENT="storage/ratelimit/purgetest-recent.log"
printf '1\n' > "$RL_OLD"
printf '1\n' > "$RL_RECENT"
# Âge fixé par PHP pour rester portable (touch -d et date -v diffèrent entre macOS et Linux).
"$PHP" -r 'touch($argv[1], time() - 7200); touch($argv[2], time() - 600);' "$RL_OLD" "$RL_RECENT"
rl_state() { printf '%s|%s' "$([[ -f "$RL_OLD" ]] && echo ancien || echo -)" "$([[ -f "$RL_RECENT" ]] && echo récent || echo -)"; }

output=$("$PHP" bin/purge-contacts.php --dry-run 2>&1)
if [[ "$output" =~ simulation\ :\ [0-9]+\ demande\(s\)\ et\ ([0-9]+)\ fichier\(s\)\ de\ limite\ d\'envoi\ à\ supprimer ]] && [[ "${BASH_REMATCH[1]}" -ge 1 ]]; then
    pass "simulation : fichiers comptés dans le journal ($output)"
else
    fail "simulation : compte des fichiers absent ($output)"
fi
expect "simulation : aucun fichier supprimé" "ancien|récent" "$(rl_state)"

output=$("$PHP" bin/purge-contacts.php 2>&1)
if [[ "$output" =~ demande\(s\)\ supprimée\(s\),\ ([0-9]+)\ fichier\(s\)\ de\ limite\ d\'envoi\ supprimé ]] && [[ "${BASH_REMATCH[1]}" -ge 1 ]]; then
    pass "purge : fichiers comptés dans le journal ($output)"
else
    fail "purge : compte des fichiers absent ($output)"
fi
expect "purge : seul le fichier de plus d'une heure est supprimé" "-|récent" "$(rl_state)"
rm -f "$RL_OLD" "$RL_RECENT"

echo "4. Textes interdits"
files=(app bin lang public database CLAUDE.md)
if grep -rn $'—' "${files[@]}" >/dev/null 2>&1; then
    fail "tiret cadratin présent :"; grep -rn $'—' "${files[@]}"
else
    pass "aucun tiret cadratin"
fi
# CLAUDE.md énonce la règle « jamais djiboutien » : il est exclu de cette recherche.
for word in djiboutien PromptEspace "Labo Tech" CEREBRO OnePay googleapis gstatic; do
    if grep -rni "$word" app bin lang public database >/dev/null 2>&1; then
        fail "« $word » présent :"; grep -rni "$word" app bin lang public database
    else
        pass "aucune occurrence de « $word »"
    fi
done

echo
if [[ $failures -eq 0 ]]; then echo "Tous les tests passent."; else echo "$failures test(s) en échec."; fi
exit $(( failures > 0 ))
