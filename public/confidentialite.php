<?php

declare(strict_types=1);

require __DIR__ . '/../app/bootstrap.php';

// Page légale rédigée sur la base du RGPD. Textes dans lang/*.php (legal.privacy).
current_page('confidentialite');
$meta = ['title' => raw('meta.privacy_title'), 'description' => raw('meta.privacy_description')];
$legalKey = 'privacy';

require ROOT_DIR . '/app/layout/header.php';
?>
<!-- A FAIRE RELIRE PAR UN JURISTE -->
<?php
require ROOT_DIR . '/app/layout/legal.php';
require ROOT_DIR . '/app/layout/footer.php';
