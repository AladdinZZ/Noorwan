<?php

declare(strict_types=1);

require __DIR__ . '/../app/bootstrap.php';
require ROOT_DIR . '/app/books.php';

// Accueil, maquette A épurée (M-56, validée le 6/11/2026) : un message par écran.
// Ordre : haut de page, trois univers (un écran chacun), produits de Solutions, Édition, Pourquoi Noorwan, contact.
current_page('index');
$meta = ['title' => raw('meta.home_title'), 'description' => raw('meta.home_description')];

$universes = tl('home.univers');
// « Une vision claire. Des étapes concrètes. » : la seconde phrase passe en gris sur sa propre ligne.
[$mottoFirst, $mottoSecond] = preg_split('/(?<=\.)\s+/u', raw('home.motto'), 2) + [1 => ''];
$trilogy = books_in('metaphysique');
$chemins = array_map('book_title', books_in('chemins'));

require ROOT_DIR . '/app/layout/header.php';
?>
<section id="top" class="screen hero" aria-labelledby="hero-title">
    <div class="wrap">
        <p class="eyebrow eyebrow-muted"><?= e(implode(raw('common.list_sep'), array_column($universes, 'title'))) ?></p>
        <h1 id="hero-title" class="h1"><?= e($mottoFirst) ?><?php if ($mottoSecond !== ''): ?> <span class="h1-soft"><?= e($mottoSecond) ?></span><?php endif; ?></h1>
        <p class="lead"><?= t('home.lead') ?></p>
        <p class="links">
            <a class="more" href="<?= e(url('index', 'univers')) ?>"><?= t('home.btn_explore') ?></a>
            <a class="more" href="<?= e(url('index', 'contact')) ?>"><?= t('home.btn_talk') ?></a>
        </p>
    </div>
    <div class="hero-visual" aria-hidden="true"><span dir="ltr">noorwan.</span></div>
</section>

<div id="univers">
<section id="consulting" class="screen universe screen-mist tone-consulting" aria-labelledby="consulting-title">
    <div class="wrap">
        <p class="num" aria-hidden="true">01</p>
        <p class="eyebrow"><?= e($universes['consulting']['title']) ?></p>
        <h2 id="consulting-title" class="h2"><?= t('home.cons_app_h') ?></h2>
        <p class="lead"><?= t('home.cons_lead') ?></p>
        <ul class="expertises">
<?php foreach (tl('home.expertises') as $expertise): ?>
            <li><strong><?= e($expertise['title']) ?></strong> <span><?= e($expertise['text']) ?></span></li>
<?php endforeach; ?>
        </ul>
        <p class="universe-note"><?= t('home.cons_app') ?></p>
        <p class="links"><a class="more" href="<?= e(url('contact', '', ['universe' => 'consulting'])) ?>"><?= t('home.btn_talk') ?></a></p>
    </div>
    <div class="shape" aria-hidden="true"></div>
</section>

<section id="solutions" class="screen universe screen-dark tone-solutions" aria-labelledby="solutions-title">
    <div class="wrap">
        <p class="num" aria-hidden="true">02</p>
        <p class="eyebrow"><?= e($universes['solutions']['title']) ?></p>
        <h2 id="solutions-title" class="h2"><?= t('home.sol_h') ?></h2>
        <p class="lead"><?= e($universes['solutions']['text']) ?></p>
        <p class="links"><a class="more" href="<?= e(url('solutions')) ?>"><?= t('home.sol_btn') ?></a></p>
    </div>
    <div class="shape" aria-hidden="true"></div>
</section>

<section id="edition-univers" class="screen universe tone-edition" aria-labelledby="edition-univers-title">
    <div class="wrap">
        <p class="num" aria-hidden="true">03</p>
        <p class="eyebrow"><?= e($universes['edition']['title']) ?></p>
        <h2 id="edition-univers-title" class="h2"><?= t('home.ed_h') ?></h2>
        <p class="lead"><?= e($universes['edition']['text']) ?></p>
        <p class="links"><a class="more" href="<?= e(url('edition')) ?>"><?= t('common.learn_more') ?></a></p>
    </div>
    <div class="shape" aria-hidden="true"></div>
</section>
</div>

<section class="products-section tone-solutions" aria-label="<?= t('home.products_label') ?>">
<?php require ROOT_DIR . '/app/layout/products.php'; ?>
</section>

<section id="edition" class="screen tone-edition" aria-labelledby="edition-title">
    <div class="wrap">
        <p class="eyebrow"><?= t('edition.tag') ?></p>
        <h2 id="edition-title" class="h2"><?= t('edition.collections.metaphysique.name') ?></h2>
        <p class="lead"><?= t('home.author_line') ?></p>
        <ul class="shelf">
<?php foreach ($trilogy as $id => $book): ?>
            <li>
<?php if ($book['cover'] !== null): ?>
                <img class="cover" src="assets/images/covers/<?= e($book['cover']) ?>" alt="<?= t('books.cover_alt', [':title' => book_title($book)]) ?>" width="<?= $book['cover_size'][0] ?>" height="<?= $book['cover_size'][1] ?>" loading="lazy" decoding="async">
<?php else: ?>
                <span class="cover-soon"><span class="cover-soon-label"><?= t('books.soon') ?></span><span class="cover-soon-title"><bdi><?= e(book_title($book)) ?></bdi></span></span>
<?php endif; ?>
            </li>
<?php endforeach; ?>
        </ul>
        <p class="shelf-caption"><?= t('edition.collections.chemins.name') ?><?= t('common.colon') ?><bdi><?= e(implode(raw('common.list_sep'), $chemins)) ?></bdi></p>
        <p class="links">
            <a class="more" href="<?= e(url('edition', 'catalogue')) ?>"><?= t('home.ed_btn_catalogue') ?></a>
            <a class="more" href="<?= e(url('contact', '', ['universe' => 'edition'])) ?>"><?= t('home.ed_btn') ?></a>
        </p>
    </div>
</section>

<section class="screen screen-dark" aria-labelledby="why-title">
    <div class="wrap">
        <p class="eyebrow eyebrow-gold"><?= t('home.why_eyebrow') ?></p>
        <h2 id="why-title" class="h2"><?= t('home.app_h') ?></h2>
        <p class="lead"><?= t('home.why_text') ?></p>
        <ul class="why-points">
<?php foreach (tl('home.why_points') as $point): ?>
            <li><strong><?= e($point['title']) ?></strong> <span><?= e($point['text']) ?></span></li>
<?php endforeach; ?>
        </ul>
        <ol class="steps">
<?php foreach (tl('home.steps') as $i => $step): ?>
            <li><span class="step-num">0<?= $i + 1 ?></span> <strong><?= e($step['title']) ?></strong> <span><?= e($step['text']) ?></span></li>
<?php endforeach; ?>
        </ol>
    </div>
</section>

<?php
$ctaId = 'contact';
require ROOT_DIR . '/app/layout/cta.php';
require ROOT_DIR . '/app/layout/footer.php';
