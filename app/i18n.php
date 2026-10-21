<?php

declare(strict_types=1);

// Langues, chaînes traduites et construction des liens (le paramètre ?lang= suit partout).

const LANGS = [
    'fr' => ['label' => 'FR', 'name' => 'Français', 'dir' => 'ltr'],
    'en' => ['label' => 'EN', 'name' => 'English', 'dir' => 'ltr'],
    'ar' => ['label' => 'عربي', 'name' => 'العربية', 'dir' => 'rtl'],
];
const DEFAULT_LANG = 'fr';

// Pages publiques : identifiant => fichier dans public/.
const PAGES = [
    'index' => '',
    'edition' => 'edition.php',
    'contact' => 'contact.php',
    'mentions-legales' => 'mentions-legales.php',
    'confidentialite' => 'confidentialite.php',
    'cookies' => 'cookies.php',
];

function lang(): string
{
    static $lang = null;
    if ($lang === null) {
        $requested = $_GET['lang'] ?? DEFAULT_LANG;
        $lang = (is_string($requested) && isset(LANGS[$requested])) ? $requested : DEFAULT_LANG;
    }

    return $lang;
}

function dir_attr(): string
{
    return LANGS[lang()]['dir'];
}

function is_rtl(): bool
{
    return dir_attr() === 'rtl';
}

/**
 * Charge le tableau de chaînes d'une langue (une seule lecture par langue).
 */
function strings(string $lang): array
{
    static $cache = [];

    return $cache[$lang] ??= require ROOT_DIR . '/lang/' . $lang . '.php';
}

/**
 * Valeur brute d'une clé à points (« home.title »), avec repli sur le français.
 */
function raw(string $key): mixed
{
    foreach (array_unique([lang(), DEFAULT_LANG]) as $lang) {
        $value = strings($lang);
        foreach (explode('.', $key) as $part) {
            if (!is_array($value) || !array_key_exists($part, $value)) {
                $value = null;
                break;
            }
            $value = $value[$part];
        }
        if ($value !== null) {
            return $value;
        }
    }

    if (is_local()) {
        trigger_error('Chaîne de traduction manquante : ' . $key, E_USER_WARNING);
    }

    return $key;
}

/**
 * Chaîne traduite, toujours échappée. $vars remplace des marqueurs (« :title ») avant échappement.
 */
function t(string $key, array $vars = []): string
{
    $value = raw($key);
    if (!is_string($value)) {
        throw new LogicException('La clé ' . $key . ' n\'est pas une chaîne');
    }

    return e(strtr($value, $vars));
}

/**
 * Liste traduite, non échappée : chaque valeur affichée passe par e().
 */
function tl(string $key): array
{
    $value = raw($key);

    return is_array($value) ? $value : [];
}

/**
 * Identifiant de la page en cours, fixé par chaque fichier de public/.
 */
function current_page(?string $set = null): string
{
    static $page = 'index';
    if ($set !== null) {
        $page = $set;
    }

    return $page;
}

/**
 * Lien relatif vers une page, langue comprise. Sur la page elle-même, une ancre seule suffit.
 */
function url(string $page = 'index', string $fragment = '', array $params = [], ?string $lang = null): string
{
    $hash = $fragment !== '' ? '#' . $fragment : '';
    if ($lang === null && $params === [] && $hash !== '' && $page === current_page()) {
        return $hash;
    }

    $query = http_build_query(['lang' => $lang ?? lang()] + $params);

    return (PAGES[$page] === '' ? './' : PAGES[$page]) . '?' . $query . $hash;
}

/**
 * Adresse absolue d'une page dans une langue (canonique, hreflang).
 */
function absolute_url(string $page, string $lang): string
{
    return rtrim((string) env('APP_URL', ''), '/') . '/' . PAGES[$page] . '?lang=' . $lang;
}
