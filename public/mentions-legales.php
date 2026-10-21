<?php

declare(strict_types=1);

require __DIR__ . '/../app/bootstrap.php';

// Page légale rédigée sur la base du RGPD. Textes dans lang/*.php (legal.mentions).
current_page('mentions-legales');
$meta = ['title' => raw('meta.mentions_title'), 'description' => raw('meta.mentions_description')];
$legalKey = 'mentions';

require ROOT_DIR . '/app/layout/header.php';
?>
<!-- A FAIRE RELIRE PAR UN JURISTE -->
<?php
require ROOT_DIR . '/app/layout/legal.php';
require ROOT_DIR . '/app/layout/footer.php';
