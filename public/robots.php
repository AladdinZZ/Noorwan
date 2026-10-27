<?php

declare(strict_types=1);

require __DIR__ . '/../app/bootstrap.php';
require ROOT_DIR . '/app/seo.php';

// Servi à l'adresse /robots.txt (réécriture dans .htaccess).
header('Content-Type: text/plain; charset=utf-8');
echo robots_txt(is_indexable());
