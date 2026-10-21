<?php

declare(strict_types=1);

// Amorçage commun à toutes les pages : configuration, en-têtes de sécurité, langue.

const ROOT_DIR = __DIR__ . '/..';
const STORAGE_DIR = ROOT_DIR . '/storage';

// Version des textes de consentement du formulaire : à changer dès que leur libellé change.
const CONSENT_TEXT_VERSION = '2026-10-21';

/**
 * Lit le fichier .env une fois (clé=valeur, lignes # ignorées) et renvoie la valeur demandée.
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

    $value = $values[$key] ?? getenv($key);

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

error_reporting(E_ALL);
ini_set('display_errors', is_local() ? '1' : '0');
ini_set('log_errors', '1');
mb_internal_encoding('UTF-8');
date_default_timezone_set('UTC');

// En-têtes de sécurité. Aucun script ni style en ligne : la CSP les interdit.
if (!headers_sent()) {
    header('Content-Type: text/html; charset=utf-8');
    header('X-Content-Type-Options: nosniff');
    header('X-Frame-Options: DENY');
    header('Referrer-Policy: strict-origin-when-cross-origin');
    header('Permissions-Policy: camera=(), microphone=(), geolocation=(), interest-cohort=()');
    header(
        "Content-Security-Policy: default-src 'self'; img-src 'self' data:; script-src 'self'; "
        . "style-src 'self'; font-src 'self'; "
        . "form-action 'self'; frame-ancestors 'none'; base-uri 'self'; object-src 'none'"
    );
    if (!is_indexable()) {
        header('X-Robots-Tag: noindex, nofollow');
    }
}

require __DIR__ . '/i18n.php';

// Les classes de app/ (Db, Csrf, RateLimit, ContactForm) se chargent à la demande.
spl_autoload_register(static function (string $class): void {
    $file = __DIR__ . '/' . $class . '.php';
    if (preg_match('/^[A-Z][A-Za-z]+$/', $class) === 1 && is_file($file)) {
        require $file;
    }
});
