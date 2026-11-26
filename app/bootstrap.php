<?php

declare(strict_types=1);

// Amorçage commun à toutes les pages : configuration, en-têtes de sécurité, langue.

const ROOT_DIR = __DIR__ . '/..';
const STORAGE_DIR = ROOT_DIR . '/storage';

// Version des textes de consentement du formulaire : à changer dès que leur libellé change.
const CONSENT_TEXT_VERSION = '2026-10-21';

// Adresse de contact publique du groupe, affichée sous le bandeau « Un projet en tête ? ».
const CONTACT_EMAIL = 'contact@noorwan.com';

/**
 * Lit le fichier .env une fois (clé=valeur, lignes # ignorées) et renvoie la valeur demandée,
 * sauf si l'environnement la définit déjà.
 */
function env(string $key, ?string $default = null): ?string
{
    static $values = null;

    if ($values === null) {
        $values = [];
        $file = ROOT_DIR . '/.env';
        if (is_readable($file)) {
            foreach (file($file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
                $line = trim($line);
                if ($line === '' || $line[0] === '#' || !str_contains($line, '=')) {
                    continue;
                }
                [$name, $value] = array_map('trim', explode('=', $line, 2));
                $values[$name] = trim($value, "\"'");
            }
        }
    }

    // Une variable d'environnement définie l'emporte sur .env (utile aux tests et à la ligne de commande).
    $value = getenv($key);
    if ($value === false) {
        $value = $values[$key] ?? null;
    }

    return ($value === false || $value === null || $value === '') ? $default : $value;
}

function is_local(): bool
{
    return env('APP_ENV', 'production') === 'local';
}

/**
 * Seule la production se laisse indexer, et seulement si APP_ENV le dit explicitement :
 * un .env incomplet donne un site non indexé plutôt qu'un site de démonstration dans les moteurs.
 */
function is_indexable(): bool
{
    return env('APP_ENV') === 'production';
}

function app_secret(): string
{
    $secret = env('APP_SECRET', '');
    if (strlen($secret) < 32) {
        throw new RuntimeException('APP_SECRET manquant ou trop court dans .env');
    }

    return $secret;
}

/**
 * Échappe une valeur pour une sortie HTML (contenu ou attribut).
 */
function e(string|int|float|null $value): string
{
    return htmlspecialchars((string) $value, ENT_QUOTES | ENT_SUBSTITUTE | ENT_HTML5, 'UTF-8');
}

/**
 * Illustration décorative (assets/img/<nom>.svg) et sa version sombre (<nom>-dark.svg, bin/illustrations-dark.php).
 * La version sombre suit l'appareil par media ; theme-init.js réécrit ce media quand le visiteur a choisi un thème.
 * $attributes : attributs ajoutés à l'image après la taille (loading, decoding, fetchpriority).
 */
function illustration(string $name, string $class, int $width, int $height, array $attributes = []): string
{
    $extra = '';
    foreach ($attributes as $attribute => $value) {
        $extra .= ' ' . e($attribute) . '="' . e($value) . '"';
    }

    return '<picture><source srcset="assets/img/' . e($name) . '-dark.svg" media="(prefers-color-scheme: dark)" data-theme-media="dark">'
        . '<img' . ($class !== '' ? ' class="' . e($class) . '"' : '') . ' src="assets/img/' . e($name) . '.svg" alt="" width="' . $width
        . '" height="' . $height . '"' . $extra . '></picture>';
}

// Photos d'en-tête des pages Consulting, Solutions, Édition et Contact (20 et 21/11/2026) : images sans texte, en WebP,
// deux largeurs (assets/img/<nom>-780.webp et <nom>-1440.webp). Le titre reste en HTML par-dessus, sélectionnable et traduit.
// Contact reprend la photo de réunion, qui n'existe qu'en 1200 px : sa grande largeur est 1200 (jamais d'agrandissement).
// Un script peut fixer le dossier lu avant l'amorçage (tests/run.sh, avec des images d'essai).
if (!defined('HERO_PHOTO_DIR')) {
    define('HERO_PHOTO_DIR', ROOT_DIR . '/public/assets/img');
}
const HERO_PHOTO_WIDTHS = [780, 1440];

/**
 * Photo d'en-tête d'une page, avec srcset et texte alternatif traduit ($altKey), ou chaîne vide tant qu'une des
 * largeurs manque : la page garde alors son rendu sans photo. Jamais en miroir en arabe.
 *
 * @param list<int> $widths largeurs déposées, de la plus petite à la plus grande (par défaut 780 et 1440)
 */
function hero_photo(string $name, string $altKey, array $widths = HERO_PHOTO_WIDTHS): string
{
    $sources = [];
    foreach ($widths as $width) {
        if (!is_file(HERO_PHOTO_DIR . '/' . $name . '-' . $width . '.webp')) {
            return '';
        }
        $sources[] = 'assets/img/' . $name . '-' . $width . '.webp ' . $width . 'w';
    }
    // Dimensions lues sur la plus grande image, pour réserver la place avant chargement.
    $size = @getimagesize(HERO_PHOTO_DIR . '/' . $name . '-' . max($widths) . '.webp');
    if ($size === false) {
        return '';
    }

    return '<div class="hero-photo"><img src="assets/img/' . e($name) . '-' . min($widths) . '.webp" srcset="' . e(implode(', ', $sources)) . '"'
        . ' sizes="100vw" alt="' . t($altKey) . '" width="' . $size[0] . '" height="' . $size[1] . '" fetchpriority="high" decoding="async"></div>';
}

// Compte Noorwan (compte.noorwan.com) : adresse et affichage des liens « Créer mon compte » et « J'ai déjà un compte » de la page Noorwan Connect.
// Le lien reste masqué tant que COMPTE_LINK_ENABLED ne vaut pas « true » dans .env.
// Un script peut définir ces constantes avant l'amorçage (tests/run.sh, pour les deux états).
if (!defined('COMPTE_URL')) {
    define('COMPTE_URL', rtrim((string) env('COMPTE_URL', 'https://compte.noorwan.com'), '/'));
}
if (!defined('COMPTE_LINK_ENABLED')) {
    define('COMPTE_LINK_ENABLED', env('COMPTE_LINK_ENABLED', 'false') === 'true');
}

/**
 * Lanceur des sites (bouton « grille » de l'en-tête, M-121, M-124) : liste publique des sites du groupe, toujours
 * complète, dans l'ordre noorwan.com, Connect, Reserva, Inteek et le site de paiement (M-123). noorwan.com n'a pas de
 * session Connect : c'est toujours cette liste. Le site courant (Noorwan) y reste, marqué, et mène à son accueil ; les
 * autres adresses viennent de .env (LAUNCHER_*_URL, puis les anciennes ECOSYSTEM_*_URL en repli), sinon des adresses
 * par défaut ; une adresse non https prend l'adresse par défaut, aucun site n'est jamais masqué (l'adresse du Compte
 * n'est jamais déduite de COMPTE_URL, v5 bis). Icône : copie sans modification de la charte commune, servie par le site
 * (public/images/sites/<clé>.svg, jamais sous /icons/, réservé par Apache) ; pastille couleur et lettre si elle ne se
 * charge pas. Jamais d'autre projet confidentiel.
 *
 * @return list<array{key: string, label: string, url: string, color: string, letter: string, icon: string, current: bool}>
 */
function launcher_sites(): array
{
    $external = static function (string $name, string $default): string {
        foreach (['LAUNCHER_', 'ECOSYSTEM_'] as $prefix) {
            $value = trim((string) env($prefix . $name . '_URL', ''));
            if ($value !== '') {
                return preg_match('#^https://[^\s"<>]+$#', $value) === 1 ? $value : $default;
            }
        }

        return $default;
    };
    $site = static fn (string $key, string $url, string $color, string $letter, bool $current = false): array => [
        'key' => $key,
        'label' => 'launcher.' . $key,
        'url' => $url,
        'color' => $color,
        'letter' => $letter,
        'icon' => 'images/sites/' . $key . '.svg',
        'current' => $current,
    ];

    return [
        $site('noorwan', url('index'), '#0071E3', 'n', true),
        $site('connect', $external('CONNECT', 'https://compte.noorwan.com/home'), '#248A3D', 'c'),
        $site('reserva', $external('RESERVA', 'https://dev.reserva.noorwan.com'), '#0F6F66', 'r'),
        $site('inteek', $external('INTEEK', 'https://dev.inteek.noorwan.com'), '#A85A00', 'i'),
        $site('onepay', $external('ONEPAY', 'https://dev.onepay.noorwan.com'), '#5B34C7', 'o'), // launcher seulement (M-123)
    ];
}

/**
 * Lien « Mon compte Connect » du bas du lanceur : l'adresse de Connect du lanceur (toujours présente).
 */
function launcher_account_url(): ?string
{
    foreach (launcher_sites() as $site) {
        if ($site['key'] === 'connect') {
            return $site['url'];
        }
    }

    return null;
}

// Installer le site sans magasin (M-132, modèle Reserva) : barre « Installer l'application Noorwan » en bas de l'écran
// (app/layout/install.php), ouverte par public/assets/js/site.js. Elle n'existe pas dans l'application Android
// (agent qui contient NoorwanApp) ; elle s'ouvre d'elle-même sur l'accueil et à l'arrivée par un code QR (?via=qr)
// ou par la grille des sites (?via=launcher), sauf après « Plus tard » : cookie nw_install_later=1, six mois, non
// chiffré, sans donnée personnelle, Path=/, SameSite=Lax, Secure en https (posé par site.js, lu ici).
const INSTALL_COOKIE = 'nw_install_later';
const INSTALL_MAX_AGE = 15552000;
const INSTALL_PARAM = 'via';
const INSTALL_ORIGINS = ['qr', 'launcher'];
const APP_AGENT_MARK = 'NoorwanApp';

/**
 * Page affichée dans l'application Android du groupe : son agent porte « NoorwanApp » (appendUserAgent).
 */
function in_native_app(): bool
{
    return str_contains((string) ($_SERVER['HTTP_USER_AGENT'] ?? ''), APP_AGENT_MARK);
}

/**
 * La barre d'installation et l'entrée du menu existent-elles sur cette page ? Jamais dans l'application Android.
 */
function install_available(): bool
{
    return !in_native_app();
}

/**
 * « Plus tard » choisi il y a moins de six mois.
 */
function install_postponed(): bool
{
    return ($_COOKIE[INSTALL_COOKIE] ?? null) === '1';
}

/**
 * Origine reconnue de l'arrivée (« qr », « launcher »), sinon null.
 */
function install_origin(): ?string
{
    $via = $_GET[INSTALL_PARAM] ?? null;

    return is_string($via) && in_array($via, INSTALL_ORIGINS, true) ? $via : null;
}

/**
 * La barre s'ouvre-t-elle d'elle-même sur cette page ? Accueil, ou arrivée par un code QR ou par la grille des sites.
 */
function install_auto(): bool
{
    if (!install_available() || install_postponed()) {
        return false;
    }

    return current_page() === 'index' || install_origin() !== null;
}

/**
 * Adresse complétée de son origine (?via=qr ou ?via=launcher, ou &via=...), sans doublon, avant l'ancre éventuelle.
 */
function with_origin(string $url, string $origin): string
{
    if (!in_array($origin, INSTALL_ORIGINS, true) || preg_match('/[?&]' . INSTALL_PARAM . '=/', $url) === 1) {
        return $url;
    }
    $fragment = '';
    $hash = strpos($url, '#');
    if ($hash !== false) {
        $fragment = substr($url, $hash);
        $url = substr($url, 0, $hash);
    }

    return $url . (str_contains($url, '?') ? '&' : '?') . INSTALL_PARAM . '=' . $origin . $fragment;
}

error_reporting(E_ALL);
ini_set('display_errors', is_local() ? '1' : '0');
ini_set('log_errors', '1');
mb_internal_encoding('UTF-8');
date_default_timezone_set('UTC');

// Mesure d'audience par Google Tag Manager (M-59, M-129), chargée seulement après l'accord « mesure d'audience ».
// GTM_ID vide ou mal formé : rien n'est chargé et la CSP reste fermée à Google (développement, tests).
if (!defined('GTM_ID')) {
    $gtmId = (string) env('GTM_ID', '');
    define('GTM_ID', preg_match('/^GTM-[A-Z0-9]{4,12}$/', $gtmId) === 1 ? $gtmId : '');
    unset($gtmId);
}

// Choix de cookies commun à tous les sites Noorwan (M-129, règle charte-commune/consentement.md), comme Connect :
// cookie nw_consent, valeur « v1.a{0|1}.m{0|1} » (a : mesure d'audience, m : publicité), six mois, Path=/,
// SameSite=Lax, Secure en https, non chiffré et jamais HttpOnly (les autres sites le lisent et le réécrivent en
// JavaScript), posé sur .noorwan.com quand l'hôte est noorwan.com ou un de ses sous-domaines, sinon sur l'hôte seul.
// Ancienne valeur du site (« granted » ou « denied », sur l'hôte seul) : reprise une fois par consent_migrate().
const CONSENT_COOKIE = 'nw_consent';
const CONSENT_MAX_AGE = 15552000;

/**
 * Choix lu dans une valeur du cookie, ou null si elle n'est pas de la forme commune.
 *
 * @return array{analytics: bool, ads: bool}|null
 */
function consent_parse(mixed $value): ?array
{
    if (!is_string($value) || preg_match('/^v1\.a([01])\.m([01])$/', $value, $match) !== 1) {
        return null;
    }

    return ['analytics' => $match[1] === '1', 'ads' => $match[2] === '1'];
}

function consent_encode(bool $analytics, bool $ads): string
{
    return 'v1.a' . (int) $analytics . '.m' . (int) $ads;
}

/**
 * Toutes les valeurs de nw_consent reçues : l'ancien cookie de l'hôte et le cookie commun de .noorwan.com peuvent
 * arriver ensemble sous le même nom, $_COOKIE n'en garde qu'un.
 *
 * @return list<string>
 */
function consent_values(): array
{
    $values = [];
    foreach (explode(';', (string) ($_SERVER['HTTP_COOKIE'] ?? '')) as $pair) {
        [$name, $value] = array_map('trim', explode('=', $pair, 2) + [1 => '']);
        if ($name === CONSENT_COOKIE) {
            $values[] = rawurldecode($value);
        }
    }
    if (isset($_COOKIE[CONSENT_COOKIE]) && is_string($_COOKIE[CONSENT_COOKIE])) {
        $values[] = $_COOKIE[CONSENT_COOKIE];
    }

    return $values;
}

/**
 * Ancienne valeur du site (« granted » : la seule mesure d'audience), lue tant qu'il n'y a pas de valeur commune.
 *
 * @return array{analytics: bool, ads: bool}|null
 */
function consent_legacy(): ?array
{
    $values = consent_values();
    foreach ($values as $value) {
        if (consent_parse($value) !== null) {
            return null;
        }
    }
    foreach ($values as $value) {
        if ($value === 'granted' || $value === 'denied') {
            return ['analytics' => $value === 'granted', 'ads' => false];
        }
    }

    return null;
}

/**
 * Choix du visiteur, ou null tant qu'il n'a pas répondu.
 *
 * @return array{analytics: bool, ads: bool}|null
 */
function consent_choice(): ?array
{
    foreach (consent_values() as $value) {
        $choice = consent_parse($value);
        if ($choice !== null) {
            return $choice;
        }
    }

    return consent_legacy();
}

function consent_analytics(): bool
{
    return consent_choice()['analytics'] ?? false;
}

function consent_ads(): bool
{
    return consent_choice()['ads'] ?? false;
}

/**
 * Domaine du cookie : « .noorwan.com » pour noorwan.com et ses sous-domaines, sinon null (l'hôte seul).
 */
function consent_domain(): ?string
{
    $host = strtolower((string) ($_SERVER['HTTP_HOST'] ?? parse_url((string) env('APP_URL', ''), PHP_URL_HOST) ?? ''));
    $host = preg_replace('/:\d+$/', '', $host);

    return $host === 'noorwan.com' || str_ends_with($host, '.noorwan.com') ? '.noorwan.com' : null;
}

/**
 * Réglages du cookie commun : six mois, Path=/, SameSite=Lax, Secure en https, jamais HttpOnly, domaine commun.
 *
 * @return array{expires: int, path: string, secure: bool, httponly: bool, samesite: string, domain?: string}
 */
function consent_cookie_options(): array
{
    $secure = ($_SERVER['HTTPS'] ?? '') === 'on' || str_starts_with((string) env('APP_URL', ''), 'https://');
    $options = ['expires' => time() + CONSENT_MAX_AGE, 'path' => '/', 'secure' => $secure, 'httponly' => false, 'samesite' => 'Lax'];
    $domain = consent_domain();
    if ($domain !== null) {
        $options['domain'] = $domain;
    }

    return $options;
}

/**
 * Pose le choix pour six mois. Sur le domaine commun, l'ancien cookie de l'hôte seul est d'abord effacé.
 */
function consent_store(bool $analytics, bool $ads): void
{
    $options = consent_cookie_options();
    if (isset($options['domain'])) {
        setcookie(CONSENT_COOKIE, '', ['expires' => 1, 'path' => '/', 'secure' => $options['secure'], 'samesite' => 'Lax']);
    }
    setcookie(CONSENT_COOKIE, consent_encode($analytics, $ads), $options);
}

/**
 * Reprise de l'ancienne valeur du site : recopiée dans la valeur commune, à la première page vue.
 */
function consent_migrate(): void
{
    $legacy = consent_legacy();
    if ($legacy !== null && !headers_sent()) {
        consent_store($legacy['analytics'], $legacy['ads']);
    }
}

/**
 * Nonce de la requête, seule autorisation des scripts en ligne d'amorçage de Tag Manager (pas d'« unsafe-inline »).
 */
function csp_nonce(): string
{
    static $nonce = null;

    return $nonce ??= base64_encode(random_bytes(18));
}

/**
 * Politique de sécurité du contenu. Aucun style en ligne ; aucun script en ligne sans le nonce.
 * Avec Tag Manager, elle s'ouvre seulement à ses domaines et à ceux de Google Analytics.
 */
function content_security_policy(): string
{
    $script = "'self'";
    $img = "'self' data:";
    $connect = "'self'";
    if (GTM_ID !== '') {
        $script .= " 'nonce-" . csp_nonce() . "' https://www.googletagmanager.com";
        $img .= ' https://www.googletagmanager.com https://*.google-analytics.com';
        $connect .= ' https://www.googletagmanager.com https://*.google-analytics.com https://*.analytics.google.com';
    }

    // Service worker et manifeste (M-132) : du site seulement, écrits pour ne pas dépendre de default-src.
    return "default-src 'self'; img-src " . $img . '; script-src ' . $script . "; style-src 'self'; font-src 'self'; "
        . 'connect-src ' . $connect . "; worker-src 'self'; manifest-src 'self'; form-action 'self'; frame-ancestors 'none'; base-uri 'self'; object-src 'none'";
}

// En-têtes de sécurité.
if (!headers_sent()) {
    header('Content-Type: text/html; charset=utf-8');
    header('X-Content-Type-Options: nosniff');
    header('X-Frame-Options: DENY');
    header('Referrer-Policy: strict-origin-when-cross-origin');
    header('Permissions-Policy: camera=(), microphone=(), geolocation=(), interest-cohort=()');
    header('Content-Security-Policy: ' . content_security_policy());
    if (!is_indexable()) {
        header('X-Robots-Tag: noindex, nofollow');
    }
    consent_migrate();
}

require __DIR__ . '/i18n.php';

// Les classes de app/ (Db, Csrf, RateLimit, ContactForm) se chargent à la demande.
spl_autoload_register(static function (string $class): void {
    $file = __DIR__ . '/' . $class . '.php';
    if (preg_match('/^[A-Z][A-Za-z]+$/', $class) === 1 && is_file($file)) {
        require $file;
    }
});
