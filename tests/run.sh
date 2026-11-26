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
# Page sans le volet du lanceur : OnePay (M-123) ne paraît que dans la grille des sites, nulle part ailleurs.
without_launcher() { sed '/<div id="launcher-panel"/,/^<\/div>/d'; }
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
for page in "" consulting solutions.php edition.php connect contact.php mentions-legales.php confidentialite.php cookies.php; do
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
# Icônes communes (M-120) : à la racine publique, déclarées avec leur version sur chaque page
for icon in favicon.ico favicon.svg apple-touch-icon.png; do
    expect "/$icon" 200 "$(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/$icon")"
done
icons_html=$(curl -s "$BASE_URL/mentions-legales.php?lang=fr")
expect "icônes déclarées (SVG, ICO, écran d'accueil)" "1|1|1" "$(grep -c '<link rel="icon" href="favicon.svg?v=[0-9]*" type="image/svg+xml">' <<< "$icons_html")|$(grep -c '<link rel="icon" href="favicon.ico?v=[0-9]*" sizes="48x48">' <<< "$icons_html")|$(grep -c '<link rel="apple-touch-icon" href="apple-touch-icon.png?v=[0-9]*">' <<< "$icons_html")"
expect "ancienne icône retirée" 404 "$(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/assets/images/favicon.svg")"

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
expect "sitemap.xml : 9 pages x 3 langues" 27 "$(grep -c '<loc>' <<< "$sitemap")"
expect "sitemap.xml : 4 versions par adresse (fr, en, ar, x-default)" 108 "$(grep -c 'hreflang=' <<< "$sitemap")"
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

echo "2 sexies. Accueil (v6) : haut de page, puis un résumé par onglet avec « En savoir plus »"
for lang in fr en ar; do
    home=$(curl -s "$BASE_URL/?lang=$lang")
    hero=$(sed -n '/<section id="top" class="screen hero"/,/<\/section>/p' <<< "$home")
    expect "haut de page : sans petit titre, titre en deux temps, accroche, 2 liens, visuel ($lang)" "0|1|1|1|2|1" \
        "$(grep -c 'class="eyebrow' <<< "$hero")|$(grep -c '<h1 id="hero-title" class="h1">' <<< "$hero")|$(grep -c 'class="h1-soft"' <<< "$hero")|$(grep -c 'class="lead"' <<< "$hero")|$(grep -c 'class="more"' <<< "$hero")|$(grep -c 'class="hero-visual"' <<< "$hero")"
    motto=$(by_lang "$lang" "Une vision claire." "A clear vision." "رؤية واضحة.")
    grep -qF "class=\"h1\">$motto <span" <<< "$hero" && pass "haut de page : « $motto » ($lang)" || fail "haut de page : devise ($lang)"
    grep -q "href=\"consulting?lang=$lang\">$(by_lang "$lang" "Découvrir nos expertises" "Explore our expertise" "اكتشف خبراتنا")<" <<< "$hero" && pass "haut de page : expertises vers /consulting ($lang)" || fail "haut de page : lien des expertises ($lang)"
    expect "trois résumés numérotés : Consulting, Solutions, Noorwan Connect ($lang)" "01|02|03" \
        "$(grep -o '<p class="num" aria-hidden="true">0[0-9]</p>' <<< "$home" | sed -E 's/.*>(0[0-9])<.*/\1/' | paste -sd '|' -)"
    more=$(by_lang "$lang" "En savoir plus" "Learn more" "اعرف المزيد")
    expect "« $more » vers chaque page ($lang)" "consulting?lang=$lang|solutions.php?lang=$lang|connect?lang=$lang" \
        "$(sed -n '/<div id="univers">/,/^<\/div>/p' <<< "$home" | grep -oE "href=\"[^\"]+\">$more<" | sed -E 's/href="([^"]+)".*/\1/' | paste -sd '|' -)"
    expect "ni expertises, ni produits, ni livres sur l'accueil ($lang)" "0|0|0" \
        "$(grep -c '<ul class="expertises">' <<< "$home")|$(grep -c '<article id="product-' <<< "$home")|$(grep -c 'class="shelf"' <<< "$home")"
    expect "anciennes ancres vers la page Consulting ($lang)" "consulting|consulting#accompagnement|consulting#accompagnement" \
        "$(grep -oE 'id="(consulting|edition-univers|edition)"[^>]* data-hash-redirect="[^"]+"' <<< "$home" | sed -E "s/.*data-hash-redirect=\"([^?]+)\?lang=$lang([^\"]*)\"/\1\2/" | paste -sd '|' -)"
    nav=$(sed -n '/<nav class="nav-desktop"/,/<\/nav>/p' <<< "$home")
    # Noorwan Connect quitte le menu (20/11/2026) : produit de Solutions, sa page reste dans le pied de page.
    expect "menu : Consulting, Solutions, Contact, chacun sa page ($lang)" "consulting?lang=$lang|solutions.php?lang=$lang|contact.php?lang=$lang" \
        "$(grep -oE 'href="[^"]+"' <<< "$nav" | sed -E 's/href="([^"]+)"/\1/' | paste -sd '|' -)"
    # Volet du menu (charte commune, 24/11/2026) : toutes les rubriques, Accueil et Édition comprises.
    expect "volet du menu : Accueil, Consulting, Solutions, Édition, Contact ($lang)" "./?lang=$lang|consulting?lang=$lang|solutions.php?lang=$lang|edition.php?lang=$lang|contact.php?lang=$lang" \
        "$(sed -n '/<nav id="nav-mobile"/,/<\/nav>/p' <<< "$home" | grep -oE 'href="[^"]+"' | sed -E 's/href="([^"]+)"/\1/' | paste -sd '|' -)"
    footer=$(sed -n '/<nav class="footer-cols"/,/<\/nav>/p' <<< "$home")
    grep -q "href=\"edition.php?lang=$lang#catalogue\"" <<< "$footer" && pass "pied de page : page Édition gardée ($lang)" || fail "pied de page : lien vers la page Édition ($lang)"
    grep -q 'id="contact" class="screen screen-mist cta"' <<< "$home" && pass "bandeau contact en bas de l'accueil ($lang)" || fail "bandeau contact ($lang)"
    expect "accueil : aucun texte à fournir ($lang)" 0 "$(grep -c '<mark class="todo">' <<< "$home")"
    why=$(sed -n '/aria-labelledby="why-title"/,/<\/section>/p' <<< "$home")
    expect "Pourquoi Noorwan : texte et trois points forts, sans chiffre ($lang)" "1|3|0" \
        "$(grep -c '<p class="lead">' <<< "$why")|$(sed -n '/<ul class="why-points">/,/<\/ul>/p' <<< "$why" | grep -c '<li>')|$(sed -n '/<ul class="why-points">/,/<\/ul>/p' <<< "$why" | grep -cE '[0-9]')"
done
grep -q "data-hash-redirect" public/assets/js/site.js && pass "site.js suit data-hash-redirect" || fail "site.js : redirection des anciennes ancres absente"

echo "2 septies. Page Consulting (/consulting)"
grep -q '/consulting?lang=fr</loc>' <<< "$sitemap" && pass "page Consulting dans le plan du site" || fail "page Consulting absente du plan du site"
grep -q '/edition.php?lang=fr</loc>' <<< "$sitemap" && pass "page Édition gardée dans le plan du site" || fail "page Édition absente du plan du site"
grep -q '^    RewriteRule ^consulting$ consulting.php \[L\]$' public/.htaccess && pass ".htaccess : /consulting réécrite vers consulting.php" || fail ".htaccess : réécriture de /consulting absente"
for lang in fr en ar; do
    html=$(curl -s "$BASE_URL/consulting?lang=$lang")
    grep -q "<link rel=\"canonical\" href=\"[^\"]*/consulting?lang=$lang\">" <<< "$html" && pass "adresse canonique /consulting ($lang)" || fail "adresse canonique /consulting ($lang)"
    grep -qF "<h1 id=\"page-title\" class=\"h1 h1-page\">$(by_lang "$lang" "Clarifier avant d&apos;accélérer." "Clarify before you accelerate." "التوضيح قبل التسريع.")</h1>" <<< "$html" && pass "titre ($lang)" || fail "titre de la page Consulting ($lang)"
    # Expertises illustrées (variante 1) : cinq cartes à pictogramme, puis la carte sombre « Clarifier avant d'accélérer. ».
    expertises=$(sed -n '/<ul class="expertises">/,/<\/ul>/p' <<< "$html")
    expect "cinq expertises et une carte sombre ($lang)" "5|1" \
        "$(grep -c '<li class="expertise">' <<< "$expertises")|$(grep -c '<li class="expertise expertise-motto">' <<< "$expertises")"
    expect "un pictogramme par expertise, clair et sombre dans le même <picture>, sans miroir ($lang)" "strategy|marketing|ecommerce|web|training" \
        "$(grep -oE '<source srcset="assets/img/expertises/[a-z]+-dark\.svg" media="\(prefers-color-scheme: dark\)" data-theme-media="dark"><img class="expertise-icon" src="assets/img/expertises/[a-z]+\.svg" alt="" width="64" height="64"' <<< "$expertises" \
            | sed -E 's/.*expertises\/([a-z]+)-dark\.svg.*expertises\/([a-z]+)\.svg.*/\1 \2/' | awk '$1 == $2 { print $1 }' | paste -sd '|' -)"
    motto=$(sed -n '/expertise-motto/,/<\/li>/p' <<< "$expertises")
    expect "carte sombre : titre et ligne d'explication ($lang)" "1|1" \
        "$(grep -cF "<strong>$(by_lang "$lang" "Clarifier avant d&apos;accélérer." "Clarify before you accelerate." "التوضيح قبل التسريع.")</strong>" <<< "$motto")|$(grep -c '<span>' <<< "$motto")"
    expect "plus de note sous les expertises ($lang)" 0 "$(grep -c 'class="universe-note"' <<< "$html")"
    section=$(sed -n '/<section id="accompagnement"/,/<\/section>/p' <<< "$html")
    tag=$(by_lang "$lang" "Accompagnement et édition" "Support and publishing" "المرافقة والنشر")
    grep -q "<p class=\"eyebrow\">$tag</p>" <<< "$section" && pass "« $tag » ($lang)" || fail "petit titre « $tag » ($lang)"
    expect "trilogie : deux couvertures et un tome à paraître ($lang)" "2|1" \
        "$(grep -c '<img class="cover"' <<< "$section")|$(grep -c 'class="cover-soon"' <<< "$section")"
    grep -q "href=\"edition.php?lang=$lang\"" <<< "$section" && pass "lien vers la page Édition ($lang)" || fail "lien vers la page Édition ($lang)"
    grep -q "href=\"contact.php?lang=$lang&amp;universe=edition\"" <<< "$section" && pass "« Publier votre livre » vers le formulaire ($lang)" || fail "lien Publier votre livre ($lang)"
    # v8 : texte de l'accompagnement à l'écriture validé par Marwan, plus rien de surligné.
    expect "accompagnement à l'écriture : texte validé, non surligné ($lang)" "1|0" \
        "$(grep -c "<p class=\"accomp-writing\">$(by_lang "$lang" "Vous avez un livre en tête, ou un manuscrit en cours." "You have a book in mind, or a manuscript under way." "في ذهنك كتاب، أو بين يديك مخطوط قيد الكتابة.")" <<< "$section")|$(grep -c '<mark class="todo">' <<< "$html")"
    grep -q "href=\"contact.php?lang=$lang&amp;universe=consulting\"" <<< "$html" && pass "contact, univers Consulting ($lang)" || fail "lien de contact Consulting ($lang)"
    if sed -n '/<nav class="nav-desktop"/,/<\/nav>/p' <<< "$html" | grep -q 'edition.php'; then fail "Édition encore dans le menu ($lang)"; else pass "Édition hors du menu ($lang)"; fi
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
    grep -q 'href="https://www.amazon.fr/dp/B0F91W6361"' <<< "$html" && pass "Harmonie : lien direct vers sa fiche Amazon ($lang)" || fail "Harmonie : lien Amazon direct absent ($lang)"
    # Depuis le 15/11, un livre sans identifiant Amazon mène à la page auteur : plus rien à fournir sur la page.
    expect "aucun texte à fournir surligné ($lang)" 0 "$(grep -c '<mark class="todo">' <<< "$html")"
done
expect "couverture_belles_manieres.webp servie" 200 "$(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/assets/images/covers/couverture_belles_manieres.webp")"

echo "2 nonies. Solutions : un produit par ligne (Inteek, Reserva, Noorwan Connect, Noor), Inteek une seule fois"
grep -q '/solutions.php?lang=fr</loc>' <<< "$sitemap" && pass "page Solutions dans le plan du site" || fail "page Solutions absente du plan du site"
for lang in fr en ar; do
    home=$(curl -s "$BASE_URL/?lang=$lang")
    nav=$(sed -n '/<nav class="nav-desktop"/,/<\/nav>/p' <<< "$home")
    grep -q "href=\"solutions.php?lang=$lang\">$(by_lang "$lang" "Solutions" "Solutions" "الحلول")<" <<< "$nav" && pass "menu : Solutions mène à solutions.php ($lang)" || fail "menu : lien Solutions ($lang)"
    for page in solutions.php; do
        html=$(curl -s "$BASE_URL/$page?lang=$lang")
        expect "lignes Inteek, Reserva, Noorwan Connect et Noor, deux confidentielles (${page:-index}, $lang)" "inteek|reserva|connect|noor|2" \
            "$(grep -oE '<article id="product-[a-z]+" class="product-row"' <<< "$html" | sed -E 's/<article id="product-([a-z]+)".*/\1/' | paste -sd '|' -)|$(grep -c 'class="badge-confidential"' <<< "$html")"
        grep -q 'id="product-noor"' <<< "$html" && sed -n '/id="product-noor"/,/<\/article>/p' <<< "$html" | grep -q 'badge-confidential' \
            && pass "Noor marqué « Confidentiel » (${page:-index}, $lang)" || fail "Noor sans mention Confidentiel (${page:-index}, $lang)"
        sed -n '/id="product-reserva"/,/<\/article>/p' <<< "$html" | grep -q 'badge-confidential' \
            && pass "Reserva marqué « Confidentiel » (${page:-index}, $lang)" || fail "Reserva sans mention Confidentiel (${page:-index}, $lang)"
        # Noorwan Connect, produit de Solutions (20/11/2026) : même gabarit de ligne, nom en lettres latines, introduction de /connect,
        # catégorie « Numérique » (décision de Marwan, 20/11/2026), « En savoir plus » vers sa page, illustration du haut de sa page.
        card=$(sed -n '/id="product-connect"/,/<\/article>/p' <<< "$html")
        lead=$(by_lang "$lang" "Un compte par personne, avec votre numéro de téléphone." "One account per person, with your phone number." "حساب واحد لكل شخص، برقم هاتفك.")
        expect "carte Noorwan Connect : nom, introduction, catégorie, lien, pas confidentielle (${page:-index}, $lang)" "1|1|1|1|0" \
            "$(grep -c '<h2 id="product-connect-name" class="h2 product-name">Connect</h2>' <<< "$card")|$(grep -cF "<p class=\"product-text\">$lead" <<< "$card")|$(grep -c "<p class=\"eyebrow eyebrow-sol product-cat\">$(by_lang "$lang" "Numérique" "Digital" "رقمي")</p>" <<< "$card")|$(grep -c "<a class=\"more\" href=\"connect?lang=$lang\">$(by_lang "$lang" "En savoir plus" "Learn more" "اعرف المزيد")</a>" <<< "$card")|$(grep -c 'badge-confidential' <<< "$card")"
        grep -qF '<div class="product-row-visual"><picture><source srcset="assets/img/connect-hero-dark.svg" media="(prefers-color-scheme: dark)" data-theme-media="dark"><img src="assets/img/connect-hero.svg" alt=""' <<< "$card" \
            && pass "carte Noorwan Connect : illustration de sa page, sans miroir (${page:-index}, $lang)" || fail "carte Noorwan Connect : illustration (${page:-index}, $lang)"
        expect "Immobilier et Shopping « bientôt » (${page:-index}, $lang)" 2 "$(sed -n '/<div class="soon-row">/,/<\/ul>/p' <<< "$html" | grep -c '<li>')"
    done

    page=$(curl -s "$BASE_URL/solutions.php?lang=$lang")
    grep -q '<!-- TEXTES A VALIDER PAR MARWAN -->' <<< "$page" && pass "page Solutions : textes marqués à valider ($lang)" || fail "page Solutions : commentaire de validation absent ($lang)"
    grep -q "<h1 id=\"page-title\" class=\"h1 h1-page\">$(by_lang "$lang" "Des logiciels pour le travail de chaque jour" "Software for everyday work" "برمجيات للعمل اليومي")</h1>" <<< "$page" \
        && pass "page Solutions : titre ($lang)" || fail "page Solutions : titre ($lang)"
    expect "page Solutions : 3 principes, 5 modules d'Inteek ($lang)" "3|5" \
        "$(sed -n '/<ol class="principles">/,/<\/ol>/p' <<< "$page" | grep -c '<li>')|$(sed -n '/<ul class="modules">/,/<\/ul>/p' <<< "$page" | grep -c '<li>')"
    expect "page Solutions : Inteek une seule fois, dans sa ligne ($lang)" "1|1|1" \
        "$(grep -c '<h2 id="product-inteek-name" class="h2 product-name">Inteek</h2>' <<< "$page")|$(grep -c 'id="product-inteek"' <<< "$page")|$(sed -n '/<main/,/<\/main>/p' <<< "$page" | grep -o '>Inteek<' | wc -l | tr -d ' ')"
    # Inteek garde son contenu détaillé dans sa ligne : catégorie, introduction, texte, modules, sans lien (pas de page à lui).
    row=$(sed -n '/id="product-inteek"/,/<\/article>/p' <<< "$page")
    expect "ligne Inteek : catégorie, introduction, texte, modules, sans lien ($lang)" "1|1|1|5|0" \
        "$(grep -c "<p class=\"eyebrow eyebrow-sol product-cat\">$(by_lang "$lang" "Ressources humaines" "Human resources" "الموارد البشرية")</p>" <<< "$row")|$(grep -c '<p class="product-text">' <<< "$row")|$(grep -c '<p class="inteek-text">' <<< "$row")|$(sed -n '/<ul class="modules">/,/<\/ul>/p' <<< "$row" | grep -c '<li>')|$(grep -c 'class="more"' <<< "$row")"
    grep -q '<p class="eyebrow eyebrow-sol product-cat">eBusiness</p>' <<< "$(sed -n '/id="product-reserva"/,/<\/article>/p' <<< "$page")" && pass "Reserva : catégorie « eBusiness » ($lang)" || fail "Reserva : catégorie ($lang)"
    expect "page Solutions : plus de grille de cartes ($lang)" 0 "$(grep -cE 'class="(products|product|glyph)[ "]' <<< "$page")"
    if grep -qE 'Réservation<|>Booking<|>الحجز<' <<< "$page"; then fail "ancienne catégorie de Reserva ($lang)"; else pass "plus de catégorie « Réservation » ($lang)"; fi
    expect "page Solutions : « Demander une présentation » vers le formulaire, univers Solutions ($lang)" 5 \
        "$(grep -c "href=\"contact.php?lang=$lang&amp;universe=solutions\">$(by_lang "$lang" "Demander une présentation" "Request a presentation" "اطلب عرضًا تقديميًا")" <<< "$page")"
    # Ni prix ni chiffres de clients : aucun montant ni symbole monétaire sur la page.
    if sed -n '/<main/,/<\/main>/p' <<< "$page" | grep -qiE '[0-9] ?(€|\$|FDJ|USD|EUR)|€|prix|price|clients'; then fail "page Solutions : prix ou clients cités ($lang)"; else pass "page Solutions : ni prix ni clients ($lang)"; fi
done
grep -q '<option value="solutions" selected>' <<< "$(curl -s "$BASE_URL/contact.php?lang=fr&universe=solutions")" && pass "formulaire : univers Solutions présélectionné" || fail "formulaire : univers Solutions non présélectionné"

echo "2 decies. Date de mise à jour des pages légales"
for page in mentions-legales.php confidentialite.php cookies.php; do
    for lang in fr en ar; do
        date=$(by_lang "$lang" "Dernière mise à jour : 26 novembre 2026" "Last updated: 26 November 2026" "آخر تحديث: 26 نوفمبر 2026")
        grep -q "<p class=\"legal-updated\">$date</p>" <<< "$(curl -s "$BASE_URL/$page?lang=$lang")" && pass "$page ($lang) : mise à jour du 26/11/2026" || fail "$page ($lang) : date de mise à jour"
    done
done

echo "2 undecies. Aucun lien vers le Compte Noorwan hors de /connect (v5 bis)"
# Rendu hors serveur, constantes fixées avant l'amorçage : les états se testent sans toucher au .env.
# render PAGE LANGUE ACTIVÉ [ADRESSE, « - » pour une adresse vide] [GTM_ID] [CHOIX]
# Lanceur hors de compte.noorwan.com : les pages rendues ne dépendent pas des réglages du .env local et les liens
# vers le Compte comptés ici sont ceux de l'en-tête et des volets, pas la tuile Connect du lanceur.
render() {
    LAUNCHER_CONNECT_URL=https://connect.example.invalid/home LAUNCHER_RESERVA_URL= LAUNCHER_INTEEK_URL= LAUNCHER_ONEPAY_URL= ECOSYSTEM_CONNECT_URL= ECOSYSTEM_RESERVA_URL= ECOSYSTEM_INTEEK_URL= "$PHP" -r '[, $page, $lang, $enabled, $url, $gtm, $consent] = $argv + [4 => "", 5 => "", 6 => ""];
        define("COMPTE_LINK_ENABLED", $enabled === "true");
        if ($url === "-") { define("COMPTE_URL", ""); } elseif ($url !== "") { define("COMPTE_URL", $url); }
        define("GTM_ID", $gtm);
        if ($consent !== "") { $_COOKIE["nw_consent"] = $consent; }
        $_GET["lang"] = $lang;
        require "public/" . $page;' "$@" 2>&1
}
COMPTE_DEFAULT="https://compte.noorwan.com"
for lang in fr en ar; do
    for page in index.php solutions.php edition.php connect.php; do
        html=$(render "$page" "$lang" false)
        expect "désactivé : aucun lien vers le Compte, $page ($lang)" 0 "$(grep -cE 'compte\.noorwan\.com|nav-account|btn-account|connect-create|connect-already' <<< "$html")"
    done
    # Activé : hors de /connect, le Compte n'est lié que par « Continuer avec Noorwan » des deux volets (charte commune).
    for page in index.php solutions.php edition.php contact.php cookies.php; do
        html=$(render "$page" "$lang" true)
        expect "activé : Compte lié seulement dans les deux volets, $page ($lang)" "2|2|0" \
            "$(grep -c 'compte\.noorwan\.com' <<< "$html")|$(grep -c "<a class=\"btn btn-connect btn-block connect-continue\" href=\"$COMPTE_DEFAULT/?lang=$lang\">" <<< "$html")|$(sed -n '/<main/,/<\/main>/p' <<< "$html" | grep -cE 'compte\.noorwan\.com|nav-account|btn-account')"
    done
    if grep -qE "'account' =>" <<< "$(sed -n "/'nav' => \[/,/\],/p" "lang/$lang.php")"; then fail "clé nav.account encore présente ($lang)"; else pass "clé nav.account retirée ($lang)"; fi

    html=$(render solutions.php "$lang" true)
    expect "en-tête : lanceur et « Connexion » vers leurs volets, jamais le Compte ($lang)" "launcher-toggle|account-toggle|1|0" \
        "$(sed -n '/<div class="header-tools">/,/<\/header>/p' <<< "$html" | grep -oE '<a class="[a-z-]+"' | sed -E 's/<a class="([a-z-]+)"/\1/' | paste -sd '|' -)|$(grep -c "<a class=\"account-toggle\" href=\"#connect-panel\" aria-controls=\"connect-panel\" aria-expanded=\"false\" data-panel-open>$(by_lang "$lang" "Connexion" "Sign in" "الدخول")</a>" <<< "$html")|$(sed -n '/<header/,/<\/header>/p' <<< "$html" | grep -c 'compte\.noorwan')"
    expect "volet du menu : ni Connect ni « Mon compte » parmi les rubriques ($lang)" "0|0" \
        "$(sed -n '/<nav id="nav-mobile"/,/<\/nav>/p' <<< "$html" | grep -c 'connect?')|$(sed '/<div id="launcher-panel"/,/^<\/div>/d' <<< "$html" | grep -cE 'Mon compte|My account|«حسابي»')"
    expect "pied de page : colonne Noorwan, Noorwan Connect puis Contact ($lang)" "connect?lang=$lang|contact.php?lang=$lang" \
        "$(sed -n '/<nav class="footer-cols"/,/<\/nav>/p' <<< "$html" | grep -oE 'href="[^"]+"' | tail -n 2 | sed -E 's/href="([^"]+)"/\1/' | paste -sd '|' -)"
    phrase=$(by_lang "$lang" "Un seul compte pour tous les services Noorwan." "One account for all Noorwan services." "حساب واحد لجميع خدمات نوروان.")
    nbsp=$'\xc2\xa0'
    link=$(by_lang "$lang" "Découvrir Connect" "Discover Connect" "اكتشف${nbsp}"$'\xe2\x81\xa6'"Connect"$'\xe2\x81\xa9')
    for state in true false; do
        hero=$(sed -n '/<section class="page-hero/,/<\/section>/p' <<< "$(render solutions.php "$lang" "$state")" | grep 'class="page-connect"')
        grep -qF "<p class=\"page-connect\">$phrase <a href=\"connect?lang=$lang\">$link " <<< "$hero" \
            && pass "page Solutions : phrase vers /connect, lien du Compte $state ($lang)" || fail "page Solutions : phrase vers /connect ($lang, $state) : $hero"
    done
    if grep -q $'—' <<< "$html"; then fail "activé : tiret cadratin dans la page ($lang)"; else pass "activé : aucun tiret cadratin ($lang)"; fi
done
expect "adresse du Compte modifiable sans toucher aux vues (trois liens de /connect, deux des volets)" 5 \
    "$(render connect.php en true https://compte.example.invalid | grep -c 'href="https://compte.example.invalid/?lang=en"')"
# Site servi : quel que soit COMPTE_LINK_ENABLED, aucun lien vers le Compte hors de /connect.
expect "site servi : aucun lien vers le Compte sur la page Solutions (hors lanceur)" 0 \
    "$(curl -s "$BASE_URL/solutions.php?lang=fr" | sed '/<div id="launcher-panel"/,/^<\/div>/d' | grep -cE 'compte\.noorwan\.com|nav-account|btn-account')"
expect "adresse du Compte vide : aucun lien" 0 "$(render connect.php fr true - | grep -cE 'nav-account|btn-account|connect-create')"
grep -q '^COMPTE_LINK_ENABLED=false$' .env.example && pass ".env.example : lien désactivé par défaut" || fail ".env.example : COMPTE_LINK_ENABLED=false absent"

echo "2 duodecies. Choix de cookies commun et Tag Manager (M-59, M-129)"
GTM_TEST="GTM-TEST000"
for lang in fr en ar; do
    for page in index.php contact.php cookies.php; do
        html=$(render "$page" "$lang" false "" "")
        expect "GTM_ID vide : ni Google, ni bandeau, ni volet, ni « Gérer les cookies », $page ($lang)" 0 \
            "$(grep -cE 'googletagmanager|gtm-bootstrap|id="consent"|consent-panel|consent-manage' <<< "$html")"
    done
    html=$(render index.php "$lang" false "" "$GTM_TEST")
    expect "sans cookie : aucun script Tag Manager ($lang)" 0 "$(grep -c 'googletagmanager' <<< "$html")"
    grep -q "<script nonce=\"[A-Za-z0-9+/=]\{24\}\" id=\"gtm-bootstrap\" data-gtm-id=\"$GTM_TEST\">" <<< "$html" && pass "sans cookie : amorçage avec nonce ($lang)" || fail "sans cookie : amorçage absent ($lang)"
    grep -q "gtag('consent', 'default', { ad_storage: 'denied', ad_user_data: 'denied', ad_personalization: 'denied', analytics_storage: 'denied' });" <<< "$html" \
        && pass "sans cookie : mode consentement tout refusé par défaut ($lang)" || fail "sans cookie : consentement par défaut ($lang)"
    expect "sans cookie : aucune mise à jour du consentement ($lang)" 0 "$(grep -c "gtag('consent', 'update'" <<< "$html")"
    banner=$(sed -n '/<section id="consent"/,/<\/section>/p' <<< "$html")
    text=$(by_lang "$lang" "Noorwan utilise des cookies pour mesurer l&apos;audience de ses sites et, si vous l&apos;acceptez, pour la publicité. Votre choix vaut pour tous les sites Noorwan." \
        "Noorwan uses cookies to measure the audience of its sites and, if you accept, for advertising. Your choice applies to all Noorwan sites." \
        "تستخدم نوروان ملفات تعريف الارتباط لقياس جمهور مواقعها، وللإعلانات إن قبلت ذلك. يسري اختيارك على جميع مواقع نوروان.")
    grep -qF "<p class=\"consent-text\">$text <a href=\"confidentialite.php?lang=$lang\">" <<< "$banner" && pass "bandeau : texte commun et lien vers Confidentialité ($lang)" || fail "bandeau : texte commun ($lang)"
    expect "bandeau : « Tout accepter » et « Tout refuser » de même forme, puis « Choisir » vers le volet ($lang)" "all|none|1" \
        "$(grep -oE 'class="btn btn-outline btn-consent" type="submit" name="choice" value="[a-z]+"' <<< "$banner" | sed -E 's/.*value="([a-z]+)"/\1/' | paste -sd '|' -)|$(grep -c "<a class=\"consent-choose\" href=\"#consent-panel\" aria-controls=\"consent-panel\" aria-expanded=\"false\" data-panel-open>$(by_lang "$lang" "Choisir" "Choose" "اختيار")</a>" <<< "$banner")"
    expect "bandeau : textes des boutons ($lang)" 2 "$(grep -cE ">($(by_lang "$lang" "Tout accepter|Tout refuser" "Accept all|Refuse all" "قبول الكل|رفض الكل"))</button>" <<< "$banner")"
    panel=$(sed -n '/<div id="consent-panel"/,/^<\/div>/p' <<< "$html")
    expect "volet « Choisir » : fin de ligne, deux interrupteurs éteints, « Enregistrer » ($lang)" "1|2|0|1|1" \
        "$(grep -c '<div id="consent-panel" class="panel-layer panel-end" data-panel data-analytics="0" data-ads="0">' <<< "$panel")|$(grep -c 'type="checkbox" role="switch"' <<< "$panel")|$(grep -c ' checked>' <<< "$panel")|$(grep -c '<input type="hidden" name="choice" value="custom">' <<< "$panel")|$(grep -c ">$(by_lang "$lang" "Enregistrer" "Save" "حفظ")</button>" <<< "$panel")"
    grep -q "<a href=\"#consent-panel\" aria-controls=\"consent-panel\" aria-expanded=\"false\" data-panel-open>$(by_lang "$lang" "Gérer les cookies" "Manage cookies" "إدارة ملفات تعريف الارتباط")</a>" <<< "$(sed -n '/<div class="footer-legal">/,/<\/div>/p' <<< "$html")" \
        && pass "« Gérer les cookies » au pied de page rouvre le volet ($lang)" || fail "« Gérer les cookies » absent ou mal relié ($lang)"

    html=$(render index.php "$lang" false "" "$GTM_TEST" v1.a1.m0)
    grep -q "j.src = 'https://www.googletagmanager.com/gtm.js?id=' + i;" <<< "$html" && grep -q "'dataLayer', '$GTM_TEST');" <<< "$html" \
        && pass "a1 : Tag Manager chargé ($lang)" || fail "a1 : Tag Manager absent ($lang)"
    grep -q "gtag('consent', 'update', { analytics_storage: 'granted', ad_storage: 'denied', ad_user_data: 'denied', ad_personalization: 'denied' });" <<< "$html" \
        && pass "a1.m0 : mesure accordée, publicité refusée ($lang)" || fail "a1.m0 : mise à jour du consentement ($lang)"
    expect "a1 : tout script en ligne porte le nonce, un seul nonce ($lang)" "0|1" \
        "$(grep -E '<script( |>)' <<< "$html" | grep -v ' src=' | grep -vc 'nonce=')|$(grep -oE 'nonce="[^"]+"' <<< "$html" | sort -u | wc -l | tr -d ' ')"
    expect "a1 : bandeau absent, volet réglé sur le choix ($lang)" "0|1|1" \
        "$(grep -c '<section id="consent"' <<< "$html")|$(grep -c 'data-analytics="1" data-ads="0"' <<< "$html")|$(grep -c 'name="analytics" value="1" checked>' <<< "$html")"
    html=$(render index.php "$lang" false "" "$GTM_TEST" v1.a1.m1)
    grep -q "gtag('consent', 'update', { analytics_storage: 'granted', ad_storage: 'granted', ad_user_data: 'granted', ad_personalization: 'granted' });" <<< "$html" \
        && pass "a1.m1 : mesure et publicité accordées ($lang)" || fail "a1.m1 : publicité non accordée ($lang)"
    for value in v1.a0.m0 v1.a0.m1; do
        html=$(render index.php "$lang" false "" "$GTM_TEST" "$value")
        expect "$value : aucun Tag Manager, aucune mise à jour, bandeau fermé ($lang)" "0|0|0" \
            "$(grep -c 'googletagmanager' <<< "$html")|$(grep -c "gtag('consent', 'update'" <<< "$html")|$(grep -c '<section id="consent"' <<< "$html")"
    done
    html=$(render index.php "$lang" false "" "$GTM_TEST" v2.a1.m1)
    expect "valeur inconnue : comme sans cookie ($lang)" "0|1" "$(grep -c 'googletagmanager' <<< "$html")|$(grep -c '<section id="consent"' <<< "$html")"
    html=$(render index.php "$lang" false "" "$GTM_TEST" granted)
    expect "ancienne valeur « granted » reprise : mesure seule ($lang)" "1|1|0" \
        "$(grep -c "ad_storage: 'denied', ad_user_data: 'denied', ad_personalization: 'denied' });" <<< "$html")|$(grep -c "gtm.js?id=' + i;" <<< "$html")|$(grep -c '<section id="consent"' <<< "$html")"
    html=$(render index.php "$lang" false "" "$GTM_TEST" denied)
    expect "ancienne valeur « denied » reprise : rien ($lang)" "0|0" "$(grep -c 'googletagmanager' <<< "$html")|$(grep -c '<section id="consent"' <<< "$html")"
    html=$(render cookies.php "$lang" false "" "$GTM_TEST" v1.a1.m0)
    manage=$(sed -n '/<section id="consent-manage"/,/<\/section>/p' <<< "$html")
    expect "page Cookies : choix actuel et bouton vers le volet ($lang)" "1|1|1" \
        "$(grep -c "$(by_lang "$lang" "Mesure d&apos;audience : acceptée" "Audience measurement: accepted" "قياس الجمهور: تم القبول")" <<< "$manage")|$(grep -c "$(by_lang "$lang" "Publicité : refusée" "Advertising: refused" "الإعلانات: تم الرفض")" <<< "$manage")|$(grep -c 'class="btn btn-outline consent-manage-open" href="#consent-panel"' <<< "$manage")"
done
expect "identifiant mal formé ignoré" 0 "$(GTM_ID='GTM-x"><script>' "$PHP" -r '$_GET["lang"]="fr"; require "public/index.php";' 2>&1 | grep -c 'gtm-bootstrap')"
grep -q '^GTM_ID=$' .env.example && pass ".env.example : GTM_ID vide par défaut" || fail ".env.example : GTM_ID absent ou rempli"
# Cookie commun : les deux cookies reçus sous le même nom (ancien de l'hôte, commun de .noorwan.com), la valeur commune l'emporte.
expect "deux cookies nw_consent reçus : la valeur commune l'emporte" "v1.a0.m1" \
    "$("$PHP" -r '$_SERVER["HTTP_COOKIE"] = "nw_consent=granted; nw_consent=v1.a0.m1"; require "app/bootstrap.php"; $c = consent_choice(); echo "v1.a" . (int) $c["analytics"] . ".m" . (int) $c["ads"];' 2>&1)"
options() { "$PHP" -r '[, $host, $https] = $argv; $_SERVER["HTTP_HOST"] = $host; if ($https === "on") { $_SERVER["HTTPS"] = "on"; } require "app/bootstrap.php"; $o = consent_cookie_options(); echo ($o["domain"] ?? "-") . "|" . ($o["expires"] - time()) . "|" . $o["path"] . "|" . $o["samesite"] . "|" . var_export($o["secure"], true) . "|" . var_export($o["httponly"], true);' "$@" 2>&1; }
expect "noorwan.com en https : domaine commun, six mois, Secure, jamais HttpOnly" ".noorwan.com|15552000|/|Lax|true|false" "$(options noorwan.com on)"
expect "sous-domaine (dev.noorwan.com:443) : domaine commun" ".noorwan.com|15552000|/|Lax|true|false" "$(options dev.noorwan.com:443 on)"
expect "autre hôte (127.0.0.1) : hôte seul" "-|15552000|/|Lax|false|false" "$(options 127.0.0.1:8010 off)"
expect "faux sous-domaine (evilnoorwan.com) : hôte seul" "-" "$(options evilnoorwan.com on | cut -d'|' -f1)"

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
expect "jeton absent refusé" 400 "$(curl -s -o /dev/null -w '%{http_code}' -X POST -d 'choice=all' "$BASE_URL/consent.php")"
expect "choix inconnu refusé" 400 "$(curl -s -o /dev/null -w '%{http_code}' -X POST --data-urlencode "token=$(consent_token)" -d 'choice=granted' "$BASE_URL/consent.php")"
response=$(curl -s -D - -o /dev/null -X POST --data-urlencode "token=$(consent_token)" -d 'choice=all' --data-urlencode 'back=edition.php?lang=ar' "$BASE_URL/consent.php?lang=ar")
grep -q '^HTTP/[0-9.]* 303' <<< "$response" && pass "Tout accepter : redirection 303" || fail "Tout accepter : $(head -n 1 <<< "$response")"
grep -qi '^Location: edition.php?lang=ar' <<< "$response" && pass "Tout accepter : retour à la page d'origine" || fail "Tout accepter : mauvais retour"
cookie=$(grep -i '^Set-Cookie: nw_consent=' <<< "$response")
grep -q 'nw_consent=v1.a1.m1;' <<< "$cookie" && grep -q 'Max-Age=15552000' <<< "$cookie" && grep -qi 'SameSite=Lax' <<< "$cookie" && grep -q 'path=/' <<< "$cookie" \
    && pass "Tout accepter : nw_consent=v1.a1.m1, six mois, SameSite=Lax, Path=/" || fail "Tout accepter : cookie $cookie"
if grep -qi 'HttpOnly' <<< "$cookie"; then fail "cookie commun en HttpOnly"; else pass "cookie commun jamais HttpOnly"; fi
if grep -qi 'domain=' <<< "$cookie"; then fail "hôte local : domaine posé ($cookie)"; else pass "hôte local : cookie sur l'hôte seul"; fi
expect "un seul cookie posé" 1 "$(grep -ci '^Set-Cookie:' <<< "$response")"
response=$(curl -s -D - -o /dev/null -X POST --data-urlencode "token=$(consent_token)" -d 'choice=all' --data-urlencode 'back=https://exemple.invalid/' "$BASE_URL/consent.php")
grep -qi '^Location: ./?lang=fr' <<< "$response" && pass "retour vers un site externe refusé" || fail "retour externe : $(grep -i '^Location' <<< "$response")"
response=$(curl -s -D - -o /dev/null -X POST -H 'Accept: application/json' -H 'Cookie: _ga=GA1.1.1; _ga_ABC123=GS1.1' --data-urlencode "token=$(consent_token)" -d 'choice=none' "$BASE_URL/consent.php")
grep -q '^HTTP/[0-9.]* 204' <<< "$response" && pass "Tout refuser en arrière-plan : réponse 204" || fail "Tout refuser en arrière-plan : $(head -n 1 <<< "$response")"
grep -q 'nw_consent=v1.a0.m0;' <<< "$response" && pass "Tout refuser : nw_consent=v1.a0.m0" || fail "Tout refuser : cookie absent"
expect "Tout refuser : cookies Google Analytics effacés" 2 "$(grep -ciE '^Set-Cookie: _ga(_ABC123)?=deleted' <<< "$response")"
for case in "analytics=1|v1.a1.m0" "ads=1|v1.a0.m1" "analytics=1&ads=1|v1.a1.m1" "x=1|v1.a0.m0"; do
    response=$(curl -s -D - -o /dev/null -X POST -H 'Accept: application/json' --data-urlencode "token=$(consent_token)" -d "choice=custom&${case%%|*}" "$BASE_URL/consent.php")
    grep -q "nw_consent=${case##*|};" <<< "$response" && pass "Choisir (${case%%|*}) : nw_consent=${case##*|}" || fail "Choisir (${case%%|*}) : $(grep -i '^Set-Cookie: nw_consent' <<< "$response")"
done
response=$(curl -s -D - -o /dev/null -X POST -H 'Host: www.noorwan.com' -H 'Accept: application/json' --data-urlencode "token=$(consent_token)" -d 'choice=all' "$BASE_URL/consent.php")
expect "www.noorwan.com : ancien cookie de l'hôte effacé, puis cookie commun sur .noorwan.com" "1|1" \
    "$(grep -ciE '^Set-Cookie: nw_consent=deleted;.*path=/' <<< "$(grep -vi 'domain=' <<< "$response")")|$(grep -ciE '^Set-Cookie: nw_consent=v1\.a1\.m1;.*domain=\.noorwan\.com' <<< "$response")"
expect "jeton signé : choix forgé refusé" 400 "$(curl -s -o /dev/null -w '%{http_code}' -X POST -d 'token=1.2.3&choice=all' "$BASE_URL/consent.php")"
# Ancienne valeur du site : recopiée dans la valeur commune à la première page vue (« granted » : la mesure seule).
response=$(curl -s -D - -o /dev/null -H 'Cookie: nw_consent=granted' "$BASE_URL/?lang=fr")
grep -q 'Set-Cookie: nw_consent=v1.a1.m0;' <<< "$response" && pass "ancien « granted » recopié en v1.a1.m0" || fail "ancien « granted » : $(grep -i '^Set-Cookie' <<< "$response")"
response=$(curl -s -D - -o /dev/null -H 'Cookie: nw_consent=denied' "$BASE_URL/?lang=fr")
grep -q 'Set-Cookie: nw_consent=v1.a0.m0;' <<< "$response" && pass "ancien « denied » recopié en v1.a0.m0" || fail "ancien « denied » : $(grep -i '^Set-Cookie' <<< "$response")"
response=$(curl -s -D - -o /dev/null -H 'Host: noorwan.com' -H 'Cookie: nw_consent=granted' "$BASE_URL/?lang=fr")
expect "noorwan.com : ancien cookie de l'hôte effacé et recopié sur .noorwan.com" "1|1" \
    "$(grep -vi 'domain=' <<< "$response" | grep -ci '^Set-Cookie: nw_consent=deleted')|$(grep -ciE '^Set-Cookie: nw_consent=v1\.a1\.m0;.*domain=\.noorwan\.com' <<< "$response")"
expect "valeur commune déjà là : rien n'est recopié" 0 "$(curl -s -D - -o /dev/null -H 'Cookie: nw_consent=v1.a0.m0' "$BASE_URL/?lang=fr" | grep -ci '^Set-Cookie: nw_consent')"
expect "sans cookie : aucun cookie posé" 0 "$(curl -s -D - -o /dev/null "$BASE_URL/?lang=fr" | grep -ci '^Set-Cookie: nw_consent')"

echo "2 quindecies. Lanceur des sites (M-121)"
# launch [VARIABLE=valeur ...] : accueil en français rendu hors serveur, lanceur et anciennes adresses vides (adresses par défaut).
launch() { env LAUNCHER_CONNECT_URL= LAUNCHER_RESERVA_URL= LAUNCHER_INTEEK_URL= LAUNCHER_ONEPAY_URL= ECOSYSTEM_CONNECT_URL= ECOSYSTEM_RESERVA_URL= ECOSYSTEM_INTEEK_URL= "$@" "$PHP" -r '$_GET["lang"] = "fr"; require "public/index.php";' 2>&1; }
launcher_panel() { sed -n '/<div id="launcher-panel"/,/^<\/div>/p'; }
launcher_sites() { grep -oE 'data-launcher-site="[a-z]+"' | sed -E 's/.*="([a-z]+)"/\1/' | paste -sd '|' -; }
html=$(launch)
expect "aucune adresse dans .env : tous les sites (OnePay après Inteek) aux adresses par défaut, Noorwan marqué, avec « Mon compte Connect »" "noorwan|connect|reserva|inteek|onepay|1|1|1|1" \
    "$(launcher_panel <<< "$html" | launcher_sites)|$(grep -c '<a class="launcher-tile" href="./?lang=fr" data-launcher-site="noorwan" aria-current="page">' <<< "$html")|$(launcher_panel <<< "$html" | grep -c 'aria-current')|$(grep -c 'launcher-account' <<< "$html")|$(launcher_panel <<< "$html" | grep -c 'href="https://dev.reserva.noorwan.com" data-launcher-site')"
html=$(launch LAUNCHER_CONNECT_URL=https://compte.example.invalid/home LAUNCHER_RESERVA_URL=https://reserva.example.invalid LAUNCHER_INTEEK_URL=https://inteek.example.invalid)
panel=$(launcher_panel <<< "$html")
expect "liste publique dans l'ordre : Noorwan, Connect, Reserva, Inteek, OnePay (M-123)" "noorwan|connect|reserva|inteek|onepay" "$(launcher_sites <<< "$panel")"
expect "adresses de .env, noms, pastilles (couleur et lettre)" "https://compte.example.invalid/home|https://reserva.example.invalid|https://inteek.example.invalid|https://dev.onepay.noorwan.com|5|5" \
    "$(grep -oE 'href="https://[^"]+" data-launcher-site' <<< "$panel" | sed -E 's/href="([^"]+)".*/\1/' | paste -sd '|' -)|$(grep -cE '<bdi>(Noorwan|Connect|Reserva|Inteek|OnePay)</bdi>' <<< "$panel")|$(grep -cE '<circle cx="24" cy="24" r="23" fill="#(0071E3|248A3D|0F6F66|A85A00|5B34C7)"/><text [^>]*>(n|c|r|i|o)</text>' <<< "$panel")"
expect "« Mon compte Connect » en bas, vers l'accueil du compte" 1 \
    "$(grep -c '<a class="launcher-account" href="https://compte.example.invalid/home" rel="noopener">Mon compte Connect</a>' <<< "$panel")"
expect "volet du lanceur : fin de ligne, voile, titre, croix" "1|1|1|1" \
    "$(grep -c '<div id="launcher-panel" class="panel-layer panel-end panel-launcher" data-panel>' <<< "$html")|$(grep -c '<a class="panel-scrim" href="#" tabindex="-1" aria-hidden="true" data-panel-close></a>' <<< "$panel")|$(grep -c '<h2 id="launcher-panel-title" class="panel-title">Sites Noorwan</h2>' <<< "$panel")|$(grep -c 'class="panel-close" href="#" data-panel-close' <<< "$panel")"
expect "anciennes adresses ECOSYSTEM_*_URL lues en repli" 1 \
    "$(launch ECOSYSTEM_RESERVA_URL=https://reserva.example.invalid | launcher_panel | grep -c 'https://reserva.example.invalid')"
expect "LAUNCHER_*_URL l'emporte sur l'ancienne adresse" 1 \
    "$(launch LAUNCHER_RESERVA_URL=https://neuf.example.invalid ECOSYSTEM_RESERVA_URL=https://ancien.example.invalid | launcher_panel | grep -c 'https://neuf.example.invalid')"
panel=$(launch 'LAUNCHER_RESERVA_URL=javascript:alert(1)' LAUNCHER_INTEEK_URL=http://inteek.example.invalid | launcher_panel)
expect "adresse non https : adresse par défaut, aucun site masqué (M-124)" "noorwan|connect|reserva|inteek|onepay|1|1|0" \
    "$(launcher_sites <<< "$panel")|$(grep -c 'href="https://dev.reserva.noorwan.com" data-launcher-site' <<< "$panel")|$(grep -c 'href="https://dev.inteek.noorwan.com" data-launcher-site' <<< "$panel")|$(grep -cE 'javascript:|http://inteek' <<< "$panel")"
expect "Compte en service : l'adresse du lanceur n'est jamais déduite de COMPTE_URL" 0 \
    "$(launch COMPTE_LINK_ENABLED=true COMPTE_URL=https://autre-compte.example.invalid | launcher_panel | grep -c 'autre-compte.example.invalid')"
expect "OnePay (M-123) : après Inteek, adresse par défaut, pastille violette et lettre « o »" "1|1" \
    "$(launcher_panel <<< "$html" | grep -c 'href="https://dev.onepay.noorwan.com" data-launcher-site="onepay" rel="noopener"')|$(launcher_panel <<< "$html" | grep -c '<circle cx="24" cy="24" r="23" fill="#5B34C7"/><text [^>]*>o</text>')"
expect "OnePay : LAUNCHER_ONEPAY_URL l'emporte, une adresse non https prend l'adresse par défaut" "1|1" \
    "$(launch LAUNCHER_ONEPAY_URL=https://onepay.example.invalid | launcher_panel | grep -c 'https://onepay.example.invalid')|$(launch LAUNCHER_ONEPAY_URL=http://onepay.example.invalid | launcher_panel | grep -c 'href="https://dev.onepay.noorwan.com" data-launcher-site="onepay"')"
# Icônes des sites (M-124) : copies de la charte commune servies par le site sous images/sites/, jamais sous /icons/
# (réservé par Apache sur Ubuntu) ; pastille couleur et lettre gardée pour le cas où l'icône ne se charge pas.
panel=$(launch | launcher_panel)
expect "icônes : une par site, sous images/sites/, versionnées, sans texte de remplacement, chacune avec sa pastille de secours" "5|5|5" \
    "$(grep -cE '<span class="launcher-icon" data-launcher-icon><img class="launcher-img" src="images/sites/(noorwan|connect|reserva|inteek|onepay)\.svg\?v=[0-9]+" alt="" width="48" height="48" decoding="async"><svg class="launcher-dot"' <<< "$panel")|$(for k in noorwan connect reserva inteek onepay; do [[ -s "public/images/sites/$k.svg" ]] && echo "$k"; done | wc -l | tr -d ' ')|$(grep -c 'class="launcher-dot"' <<< "$panel")"
[[ ! -e public/icons ]] && pass "aucun dossier public/icons (réservé par Apache)" || fail "dossier public/icons présent"
expect "icône de Connect au point vert #30D158, pastille de Connect #248A3D" "1|1" \
    "$(grep -c '#30D158' public/images/sites/connect.svg)|$(grep -c '<circle cx="24" cy="24" r="23" fill="#248A3D"/><text [^>]*>c</text>' <<< "$panel")"
expect "icône de noorwan.com identique au favicon du site" 0 "$(cmp -s public/favicon.svg public/images/sites/noorwan.svg; echo $?)"
expect "icônes servies par le site" "200|200" "$(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/images/sites/connect.svg")|$(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/images/sites/onepay.svg")"
expect "site.js montre la pastille quand une icône ne se charge pas" "1|1" \
    "$(grep -c "holder.classList.add('is-failed');" public/assets/js/site.js)|$(grep -c 'images\[i\].complete && images\[i\].naturalWidth === 0' public/assets/js/site.js)"
expect "feuille : pastille cachée tant que l'icône s'affiche, montrée en cas d'échec" "1|1" \
    "$(grep -c '^\.launcher-icon\.is-failed \.launcher-img {$' public/assets/css/site.css)|$(grep -c '^\.launcher-icon\.is-failed \.launcher-dot {$' public/assets/css/site.css)"
# En-tête (M-124) : le groupe de fin reste en bout de ligne même sans liens principaux (le logo pousse par sa marge).
expect "en-tête : le logo pousse le groupe de fin en bout de ligne" 1 "$(sed -n '/^\.header-bar \.logo {$/,/^}$/p' public/assets/css/site.css | grep -c 'margin-inline: 4px auto;')"
if grep -qi 'onepay' <<< "$(launch | without_launcher)"; then fail "OnePay hors du lanceur"; else pass "OnePay absent hors du lanceur"; fi
expect "plus aucune ligne « Écosystème Noorwan » (pied de page, volet du menu, réglages, textes)" "0|0|0|0" \
    "$(grep -cE 'class="(ecosystem|panel-ecosystem)"|Écosystème Noorwan|Noorwan ecosystem|منظومة Noorwan' <<< "$html")|$(grep -c 'ecosystem' app/layout/header.php app/layout/footer.php public/assets/css/site.css | awk -F: '{ n += $2 } END { print n }')|$(grep -c '^ECOSYSTEM_' .env.example)|$(grep -c "'ecosystem' =>" lang/fr.php lang/en.php lang/ar.php | awk -F: '{ n += $2 } END { print n }')"
[[ ! -e app/layout/ecosystem.php ]] && pass "gabarit ecosystem.php retiré" || fail "gabarit ecosystem.php encore présent"
for lang in fr en ar; do
    html=$(curl -s "$BASE_URL/?lang=$lang")
    expect "lanceur traduit : bouton, titre, nom du site courant ($lang)" "1|1|1" \
        "$(grep -c "<a class=\"launcher-toggle\" href=\"#launcher-panel\" aria-controls=\"launcher-panel\" aria-expanded=\"false\" aria-label=\"$(by_lang "$lang" "Sites Noorwan" "Noorwan sites" "مواقع Noorwan")\"" <<< "$html")|$(grep -c "class=\"panel-title\">$(by_lang "$lang" "Sites Noorwan" "Noorwan sites" "مواقع Noorwan")</h2>" <<< "$html")|$(grep -c "href=\"./?lang=$lang\" data-launcher-site=\"noorwan\" aria-current=\"page\"" <<< "$html")"
done
expect "« Mon compte Connect » traduit (en, ar)" "My Connect account|حسابي في Connect" \
    "$(grep -oE "'account' => '[^']+'" <<< "$(sed -n "/'launcher' => \[/,/\],/p" lang/en.php lang/ar.php)" | sed -E "s/.*'([^']+)'$/\1/" | paste -sd '|' -)"
# Grille de trois par ligne, panneau dès 640 px (fin de ligne), propriétés logiques seulement.
launcher_css=$(sed -n '/Lanceur des sites (M-121)/,/En-tête à 390 px : avec le lanceur/p' public/assets/css/site.css)
expect "feuille : trois tuiles par ligne, panneau dès 640 px, voile transparent" "1|1|1" \
    "$(grep -c 'grid-template-columns: repeat(3, minmax(0, 1fr));' <<< "$launcher_css")|$(grep -c '@media (min-width: 640px)' <<< "$launcher_css")|$(grep -c 'background: transparent;' <<< "$launcher_css")"
expect "feuille : panneau de 328 px aligné sur le bouton, sans croix dès 640 px (comme Connect)" "1|1|1" \
    "$(grep -c 'width: 328px;' <<< "$launcher_css")|$(grep -c 'inset-inline-end: var(--launcher-end, 8px);' <<< "$launcher_css")|$(grep -A1 '\.panel-launcher \.panel-close {' <<< "$launcher_css" | grep -c 'display: none;')"
expect "site.js aligne le panneau sur le bouton « grille »" 1 "$(grep -c "panel.style.setProperty('--launcher-end'" public/assets/js/site.js)"
logo_css=$(sed -n '/^\.logo {$/,/^}$/p' public/assets/css/site.css)
expect "mot-symbole de l'en-tête : 20 px, graisse 600" "1|1" "$(grep -c 'font-size: 20px;' <<< "$logo_css")|$(grep -c 'font-weight: 600;' <<< "$logo_css")"
expect "bouton du thème : lune en clair, soleil en sombre" 1 "$(grep -c '^\.theme-toggle\[data-shown="dark"\] \.theme-icon-moon,$' public/assets/css/site.css)"
if grep -qE '(^|[^-])(left|right)\s*:|margin-(left|right)|padding-(left|right)|border-(left|right)' <<< "$launcher_css"; then fail "lanceur : propriété physique (left, right)"; else pass "lanceur : propriétés logiques seulement"; fi

echo "2 sexdecies. OnePay absent de toutes les pages, hors grille du lanceur (M-123)"
for page in "" consulting solutions.php edition.php connect contact.php mentions-legales.php confidentialite.php cookies.php; do
    for lang in fr en ar; do
        if curl -s "$BASE_URL/$page?lang=$lang" | without_launcher | grep -qi 'onepay'; then fail "OnePay présent : /${page:-index} ($lang)"; else pass "OnePay absent : /${page:-index} ($lang)"; fi
    done
done
for lang in fr en ar; do
    if render index.php "$lang" true "" "$GTM_TEST" granted | without_launcher | grep -qi 'onepay' || render connect.php "$lang" true | without_launcher | grep -qi 'onepay'; then fail "OnePay présent, tout activé ($lang)"; else pass "OnePay absent, tout activé ($lang)"; fi
done

echo "2 septdecies. Page Noorwan Connect (/connect)"
grep -q '/connect?lang=fr</loc>' <<< "$sitemap" && pass "page Noorwan Connect dans le plan du site" || fail "page Noorwan Connect absente du plan du site"
expect "connect.php reste servi" 200 "$(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/connect.php?lang=fr")"
grep -q '^    RewriteRule ^connect$ connect.php \[L\]$' public/.htaccess && pass ".htaccess : /connect réécrite vers connect.php" || fail ".htaccess : réécriture de /connect absente"
for lang in fr en ar; do
    html=$(curl -s "$BASE_URL/connect?lang=$lang")
    nav=$(sed -n '/<nav class="nav-desktop"/,/<\/nav>/p' <<< "$html")
    expect "menu : plus de Noorwan Connect, aucun onglet actif sur sa page ($lang)" "0|0" \
        "$(grep -c 'href="connect?' <<< "$nav")|$(grep -c 'aria-current="page"' <<< "$nav")"
    grep -q "<link rel=\"canonical\" href=\"[^\"]*/connect?lang=$lang\">" <<< "$html" && pass "adresse canonique /connect ($lang)" || fail "adresse canonique ($lang)"
    title=$(by_lang "$lang" "Un seul compte pour tous les services Noorwan" "One account for all Noorwan services" "حساب واحد لجميع خدمات نوروان")
    grep -qF "<h1 id=\"page-title\" class=\"h1 h1-page\">$title</h1>" <<< "$html" && pass "titre ($lang)" || fail "titre de la page Noorwan Connect ($lang)"
    expect "sections particuliers, professionnels, sans mot de passe, données, partenaires ($lang)" "particuliers|professionnels|sans-mot-de-passe|donnees|partenaires" \
        "$(grep -oE '<section id="[a-z-]+" class="screen[^"]*connect-section' <<< "$html" | sed -E 's/<section id="([a-z-]+)".*/\1/' | paste -sd '|' -)"
    expect "trois points par section, quatre sections ($lang)" 12 "$(grep -c '<span class="connect-num" aria-hidden="true">0' <<< "$html")"
    expect "six illustrations décoratives ($lang)" 6 "$(grep -cE '<img class="illus" src="assets/img/connect-(hero|personal|pro|code|data|partner)\.svg" alt=""' <<< "$html")"
    soon=$(by_lang "$lang" "Bientôt" "Coming soon" "قريبًا")
    grep -q "<p class=\"badge-soon\">$soon</p>" <<< "$html" && pass "partenaires : « $soon » ($lang)" || fail "partenaires : pastille « $soon » ($lang)"
    if sed -n '/id="partenaires"/,/<\/section>/p' <<< "$html" | grep -qE '20[0-9]{2}|janvier|trimestre|quarter|month|mois'; then fail "partenaires : date promise ($lang)"; else pass "partenaires : aucune date ($lang)"; fi
    grep -q "href=\"contact.php?lang=$lang&amp;universe=solutions\">" <<< "$(sed -n '/id="partenaires"/,/<\/section>/p' <<< "$html")" && pass "partenaires : lien vers le formulaire ($lang)" || fail "partenaires : lien vers le formulaire ($lang)"
    if sed -n '/<main/,/<\/main>/p' <<< "$html" | grep -qiE 'reserva|onepay|\+253|[0-9]{2} [0-9]{2} [0-9]{2}'; then fail "aucun produit confidentiel ni numéro réel ($lang)"; else pass "aucun produit confidentiel ni numéro réel ($lang)"; fi

    create=$(by_lang "$lang" "Créer mon compte" "Create my account" "إنشاء حسابي")
    href="$COMPTE_DEFAULT/?lang=$lang"
    html=$(render connect.php "$lang" true)
    expect "activé : « $create » en haut et en bas, vers le Compte ($lang)" 2 "$(grep -c "<a class=\"btn btn-blue connect-create\" href=\"$href\">$create " <<< "$html")"
    already=$(by_lang "$lang" "J&apos;ai déjà un compte" "I already have an account" "لديّ حساب بالفعل")
    grep -qF "<p class=\"connect-already\"><a href=\"$href\">$already</a></p>" <<< "$html" && pass "activé : « $already » vers le Compte ($lang)" || fail "activé : lien « $already » ($lang)"
    nbsp=$'\xc2\xa0'
    dest=$(by_lang "$lang" "votre compte Connect" "your Connect account" "حسابك على")
    expect "textes : « $dest » deux fois, plus de « Mon compte » ($lang)" "2|0" \
        "$(sed -n '/id="donnees"/,/<\/section>/p' <<< "$html" | grep -o "$dest" | wc -l | tr -d ' ')|$(sed '/<div id="launcher-panel"/,/^<\/div>/d' <<< "$html" | grep -cE 'Mon compte|My account|«حسابي»')"
    grep -q 'id="creer"' <<< "$html" && pass "activé : bandeau final ($lang)" || fail "activé : bandeau final absent ($lang)"
    final=$(by_lang "$lang" "Créez votre compte Connect" "Create your Connect account" "أنشئ حسابك على Connect")
    grep -qF "<h2 id=\"creer-title\" class=\"h2 h2-section\">$final</h2>" <<< "$html" && pass "bandeau final : « $final » ($lang)" || fail "bandeau final : titre ($lang)"
    html=$(render connect.php "$lang" false)
    expect "désactivé : ni bouton ni bandeau final, page complète ($lang)" "0|0|5" \
        "$(grep -c 'connect-create' <<< "$html")|$(grep -c 'id="creer"' <<< "$html")|$(grep -c 'connect-section' <<< "$html")"
    footer=$(sed -n '/<nav class="footer-cols"/,/<\/nav>/p' <<< "$html")
    grep -q "href=\"connect?lang=$lang\">Connect<" <<< "$footer" && pass "pied de page : Connect ($lang)" || fail "pied de page : lien Noorwan Connect ($lang)"
done
grep -q '\[dir="rtl"\] \.connect-visual \.illus' public/assets/css/site.css && pass "illustrations de Noorwan Connect sans miroir (coches)" || fail "règle sans miroir des illustrations de Noorwan Connect"

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

echo "2 nonies ter. Illustrations dessinées (SVG)"
# Produits (v3), haut de page, univers, étapes de la méthode et contact (v4) : moins de 20 Ko, sans texte.
for base in reserva inteek noor hero universe-consulting universe-solutions universe-edition step-field step-build step-improve connect-hero connect-personal connect-pro connect-code connect-data connect-partner; do
  for id in "$base" "$base-dark"; do
    file="public/assets/img/$id.svg"
    expect "$id.svg servi" 200 "$(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/assets/img/$id.svg")"
    size=$(wc -c < "$file" | tr -d ' ')
    [[ $size -lt 20480 ]] && pass "$id.svg léger ($size octets)" || fail "$id.svg trop lourd ($size octets)"
    expect "$id.svg sans texte ni image externe ni script" 0 "$(grep -ciE '<text|<image|href=|<script' "$file")"
  done
done
for lang in fr en ar; do
    home=$(curl -s "$BASE_URL/?lang=$lang")
    expect "accueil : sept illustrations décoratives ($lang)" 7 "$(grep -cE '<img class="illus" src="assets/img/(hero|universe-(consulting|solutions)|connect-hero|step-(field|build|improve))\.svg" alt=""' <<< "$home")"
    expect "méthode : trois étapes ($lang)" 3 "$(sed -n '/id="methode"/,/<\/section>/p' <<< "$home" | grep -c '<span class="method-num"')"
    # Photo de contact (v7) : bandeau de l'accueil (chargée à la demande), texte alternatif traduit.
    # Depuis le 21/11/2026, la page Contact la porte en fond de son en-tête (contrôlé avec les photos d'en-tête).
    alt=$(by_lang "$lang" "Trois personnes en réunion" "Three people in a meeting" "ثلاثة أشخاص في اجتماع")
    photo='<img class="photo" src="assets/img/contact-reunion-600.webp" srcset="assets/img/contact-reunion-600.webp 600w, assets/img/contact-reunion-1200.webp 1200w"'
    expect "bandeau de contact : photo avec texte alternatif ($lang)" 1 "$(grep -F "$photo" <<< "$home" | grep -F 'loading="lazy"' | grep -c "alt=\"$alt")"
    if grep -q 'contact\.svg' <<< "$home"; then fail "ancienne illustration de contact encore sur l'accueil ($lang)"; else pass "ancienne illustration de contact retirée ($lang)"; fi
done
# Pictogrammes des expertises (variante 1) : couleurs du Consulting, version sombre aux couleurs de la planche, jamais en miroir.
for id in strategy marketing ecommerce web training; do
    for variant in "$id" "$id-dark"; do
        file="public/assets/img/expertises/$variant.svg"
        expect "expertises/$variant.svg servi" 200 "$(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/assets/img/expertises/$variant.svg")"
        expect "expertises/$variant.svg sans texte ni image externe ni script" 0 "$(grep -ciE '<text|<image|href=|<script' "$file")"
    done
    expect "expertises/$id.svg : trait, accent et pastille du Consulting" "1|1|1" \
        "$(grep -c '#A8915F' "public/assets/img/expertises/$id.svg")|$(grep -c '#6F5B2E' "public/assets/img/expertises/$id.svg")|$(grep -c 'fill="#F3EEE3"' "public/assets/img/expertises/$id.svg")"
    expect "expertises/$id-dark.svg : trait, accent et pastille sombres" "1|1|1|0" \
        "$(grep -c '#CDB98A' "public/assets/img/expertises/$id-dark.svg")|$(grep -c '#E6D3A3' "public/assets/img/expertises/$id-dark.svg")|$(grep -c 'fill="#2A2A2C"' "public/assets/img/expertises/$id-dark.svg")|$(grep -ciE '#(A8915F|6F5B2E|F3EEE3)' "public/assets/img/expertises/$id-dark.svg")"
done
# Lignes des produits (disposition A) : une colonne au téléphone, deux dès 834 px, illustration côté fin une ligne sur deux,
# par l'ordre de la grille (aucun left ni right : juste en arabe sans feuille séparée).
rows834=$(sed -n '/^@media (min-width: 834px) {$/,/^}$/p' public/assets/css/site.css)
grep -q '^    \.product-row:nth-child(even) \.product-row-visual {$' <<< "$rows834" && grep -q '^        grid-template-columns: repeat(2, minmax(0, 1fr));$' <<< "$(sed -n '/^    \.product-row {$/,/^    }$/p' <<< "$rows834")" \
    && pass "lignes des produits : deux colonnes dès 834 px, illustration en alternance" || fail "alternance des lignes des produits"
expect "lignes des produits : propriétés logiques seulement" 0 "$(sed -n '/Produits de Solutions : une ligne par produit/,/^\.badge-confidential {$/p' public/assets/css/site.css | grep -cE '(margin|padding|border)-(left|right)|[^-](left|right):|text-align: (left|right)')"
if grep -qE '\.(products|product|glyph|product-dark|product-light|inteek-visual)( |,|\{|:)' public/assets/css/site.css; then fail "anciens styles de la grille des produits encore présents"; else pass "anciens styles de la grille des produits retirés"; fi
if grep -qE '\[dir="rtl"\][^{]*\.expertise-icon' public/assets/css/site.css; then fail "pictogrammes des expertises retournés en arabe"; else pass "pictogrammes des expertises sans miroir en arabe"; fi
grep -q '\[dir="rtl"\] \.illus' public/assets/css/site.css && pass "illustrations en miroir en arabe" || fail "miroir des illustrations en arabe absent"
for width in 600 1200; do
    file="public/assets/img/contact-reunion-$width.webp"
    expect "photo de contact $width px servie" 200 "$(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/assets/img/contact-reunion-$width.webp")"
    size=$(wc -c < "$file" | tr -d ' ')
    [[ $size -lt 61440 ]] && pass "photo de contact $width px légère ($size octets)" || fail "photo de contact $width px trop lourde ($size octets)"
done
if grep -qE '\[dir="rtl"\] [^{]*\.photo' public/assets/css/site.css; then fail "photo en miroir en arabe"; else pass "photo jamais en miroir"; fi

echo "Photos d'en-tête des trois univers (20/11/2026)"
# Emplacements prêts : <page>-hero-780.webp et -1440.webp dans assets/img, titre en HTML par-dessus.
# Tant qu'une image manque, la page garde son rendu ; Consulting garde son illustration.
hero_render() { "$PHP" -r '[, $dir, $page, $lang] = $argv; if ($dir !== "") { define("HERO_PHOTO_DIR", $dir); } $_GET["lang"] = $lang; require "public/" . $page;' "$@" 2>&1; }
for univ in consulting solutions edition; do
    page=$([[ $univ == consulting ]] && echo consulting.php || echo "$univ.php")
    if [[ -f "public/assets/img/$univ-hero-780.webp" && -f "public/assets/img/$univ-hero-1440.webp" ]]; then
        expect "$univ : photo d'en-tête déposée et affichée" 1 "$(hero_render "" "$page" fr | grep -c 'class="hero-photo"')"
        for width in 780 1440; do
            size=$(wc -c < "public/assets/img/$univ-hero-$width.webp" | tr -d ' ')
            [[ $size -lt 307200 ]] && pass "$univ-hero-$width.webp léger ($size octets)" || fail "$univ-hero-$width.webp trop lourd ($size octets)"
            expect "$univ-hero-$width.webp : largeur $width px" "$width" "$("$PHP" -r 'echo getimagesize($argv[1])[0];' "public/assets/img/$univ-hero-$width.webp")"
        done
    else
        for lang in fr en ar; do
            html=$(curl -s "$BASE_URL/$([[ $univ == consulting ]] && echo consulting || echo "$page")?lang=$lang")
            expect "$univ sans photo : en-tête inchangé ($lang)" "0|0|$([[ $univ == consulting ]] && echo 1 || echo 0)" \
                "$(grep -c 'has-photo' <<< "$html")|$(grep -c 'class="hero-photo"' <<< "$html")|$(sed -n '/<section class="page-hero/,/<\/section>/p' <<< "$html" | grep -c 'class="shape"')"
        done
    fi
done
if "$PHP" -r 'exit(function_exists("imagewebp") ? 0 : 1);'; then
    HERO_DIR=$(mktemp -d)
    # Images d'essai sans texte, aux deux largeurs (non versionnées).
    "$PHP" -r 'foreach ([780 => 488, 1440 => 900] as $w => $h) { $i = imagecreatetruecolor($w, $h); imagefilledrectangle($i, 0, 0, $w, $h, imagecolorallocate($i, 60, 70, 90));
        foreach (["consulting", "solutions", "edition"] as $n) { imagewebp($i, $argv[1] . "/$n-hero-$w.webp", 70); } }' "$HERO_DIR"
    for univ in consulting solutions edition; do
        page=$([[ $univ == consulting ]] && echo consulting.php || echo "$univ.php")
        for lang in fr en ar; do
            hero=$(hero_render "$HERO_DIR" "$page" "$lang" | sed -n '/<section class="page-hero/,/<\/section>/p')
            img="<div class=\"hero-photo\"><img src=\"assets/img/$univ-hero-780.webp\" srcset=\"assets/img/$univ-hero-780.webp 780w, assets/img/$univ-hero-1440.webp 1440w\" sizes=\"100vw\" alt=\""
            expect "$univ avec photo : classe, image deux largeurs, alt, dimensions, titre en HTML après l'image ($lang)" "1|1|1|1" \
                "$(grep -c 'class="page-hero has-photo' <<< "$hero")|$(grep -cF "$img" <<< "$hero")|$(grep -c 'width="1440" height="900" fetchpriority="high" decoding="async"></div>' <<< "$hero")|$(sed -n '/class="hero-photo"/,$p' <<< "$hero" | grep -c '<h1 id="page-title"')"
            [[ $univ == consulting ]] && expect "consulting avec photo : plus d'illustration en tête ($lang)" 0 "$(grep -c 'class="shape"' <<< "$hero")"
        done
    done
    rm -f "$HERO_DIR/solutions-hero-1440.webp"
    expect "une seule largeur déposée : pas de photo" 0 "$(hero_render "$HERO_DIR" solutions.php fr | grep -c 'hero-photo')"
    rm -rf "$HERO_DIR"
else
    pass "GD sans WebP : contrôle avec images d'essai ignoré"
fi
# Page Contact (21/11/2026) : en-tête en photo comme Consulting, à partir de la photo de réunion (1200 px au plus :
# grande largeur 1200, jamais d'agrandissement). La photo n'est plus dans le corps de l'en-tête (pas deux fois la même).
for width in 780 1200; do
    file="public/assets/img/contact-hero-$width.webp"
    expect "contact-hero-$width.webp servi" 200 "$(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/assets/img/contact-hero-$width.webp")"
    size=$(wc -c < "$file" | tr -d ' ')
    [[ $size -lt 307200 ]] && pass "contact-hero-$width.webp léger ($size octets)" || fail "contact-hero-$width.webp trop lourd ($size octets)"
    expect "contact-hero-$width.webp : largeur $width px, hauteur de l'original (800 px), sans agrandissement" "$width|800" \
        "$("$PHP" -r '$s = getimagesize($argv[1]); echo $s[0] . "|" . $s[1];' "$file")"
done
for lang in fr en ar; do
    html=$(curl -s "$BASE_URL/contact.php?lang=$lang")
    hero=$(sed -n '/<section class="page-hero/,/<\/section>/p' <<< "$html")
    alt=$(by_lang "$lang" "Trois personnes en réunion" "Three people in a meeting" "ثلاثة أشخاص في اجتماع")
    img='<div class="hero-photo"><img src="assets/img/contact-hero-780.webp" srcset="assets/img/contact-hero-780.webp 780w, assets/img/contact-hero-1200.webp 1200w" sizes="100vw" alt="'
    expect "page Contact : en-tête en photo, deux largeurs, alt, dimensions, titre en HTML après l'image ($lang)" "1|1|1|1" \
        "$(grep -c '<section class="page-hero has-photo"' <<< "$hero")|$(grep -F "$img" <<< "$hero" | grep -c "alt=\"$alt")|$(grep -c 'width="1200" height="800" fetchpriority="high" decoding="async"></div>' <<< "$hero")|$(sed -n '/class="hero-photo"/,$p' <<< "$hero" | grep -c '<h1 id="page-title"')"
    expect "page Contact : plus de photo dans le corps de l'en-tête ni ailleurs sur la page ($lang)" "0|0" \
        "$(grep -c 'class="cta-visual"' <<< "$html")|$(grep -c 'contact-reunion-' <<< "$html")"
    expect "page Contact : adresse sous l'introduction ($lang)" 1 "$(grep -c '<p class="cta-mail"><a href="mailto:' <<< "$hero")"
done
grep -q '^\.page-hero\.has-photo \.cta-mail a {$' public/assets/css/site.css && pass "page Contact : adresse en blanc sur la photo" || fail "couleur de l'adresse sur la photo de Contact"
grep -q '^\.hero-photo img {$' public/assets/css/site.css && pass "photo d'en-tête en object-fit, voile par-dessus" || fail "styles de la photo d'en-tête absents"
if grep -qE '\[dir="rtl"\][^{]*\.hero-photo' public/assets/css/site.css; then fail "photo d'en-tête en miroir en arabe"; else pass "photo d'en-tête jamais en miroir"; fi

echo "Onglet actif et titre de « Pourquoi Noorwan » (v7)"
for lang in fr en ar; do
    for tab in consulting solutions contact; do
        html=$(curl -s "$BASE_URL/$(case "$tab" in consulting|connect) echo "$tab" ;; *) echo "$tab.php" ;; esac)?lang=$lang")
        for menu in '<nav class="nav-desktop"' '<nav id="nav-mobile"'; do
            nav=$(sed -n "/$menu/,/<\/nav>/p" <<< "$html")
            expect "onglet actif unique sur $tab ($lang, $([[ $menu == *mobile* ]] && echo téléphone || echo ordinateur))" 1 "$(grep -c 'aria-current="page"' <<< "$nav")"
            grep 'aria-current="page"' <<< "$nav" | grep -qE "href=\"(\./)?$tab(\.php)?\?" && pass "onglet actif : $tab ($lang)" || fail "onglet actif attendu : $tab ($lang)"
        done
    done
    home=$(curl -s "$BASE_URL/?lang=$lang")
    expect "accueil : aucun onglet actif dans la barre, « Accueil » actif dans le volet ($lang)" "0|1" \
        "$(sed -n '/<nav class="nav-desktop"/,/<\/nav>/p' <<< "$home" | grep -c 'aria-current="page"')|$(sed -n '/<nav id="nav-mobile"/,/<\/nav>/p' <<< "$home" | grep -c "href=\"./?lang=$lang\" aria-current=\"page\"")"
    expect "titre « Une même exigence, quel que soit le projet » ($lang)" 1 "$(grep -c "id=\"why-title\" class=\"h2\">$(by_lang "$lang" "Une même exigence, quel que soit le projet" "One standard, whatever the project" "معيار واحد، أيًّا كان المشروع")<" <<< "$home")"
    for page in "" consulting; do
        if curl -s "$BASE_URL/$page?lang=$lang" | grep -qiE 'trois (métiers|univers)|three (trades|areas|worlds)|ثلاث مهن|ثلاثة مجالات'; then fail "« trois métiers » ou « trois univers » encore sur /$page ($lang)"; else pass "ni « trois métiers » ni « trois univers » sur /$page ($lang)"; fi
    done
done
grep -q '\.nav-desktop a\[aria-current="page"\]' public/assets/css/site.css && grep -q '\.nav-mobile a\[aria-current="page"\]' public/assets/css/site.css && pass "onglet actif mis en avant (ordinateur et téléphone)" || fail "style de l'onglet actif absent"
for lang in fr en ar; do
    html=$(curl -s "$BASE_URL/solutions.php?lang=$lang")
    expect "Solutions : une illustration par ligne, Inteek seule en miroir en arabe ($lang)" "2|1|1|4" \
        "$(grep -cE '<div class="product-row-visual"><picture><source srcset="assets/img/(reserva|noor)-dark\.svg" media="\(prefers-color-scheme: dark\)" data-theme-media="dark"><img src="assets/img/(reserva|noor)\.svg" alt=""' <<< "$html")|$(grep -c '<div class="product-row-visual mirror-rtl"><picture><source srcset="assets/img/inteek-dark.svg" media="(prefers-color-scheme: dark)" data-theme-media="dark"><img src="assets/img/inteek.svg" alt=""' <<< "$html")|$(grep -c 'mirror-rtl' <<< "$html")|$(grep -c 'class="product-row-visual' <<< "$html")"
done

echo "« Nos savoir-faire », phrases retirées, titre de contact avant la photo sur téléphone (v8)"
# Textes « À FOURNIR » dans les chaînes du site (20/11/2026) : textes alternatifs des photos d'en-tête, dans chaque langue.
# Consulting a sa photo depuis le 20/11/2026 ; le texte alternatif de Solutions est écrit le 21/11/2026, avant l'image :
# reste Édition (3 langues).
# La catégorie de Noorwan Connect est fournie (« Numérique », 20/11/2026) : la clé solutions.connect_cat disparaît.
expect "« À FOURNIR » dans lang/ : plus de catégorie de Noorwan Connect à fournir" 0 "$(cat lang/*.php | grep -c 'connect_cat\|catégorie de Noorwan Connect')"
expect "« À FOURNIR » dans lang/ : texte alternatif de la photo d'en-tête restante (Édition)" 3 "$(cat lang/*.php | grep -c "'hero_alt' => '\[À FOURNIR : description de la photo d.*en-tête de la page Édition\]'")"
expect "« À FOURNIR » dans lang/ : rien d'autre" 3 "$(cat lang/*.php | grep -c 'À FOURNIR')"
for lang in fr en ar; do
    expect "texte alternatif de la photo d'en-tête de Solutions écrit ($lang)" 1 \
        "$(grep -cF "'hero_alt' => '$(by_lang "$lang" "Illustration : deux personnes assemblent des écrans d\\'application et des modules reliés entre eux." "Illustration: two people assemble app screens and connected modules." "رسم توضيحي: شخصان يجمّعان شاشات تطبيقات ووحدات مترابطة.")'," "lang/$lang.php")"
done
for lang in fr en ar; do
    home=$(curl -s "$BASE_URL/?lang=$lang")
    why=$(sed -n '/aria-labelledby="why-title"/,/<\/section>/p' <<< "$home")
    expect "point 2 de « Pourquoi Noorwan » : « Nos savoir-faire » ($lang)" 1 \
        "$(grep -c "<li><strong>$(by_lang "$lang" "Nos savoir-faire" "What we do best" "خبراتنا")</strong>" <<< "$why")"
    removed=$(by_lang "$lang" 'Nous conseillons les entreprises|relie le conseil|se nourrissent|notre méthode pour' \
        'We advise businesses|brings together consulting|feed each other|This is our method' \
        'نقدّم الاستشارات للمؤسسات|تجمع الاستشارات والبرمجيات|تتغذى الاستشارات|هذا منهجنا')
    expect "accueil : plus de phrase qui nomme conseil, logiciel et édition ($lang)" 0 "$(grep -cE "$removed" <<< "$home")"
    expect "méthode : plus de paragraphe d'introduction ($lang)" 0 "$(sed -n '/id="methode"/,/<\/section>/p' <<< "$home" | grep -c '<p class="lead">')"
    # Ordre du document = ordre sur téléphone : titre, puis photo.
    expect "bandeau de contact : titre puis photo ($lang)" "cta-title|cta-visual" \
        "$(sed -n '/class="screen screen-mist cta"/,/<\/section>/p' <<< "$home" | grep -oE 'id="cta-title"|class="cta-visual"' | sed -E 's/(id|class)="([^"]+)"/\2/' | paste -sd '|' -)"
done
sed -n '/@media (min-width: 768px) {/,/^}/p' public/assets/css/site.css | grep -A3 '\.wrap-photo > \.cta-visual' | grep -q 'order: -1' \
    && pass "à partir de 768 px, la photo repasse au-dessus du titre" || fail "ordre de la photo sur grand écran"

echo "2 nonies bis. Reserva confidentiel : aucune description sur le site"
for page in "" consulting solutions.php edition.php connect contact.php; do
    for lang in fr en ar; do
        if curl -s "$BASE_URL/$page?lang=$lang" | grep -qE 'prise de rendez-vous|reservation booking|حجز المواعيد'; then fail "description de Reserva présente : /${page:-index} ($lang)"; else pass "aucune description de Reserva : /${page:-index} ($lang)"; fi
    done
done
if grep -rnE 'prise de rendez-vous|reservation booking|حجز المواعيد' lang >/dev/null; then fail "description de Reserva dans lang/"; else pass "aucune description de Reserva dans lang/"; fi

echo "3 quater. Fond blanc cassé (v6)"
grep -qE '^    --page: #F6F5F1;$' public/assets/css/site.css && grep -qE '^    background: var\(--page\);$' public/assets/css/site.css \
    && pass "fond de page blanc cassé (--page)" || fail "fond de page : --page absent"
# Contraste AA (4,5:1) des textes gris et des liens sur le fond de page et sur les sections grises.
contrast=$("$PHP" -r '$css = file_get_contents("public/assets/css/site.css");
    $v = fn ($n) => preg_match("/--$n: #([0-9A-F]{6});/i", $css, $m) ? $m[1] : "000000";
    $l = function ($h) { $c = array_map(fn ($x) => ($x /= 255) <= 0.03928 ? $x / 12.92 : (($x + 0.055) / 1.055) ** 2.4, array_map("hexdec", str_split($h, 2))); return 0.2126 * $c[0] + 0.7152 * $c[1] + 0.0722 * $c[2]; };
    $min = 99; foreach (["text", "muted", "link"] as $fg) { foreach (["page", "mist"] as $bg) { $a = $l($v($fg)); $b = $l($v($bg)); $min = min($min, (max($a, $b) + 0.05) / (min($a, $b) + 0.05)); } }
    echo $min >= 4.5 ? "AA" : sprintf("%.2f", $min);')
expect "contraste AA des textes gris et des liens" AA "$contrast"

echo "Thème sombre (v9)"
# Bouton du thème sur toutes les pages : rond dans la barre, sur toutes les largeurs (charte commune), libellés traduits.
for page in "" consulting solutions.php edition.php connect contact.php mentions-legales.php confidentialite.php cookies.php; do
    for lang in fr en ar; do
        html=$(curl -s "$BASE_URL/$page?lang=$lang")
        to_dark=$(by_lang "$lang" "Passer en sombre" "Switch to dark" "التبديل إلى الوضع الداكن")
        to_light=$(by_lang "$lang" "Passer en clair" "Switch to light" "التبديل إلى الوضع الفاتح")
        expect "bouton du thème dans la barre, un seul, libellés traduits (/${page:-index}, $lang)" "1|1" \
            "$(sed -n '/<div class="header-tools">/,/<\/header>/p' <<< "$html" | grep -c '<button class="theme-toggle theme-toggle-bar" type="button" hidden')|$(grep -cF "data-label-dark=\"$to_dark\" data-label-light=\"$to_light\"" <<< "$html")"
        head=$(sed -n '/<head>/,/<\/head>/p' <<< "$html")
        expect "theme-init.js dans <head>, sans defer, avant la feuille de style (/${page:-index}, $lang)" "theme-init|site.css" \
            "$(grep -oE '<script src="assets/js/theme-init\.js\?v=[0-9]+"></script>|<link rel="stylesheet" href="assets/css/site\.css' <<< "$head" | sed -E 's/.*(theme-init|site\.css).*/\1/' | paste -sd '|' -)"
        expect "theme-color clair et sombre, color-scheme (/${page:-index}, $lang)" "1|1|1" \
            "$(grep -c '<meta name="theme-color" content="#F6F5F1" media="(prefers-color-scheme: light)" data-theme-media="light">' <<< "$head")|$(grep -c '<meta name="theme-color" content="#000000" media="(prefers-color-scheme: dark)" data-theme-media="dark">' <<< "$head")|$(grep -c '<meta name="color-scheme" content="light dark">' <<< "$head")"
        # Chaque illustration de la page a sa version sombre, juste avant elle, dans le même <picture>.
        svg=$(grep -oE '<img [^>]*src="assets/img/[a-z-]+\.svg"' <<< "$html" | wc -l | tr -d ' ')
        paired=$(grep -oE '<source srcset="assets/img/[a-z-]+-dark\.svg" media="\(prefers-color-scheme: dark\)" data-theme-media="dark"><img [^>]*src="assets/img/[a-z-]+\.svg"' <<< "$html" \
            | sed -E 's/.*srcset="assets\/img\/([a-z-]+)-dark\.svg".*src="assets\/img\/([a-z-]+)\.svg"/\1 \2/' | awk '$1 == $2' | wc -l | tr -d ' ')
        expect "illustrations avec leur version sombre (/${page:-index}, $lang)" "$svg" "$paired"
    done
done
for file in public/assets/img/*.svg; do
    [[ "$file" == *-dark.svg ]] && continue
    dark="${file%.svg}-dark.svg"
    [[ -f "$dark" ]] && pass "version sombre de $(basename "$file")" || fail "version sombre absente : $(basename "$dark")"
done
"$PHP" bin/illustrations-dark.php --check >/dev/null 2>&1 && pass "versions sombres à jour (bin/illustrations-dark.php)" || fail "versions sombres à régénérer : php bin/illustrations-dark.php"
expect "noir du dessin éclairci dans les versions sombres (hors dessins pour fond noir)" 0 \
    "$(grep -li '#1D1D1F' public/assets/img/*-dark.svg | grep -vcE '/(connect-code|noor)-dark\.svg$')"
expect "theme-init.js servi" 200 "$(curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/assets/js/theme-init.js")"
# Thème du visiteur (socle du lanceur L6) : cookie nw_theme de six mois, jamais localStorage seul (ancien choix repris
# une fois puis effacé) ; la page Cookies en a sa section, texte à fournir.
expect "theme-init.js : cookie nw_theme de six mois, ancien localStorage repris puis effacé" "1|1|1|0|0" \
    "$(grep -c "var COOKIE = 'nw_theme';" public/assets/js/theme-init.js)|$(grep -c 'var MAX_AGE = 182 \* 86400;' public/assets/js/theme-init.js)|$(grep -c 'localStorage.removeItem(LEGACY_KEY)' public/assets/js/theme-init.js)|$(grep -c 'localStorage.setItem' public/assets/js/theme-init.js)|$(grep -c "addEventListener('storage'" public/assets/js/theme-init.js)"
for lang in fr en ar; do
    expect "page Cookies : section nw_theme ($lang)" 1 "$(curl -s "$BASE_URL/cookies.php?lang=$lang" | grep -c '<h2>nw_theme</h2>')"
done
# Les deux blocs de couleurs sombres (choix manuel, appareil sombre) sont identiques.
css_block() { sed -n "/^$1/,/^ *}/p" public/assets/css/site.css | sed -e '1d' -e '$d' -e 's/^ *//'; }
dark_manual=$(css_block ':root\[data-theme="dark"\] {')
dark_device=$(css_block '    :root:not(\[data-theme="light"\]) {')
[[ -n "$dark_manual" && "$dark_manual" == "$dark_device" ]] && pass "couleurs sombres : choix manuel et appareil identiques ($(wc -l <<< "$dark_manual" | tr -d ' ') réglages)" || fail "couleurs sombres : blocs différents"
grep -q '^@media (prefers-color-scheme: dark) {$' public/assets/css/site.css && pass "couleurs sombres sous @media (prefers-color-scheme: dark)" || fail "@media (prefers-color-scheme: dark) absent"
for name in page mist paper line line-2 ink text muted link; do
    grep -q "^--$name: #" <<< "$dark_manual" && pass "couleur sombre --$name" || fail "couleur sombre --$name absente"
done
expect "point du logotype en #2997FF dans le thème sombre" 1 "$(grep -c '^--logo-dot: var(--link-dark);$' <<< "$dark_manual")"
expect "aucune couleur de texte blanc fixée sur --paper (blanc sur bleu : --white)" 0 "$(grep -c 'color: var(--paper)' public/assets/css/site.css)"
# Contraste AA (4,5:1) en sombre : textes gris et liens sur page, brume, papier ; textes des univers sur leur fond ; erreur et réussite.
contrast_dark=$(DARK="$dark_manual" "$PHP" -r '$css = getenv("DARK");
    $v = fn ($n) => preg_match("/^--$n: #([0-9A-F]{6});/mi", $css, $m) ? $m[1] : "FFFFFF";
    $l = function ($h) { $c = array_map(fn ($x) => ($x /= 255) <= 0.03928 ? $x / 12.92 : (($x + 0.055) / 1.055) ** 2.4, array_map("hexdec", str_split($h, 2))); return 0.2126 * $c[0] + 0.7152 * $c[1] + 0.0722 * $c[2]; };
    $r = fn ($a, $b) => (max($l($v($a)), $l($v($b))) + 0.05) / (min($l($v($a)), $l($v($b))) + 0.05);
    $pairs = [["cons-text", "cons-tint"], ["sol-text", "sol-tint"], ["ed-text", "ed-tint"], ["error", "error-tint"], ["success", "success-tint"], ["error", "paper"], ["success", "paper"]];
    foreach (["ink", "text", "muted", "link"] as $fg) { foreach (["page", "mist", "paper"] as $bg) { $pairs[] = [$fg, $bg]; } }
    $bad = []; foreach ($pairs as [$a, $b]) { if ($r($a, $b) < 4.5) { $bad[] = "$a/$b " . round($r($a, $b), 2); } }
    echo $bad === [] ? "AA" : implode(", ", $bad);')
expect "contraste AA du thème sombre" AA "$contrast_dark"

echo "4. Textes interdits"
files=(app bin lang public database CLAUDE.md)
if grep -rn $'—' "${files[@]}" >/dev/null 2>&1; then
    fail "tiret cadratin présent :"; grep -rn $'—' "${files[@]}"
else
    pass "aucun tiret cadratin"
fi
# CLAUDE.md énonce la règle « jamais djiboutien » : il est exclu de cette recherche.
for word in djiboutien PromptEspace "Labo Tech" CEREBRO OnePay googleapis gstatic; do
    # OnePay (M-123) : seules les lignes du lanceur des sites le nomment.
    hits=$(grep -rni "$word" app bin lang public database 2>/dev/null || true)
    if [ "$word" = OnePay ]; then hits=$(grep -vE "launcher|^lang/(fr|en|ar)\.php:[0-9]+:\s*'onepay' => 'OnePay',$" <<< "$hits" || true); fi
    if [ -n "$hits" ]; then
        fail "« $word » présent :"; printf '%s\n' "$hits"
    else
        pass "aucune occurrence de « $word »"
    fi
done

echo "5. Charte commune (M-116, M-118, M-120)"
# Rendu hors serveur avec tous les réglages : Compte en service, Tag Manager, trois autres sites dans le lanceur.
full() {
    LAUNCHER_CONNECT_URL=https://connect.example.invalid LAUNCHER_RESERVA_URL=https://reserva.example.invalid LAUNCHER_INTEEK_URL=https://inteek.example.invalid LAUNCHER_ONEPAY_URL=https://onepay.example.invalid \
        "$PHP" -r '[, $page, $lang] = $argv; define("COMPTE_LINK_ENABLED", true); define("GTM_ID", "GTM-TEST000");
        $_GET["lang"] = $lang; require "public/" . $page;' "$@" 2>&1
}
for page in index.php consulting.php solutions.php edition.php connect.php contact.php mentions-legales.php confidentialite.php cookies.php; do
    for lang in fr en ar; do
        html=$(curl -s "$BASE_URL/${page/consulting.php/consulting}?lang=$lang")
        header=$(sed -n '/<header class="site-header">/,/<\/header>/p' <<< "$html")
        # En-tête fixe : Menu, logo, liens, langue, thème, lanceur des sites, Connexion, dans cet ordre.
        expect "en-tête : Menu, logo, liens, langue, thème, lanceur, Connexion (${page%.php}, $lang)" "menu-toggle|logo|nav-desktop|lang-menu|theme-toggle|launcher-toggle|account-toggle" \
            "$(grep -oE 'class="(menu-toggle|logo|nav-desktop|lang-menu|theme-toggle theme-toggle-bar|launcher-toggle|account-toggle)"' <<< "$header" | sed -E 's/class="([a-z-]+).*/\1/' | paste -sd '|' -)"
        # Trois volets : menu en début de ligne, lanceur et connexion en fin de ligne, chacun avec voile et croix.
        expect "volets : menu au début, lanceur et connexion à la fin, voile et croix (${page%.php}, $lang)" "1|1|1|3|3|3" \
            "$(grep -c '<div id="menu-panel" class="panel-layer panel-start" data-panel>' <<< "$html")|$(grep -c '<div id="launcher-panel" class="panel-layer panel-end panel-launcher" data-panel>' <<< "$html")|$(grep -c '<div id="connect-panel" class="panel-layer panel-end" data-panel>' <<< "$html")|$(grep -c '<a class="panel-scrim" href="#" tabindex="-1" aria-hidden="true" data-panel-close></a>' <<< "$html")|$(grep -c "<a class=\"panel-close\" href=\"#\" data-panel-close><span class=\"visually-hidden\">$(by_lang "$lang" "Fermer" "Close" "إغلاق")</span>" <<< "$html")|$(grep -c 'role="dialog" aria-modal="true"' <<< "$html")"
        footer=$(sed -n '/<footer class="site-footer">/,/<\/footer>/p' <<< "$html")
        expect "pied de page : logo et phrase, quatre colonnes, ligne légale (${page%.php}, $lang)" "1|1|4|1|1" \
            "$(grep -c '<div class="footer-brand">' <<< "$footer")|$(grep -c "<p class=\"footer-tagline\">$(by_lang "$lang" "Des idées pour des solutions concrètes." "Ideas for concrete solutions." "أفكار من أجل حلول ملموسة.")</p>" <<< "$footer")|$(grep -c '<p class="footer-h">' <<< "$(sed -n '/<nav class="footer-cols"/,/<\/nav>/p' <<< "$footer")")|$(grep -c "<p class=\"footer-copy\" dir=\"ltr\">© $(date +%Y) Noorwan SARL</p>" <<< "$footer")|$(grep -c "href=\"confidentialite.php?lang=$lang\"" <<< "$footer")"
        rendered=$(full "$page" "$lang")
        if grep -qE 'Noorwan( |&nbsp;|'$'\xc2\xa0'')Connect|Compte Noorwan|Noorwan Account|Continuer avec Noorwan Connect' <<< "$(sed -e 's/<[^>]*>//g' <<< "$rendered")"; then
            fail "texte « Noorwan Connect » ou « Compte Noorwan » affiché (${page%.php}, $lang)"
        else
            pass "aucun « Noorwan Connect » ni « Compte Noorwan » affiché (${page%.php}, $lang)"
        fi
        if grep -qi 'onepay' <<< "$(without_launcher <<< "$rendered")"; then fail "OnePay présent, tout activé (${page%.php}, $lang)"; else pass "OnePay absent, tout activé (${page%.php}, $lang)"; fi
    done
done
for lang in fr en ar; do
    html=$(full solutions.php "$lang")
    # Lanceur : les quatre sites, noorwan.com marqué ; plus aucune ligne écosystème au pied de page ni dans le menu.
    expect "lanceur : cinq sites dont OnePay, le site courant marqué, aucune ligne écosystème, OnePay seulement dans la grille ($lang)" "noorwan|connect|reserva|inteek|onepay|1|0|0" \
        "$(launcher_panel <<< "$html" | launcher_sites)|$(launcher_panel <<< "$html" | grep -c 'aria-current="page"')|$(grep -cE 'class="(ecosystem|panel-ecosystem)"' <<< "$html")|$(without_launcher <<< "$html" | grep -ci 'onepay')"
    # Volet de connexion : Connect, présentation de /connect, « Continuer avec Noorwan » en bleu, « En savoir plus ».
    panel=$(sed -n '/<div id="connect-panel"/,/<\/section>/p' <<< "$html")
    expect "volet de connexion : titre, logotype Connect, bouton, lien vers /connect ($lang)" "1|1|1|1" \
        "$(grep -c "<h2 id=\"connect-panel-title\" class=\"panel-title\">$(by_lang "$lang" "Connexion" "Sign in" "الدخول")</h2>" <<< "$panel")|$(grep -c '<p class="connect-lockup" dir="ltr" lang="en">noorwan<span class="logo-dot">.</span><span class="connect-lockup-name">Connect</span></p>' <<< "$panel")|$(grep -c ">$(by_lang "$lang" "Continuer avec Noorwan" "Continue with Noorwan" "المتابعة باستخدام Noorwan")</a>" <<< "$panel")|$(grep -c "<a class=\"more\" href=\"connect?lang=$lang\">" <<< "$panel")"
    # Menu des langues : trois langues, la langue active cochée.
    expect "menu des langues : trois langues, une seule cochée ($lang)" "3|1" \
        "$(sed -n '/<ul class="lang-list"/,/<\/ul>/p' <<< "$html" | grep -c '<li>')|$(sed -n '/<ul class="lang-list"/,/<\/ul>/p' <<< "$html" | grep -c 'aria-current="true"')"
    # « Gérer les cookies » dans la ligne légale, vers le volet du choix commun.
    grep -q "<a href=\"#consent-panel\" aria-controls=\"consent-panel\" aria-expanded=\"false\" data-panel-open>" <<< "$(sed -n '/<div class="footer-legal">/,/<\/div>/p' <<< "$html")" \
        && pass "« Gérer les cookies » dans la ligne légale ($lang)" || fail "« Gérer les cookies » absent de la ligne légale ($lang)"
done
html=$(render solutions.php fr false)
expect "Compte hors service : volet sans bouton, lien vers /connect gardé" "0|1" \
    "$(grep -c 'connect-continue' <<< "$html")|$(sed -n '/<div id="connect-panel"/,/<\/section>/p' <<< "$html" | grep -c '<a class="more" href="connect?lang=fr">')"
# Feuille et script : volets en propriétés logiques, ouverture par l'ancre sans script, Échap, retour arrière, voile.
panel_css=$(sed -n '/Volets (M-118)/,/Volet de connexion : logotype/p' public/assets/css/site.css)
if grep -qE '(^|[^-])(left|right)\s*:|margin-(left|right)|padding-(left|right)|border-(left|right)' <<< "$panel_css"; then fail "volets : propriété physique (left, right)"; else pass "volets : propriétés logiques seulement"; fi
grep -q ':root:not(.js-panels) .panel-layer:target' <<< "$panel_css" && pass "volets : ouverts par leur ancre sans JavaScript" || fail "volets : ouverture sans JavaScript"
grep -q 'width: min(100%, var(--panel-w));' <<< "$panel_css" && grep -q '^    --panel-w: 400px;$' public/assets/css/site.css && pass "volets : plein écran au téléphone, 400 px au plus" || fail "volets : largeur"
expect "site.js : Échap, retour arrière, voile et croix" "1|1|1" \
    "$(grep -c "event.key === 'Escape'" <<< "$(sed -n '/Volets de la charte commune/,/^})();/p' public/assets/js/site.js)")|$(grep -c "addEventListener('popstate'" public/assets/js/site.js)|$(grep -c "closest('\[data-panel-close\]')" public/assets/js/site.js)"
grep -q '@media (min-width: 900px)' <<< "$(sed -n '/Grand écran (charte commune)/,$p' public/assets/css/site.css)" && pass "liens de la barre dès 900 px" || fail "seuil de 900 px absent"
# Aucune fenêtre surgissante : ni <dialog>, ni fenêtre modale centrée, ni confirm(), alert() ou window.open().
if grep -rniE '<dialog|class="[^"]*modal|\.modal|confirm\(|alert\(|window\.open|popup' app public/*.php public/assets/js public/assets/css lang >/dev/null; then
    fail "fenêtre surgissante :"; grep -rniE '<dialog|class="[^"]*modal|\.modal|confirm\(|alert\(|window\.open|popup' app public/*.php public/assets/js public/assets/css lang
else
    pass "aucune fenêtre surgissante"
fi
# Police unique : système en latin, IBM Plex Sans Arabic servie par le site en arabe ; aucune autre police.
expect "polices servies : IBM Plex Sans Arabic seulement" 4 "$(ls public/assets/fonts/*.woff2 | grep -c 'IBMPlexSansArabic-')"
expect "polices déclarées : système et IBM Plex Sans Arabic seulement" 0 \
    "$(grep -oE 'font-family:[^;]+' public/assets/css/site.css | grep -vE "var\(--font\)|-apple-system|'IBM Plex Sans Arabic'" | wc -l | tr -d ' ')"
if grep -qE '@import|fonts\.googleapis|font-face[^}]*url\(https?:' public/assets/css/site.css; then fail "police chez un tiers"; else pass "aucune police chez un tiers"; fi
# « Continuer avec Noorwan » toujours bleu, jamais recoloré par le thème sombre.
grep -q '^\.btn-connect {$' public/assets/css/site.css && [[ "$(sed -n '/^\.btn-connect {$/,/^}/p' public/assets/css/site.css)" == *"background: #0071E3;"* ]] \
    && pass "« Continuer avec Noorwan » en bleu #0071E3" || fail "couleur du bouton Connect"
expect "jetons de la charte commune (clair, sombre manuel, sombre appareil)" "3|3|3" \
    "$(grep -cE '^ *--control-line: #' public/assets/css/site.css)|$(grep -cE '^ *--scrim: rgba' public/assets/css/site.css)|$(grep -cE '^ *--focus: #' public/assets/css/site.css)"

echo "6. Application Android (M-122)"
# Tout est dans mobile/ (le site n'a pas d'outil de build) : jamais servi, jamais dans public/.
cap=mobile/capacitor.config.json
cap_value() { "$PHP" -r '$c = json_decode(file_get_contents($argv[1]), true); $v = eval("return \$c" . $argv[2] . ";"); echo is_bool($v) ? ($v ? "true" : "false") : (is_array($v) ? implode(",", $v) : $v);' "$cap" "$1" 2>/dev/null; }
expect "application : identifiant" "com.noorwan.site" "$(cap_value "['appId']")"
expect "application : nom" "Noorwan" "$(cap_value "['appName']")"
expect "application : dossier web dans mobile/" "www" "$(cap_value "['webDir']")"
expect "application : adresse du site" "https://noorwan.com" "$(cap_value "['server']['url']")"
expect "application : ni clair ni contenu mixte, schéma https" "false|https|false" \
    "$(cap_value "['server']['cleartext']")|$(cap_value "['server']['androidScheme']")|$(cap_value "['android']['allowMixedContent']")"
expect "application : navigation permise vers le Compte seulement" "compte.noorwan.com" "$(cap_value "['server']['allowNavigation']")"
expect "application : page de secours" "index.html" "$(cap_value "['server']['errorPath']")"
expect "application : paquets Capacitor en 8.x" "3" \
    "$(grep -cE '"@capacitor/(core|cli|android)": "\^8\.' mobile/package.json)"
# Page hors ligne : française, sans script en ligne ni ressource externe, « Réessayer » vers le site.
offline=mobile/www/index.html
expect "page hors ligne : français, « Pas de connexion », « Réessayer »" "1|1|1" \
    "$(grep -c '<html lang="fr">' $offline)|$(grep -c '<h1>Pas de connexion</h1>' $offline)|$(grep -c '>Réessayer</button>' $offline)"
if grep -qiE '<script([^>]*)>' $offline && grep -iE '<script([^>]*)>' $offline | grep -qv 'src='; then fail "page hors ligne : script en ligne"; else pass "page hors ligne : aucun script en ligne"; fi
if grep -qE '(src|href)="https?://' $offline; then fail "page hors ligne : ressource externe"; else pass "page hors ligne : aucune ressource externe"; fi
grep -q "var SITE_URL = 'https://noorwan.com/';" mobile/www/offline.js && pass "« Réessayer » renvoie vers l'adresse du site" || fail "adresse de offline.js différente de server.url"
# Projet Android : identité, barre d'état, icônes de la famille commune.
res=mobile/android/app/src/main/res
expect "projet Android : nom (titre et application), identifiant, activité" "2|1|1" \
    "$(grep -c '>Noorwan<' $res/values/strings.xml)|$(grep -c 'applicationId "com.noorwan.site"' mobile/android/app/build.gradle)|$(ls mobile/android/app/src/main/java/com/noorwan/site/MainActivity.java 2>/dev/null | wc -l | tr -d ' ')"
expect "barre d'état #1D1D1F, statusBarColor du thème et fond de l'icône #1D1D1F" "1|1|1" \
    "$(grep -c '<color name="colorPrimaryDark">#1D1D1F<' $res/values/colors.xml)|$(grep -c 'statusBarColor' $res/values/styles.xml)|$(grep -c '#1D1D1F' $res/values/ic_launcher_background.xml)"
grep -q 'ic_launcher_foreground' $res/mipmap-anydpi-v26/ic_launcher.xml && grep -q 'ic_launcher_background' $res/mipmap-anydpi-v26/ic_launcher.xml \
    && pass "icône adaptative : fond et premier plan" || fail "icône adaptative"
icon_sizes=""
for entry in mdpi:48 hdpi:72 xhdpi:96 xxhdpi:144 xxxhdpi:192; do
    density="${entry%%:*}"; size="${entry##*:}"; fg=$(( size * 108 / 48 ))
    for name in ic_launcher ic_launcher_round; do
        icon_sizes+="$(file "$res/mipmap-$density/$name.png" | grep -c "$size x $size") "
    done
    icon_sizes+="$(file "$res/mipmap-$density/ic_launcher_foreground.png" | grep -c "$fg x $fg") "
done
expect "icônes du lanceur : carrée, ronde et premier plan aux cinq densités" "1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 " "$icon_sizes"
expect "écrans de démarrage présents" "11" "$(ls $res/drawable/splash.png $res/drawable-land-*/splash.png $res/drawable-port-*/splash.png | wc -l | tr -d ' ')"
# Rien de l'application dans public/ ni servi ; ce qui ne se versionne pas est ignoré.
if ls -A public | grep -qiE 'android|mobile|capacitor|node_modules|package'; then fail "application dans public/ : $(ls -A public | grep -iE 'android|mobile|capacitor|node_modules|package')"; else pass "rien de l'application dans public/"; fi
if grep -rqiE 'capacitor|com\.noorwan\.site' public app lang; then fail "référence à l'application dans le site"; else pass "le site ne connaît pas l'application"; fi
expect "git ignore : dépendances, compilation, clés de signature" "5" \
    "$(grep -cxE 'mobile/node_modules/|mobile/android/app/build/|\*\.jks|\*\.keystore|keystore\.properties' .gitignore)"
if git ls-files --error-unmatch mobile/node_modules >/dev/null 2>&1 || [[ -n "$(git ls-files 'mobile/android/app/build' '*.jks' '*.keystore' 2>/dev/null)" ]]; then fail "fichier ignoré versionné"; else pass "ni dépendances, ni compilation, ni clé versionnées"; fi
# OnePay, tiret cadratin et mot interdit absents de l'application.
files=(mobile/capacitor.config.json mobile/package.json mobile/www mobile/android/app/src docs/Tech-Notes/Application-Android.md)
if grep -rniE 'onepay' "${files[@]}" >/dev/null 2>&1; then fail "OnePay présent dans l'application"; else pass "OnePay absent de l'application"; fi
if grep -rn $'—' "${files[@]}" >/dev/null 2>&1; then fail "tiret cadratin dans l'application"; else pass "aucun tiret cadratin dans l'application"; fi
if grep -rniE 'djiboutien' "${files[@]}" >/dev/null 2>&1; then fail "« djiboutien » dans l'application"; else pass "aucun « djiboutien » dans l'application"; fi

echo
if [[ $failures -eq 0 ]]; then echo "Tous les tests passent."; else echo "$failures test(s) en échec."; fi
exit $(( failures > 0 ))
