<?php

declare(strict_types=1);

require __DIR__ . '/../app/bootstrap.php';

// Enregistre le choix de mesure d'audience (bandeau ou page Cookies) dans le cookie nw_consent, pour six mois.
// Un refus efface aussi les cookies de Google Analytics déjà posés. Réponse 204 à site.js, sinon retour à la page.

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    header('Allow: POST');
    exit;
}

$choice = $_POST['choice'] ?? '';
if (!in_array($choice, ['granted', 'denied'], true) || !Csrf::isValid('consent', $_POST['token'] ?? null)) {
    http_response_code(400);
    exit;
}

$secure = str_starts_with((string) env('APP_URL', ''), 'https://');
setcookie(CONSENT_COOKIE, $choice, [
    'expires' => time() + CONSENT_MAX_AGE,
    'path' => '/',
    'secure' => $secure,
    'httponly' => true,
    'samesite' => 'Lax',
]);

if ($choice === 'denied') {
    // Cookies de Google Analytics (_ga, _ga_XXXX) : posés sur le domaine principal, retirés sur ce domaine et sur l'hôte.
    $host = (string) parse_url((string) env('APP_URL', ''), PHP_URL_HOST);
    $domain = preg_replace('/^www\./', '', $host);
    foreach (array_keys($_COOKIE) as $name) {
        if (preg_match('/^_ga(_[A-Za-z0-9]+)?$/', (string) $name) === 1) {
            setcookie((string) $name, '', ['expires' => 1, 'path' => '/']);
            if ($domain !== '' && filter_var($domain, FILTER_VALIDATE_IP) === false) {
                setcookie((string) $name, '', ['expires' => 1, 'path' => '/', 'domain' => '.' . $domain]);
            }
        }
    }
}

if (str_contains((string) ($_SERVER['HTTP_ACCEPT'] ?? ''), 'application/json')) {
    http_response_code(204);
    exit;
}

// Retour seulement vers une page du site (jamais une adresse externe).
$back = (string) ($_POST['back'] ?? '');
$path = (string) parse_url($back, PHP_URL_PATH);
$valid = !str_contains($back, '//') && !str_contains($back, '\\') && ($path === './' || in_array($path, PAGES, true));
header('Location: ' . ($valid ? $back : url('index')), true, 303);
