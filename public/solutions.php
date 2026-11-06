<?php

declare(strict_types=1);

require __DIR__ . '/../app/bootstrap.php';

// Page Solutions, maquette A épurée (M-56) : en-tête, notre façon de faire, produits, Inteek en détail.
// Le titre et l'introduction reprennent ceux de la section Solutions de l'accueil. Aucun produit confidentiel hors liste (vérifié par tests/run.sh).
current_page('solutions');
$meta = ['title' => raw('meta.solutions_title'), 'description' => raw('meta.solutions_description')];

$contactSolutions = url('contact', '', ['universe' => 'solutions']);
$inteek = tl('home.products')['inteek'];

require ROOT_DIR . '/app/layout/header.php';
?>
<!-- TEXTES A VALIDER PAR MARWAN -->
<section class="page-hero tone-solutions" aria-labelledby="page-title">
    <div class="wrap">
        <p class="eyebrow eyebrow-sol"><?= t('solutions.tag') ?></p>
        <h1 id="page-title" class="h1 h1-page"><?= t('home.sol_h') ?></h1>
        <p class="lead"><?= t('home.sol_text') ?></p>
<?php if (account_url() !== null): ?>
        <p class="page-account"><?= t('solutions.account_text') ?> <a href="<?= e(account_url()) ?>"><?= t('nav.account') ?> <span aria-hidden="true"><?= t('common.arrow') ?></span></a></p>
<?php endif; ?>
        <p class="links"><a class="btn btn-dark" href="<?= e($contactSolutions) ?>"><?= t('solutions.btn_demo') ?> <span aria-hidden="true"><?= t('common.arrow') ?></span></a></p>
    </div>
</section>

<section class="section section-mist" aria-labelledby="approach-title">
    <div class="wrap">
        <h2 id="approach-title" class="h2 h2-section section-title"><?= t('solutions.approach_title') ?></h2>
        <ol class="principles">
<?php foreach (tl('solutions.principles') as $i => $principle): ?>
            <li>
                <span class="principle-num">0<?= $i + 1 ?></span>
                <h3><?= e($principle['title']) ?></h3>
                <p><?= e($principle['text']) ?></p>
            </li>
<?php endforeach; ?>
        </ol>
    </div>
</section>

<section class="products-section tone-solutions" aria-label="<?= t('home.products_label') ?>">
<?php require ROOT_DIR . '/app/layout/products.php'; ?>
</section>

<section id="inteek" class="screen screen-mist tone-solutions" aria-labelledby="inteek-title">
    <div class="wrap">
        <p class="eyebrow eyebrow-sol"><?= e($inteek['cat']) ?></p>
        <h2 id="inteek-title" class="h2"><?= e($inteek['name']) ?></h2>
        <p class="lead"><?= t('solutions.inteek_lead') ?></p>
        <p class="inteek-text"><?= t('solutions.inteek_text') ?></p>
        <h3 class="modules-title"><?= t('solutions.modules_title') ?></h3>
        <ul class="modules">
<?php foreach (tl('solutions.modules') as $module): ?>
            <li><?= e($module) ?></li>
<?php endforeach; ?>
        </ul>
    </div>
</section>

<?php
$ctaParams = ['universe' => 'solutions'];
$ctaButton = 'solutions.btn_demo';
require ROOT_DIR . '/app/layout/cta.php';
require ROOT_DIR . '/app/layout/footer.php';
