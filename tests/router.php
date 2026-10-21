<?php

declare(strict_types=1);

// Routeur du serveur intégré de PHP pour les tests en intégration continue :
// php -S 127.0.0.1:8000 -t public tests/router.php
// Reproduit ce que fait public/.htaccess sous Apache (réécritures, fichiers cachés refusés).

$path = (string) parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH);

$rewrites = ['/robots.txt' => 'robots.php', '/sitemap.xml' => 'sitemap.php'];
if (isset($rewrites[$path])) {
    require __DIR__ . '/../public/' . $rewrites[$path];

    return true;
}

if (str_contains($path, '/.')) {
    http_response_code(404);

    return true;
}

return false;
