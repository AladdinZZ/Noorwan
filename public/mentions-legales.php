<?php

declare(strict_types=1);

require __DIR__ . '/../app/bootstrap.php';

current_page('mentions-legales');
$meta = ['title' => raw('meta.mentions_title'), 'description' => raw('meta.mentions_description')];

require ROOT_DIR . '/app/layout/header.php';
?>
<section class="page-hero">
    <div class="wrap">
        <h1><?= e($meta['title']) ?></h1>
    </div>
</section>
<?php require ROOT_DIR . '/app/layout/footer.php';
