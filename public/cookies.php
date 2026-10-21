<?php

declare(strict_types=1);

require __DIR__ . '/../app/bootstrap.php';

// Page légale rédigée sur la base du RGPD. Textes dans lang/*.php (legal.cookies).
current_page('cookies');
$meta = ['title' => raw('meta.cookies_title'), 'description' => raw('meta.cookies_description')];
$legalKey = 'cookies';

require ROOT_DIR . '/app/layout/header.php';
?>
<!-- A FAIRE RELIRE PAR UN JURISTE -->
<?php
require ROOT_DIR . '/app/layout/legal.php';
require ROOT_DIR . '/app/layout/footer.php';
