<?php

declare(strict_types=1);

require __DIR__ . '/../app/bootstrap.php';
require ROOT_DIR . '/app/seo.php';

// Servi à l'adresse /sitemap.xml (réécriture dans .htaccess).
header('Content-Type: application/xml; charset=utf-8');
echo sitemap_xml();
