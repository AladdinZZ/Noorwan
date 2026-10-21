<?php

declare(strict_types=1);

require __DIR__ . '/../app/bootstrap.php';
require ROOT_DIR . '/app/books.php';

// Accueil, conforme à la maquette v1 validée le 21/10/2026 (docs/maquette/).
current_page('index');
$meta = ['title' => raw('meta.home_title'), 'description' => raw('meta.home_description')];

$lockIcon = '<svg width="12" height="12" viewBox="0 0 12 12" aria-hidden="true" focusable="false"><rect x="2" y="5.5" width="8" height="5.5" rx="1.2" fill="none" stroke="currentColor" stroke-width="1.2"/><path d="M4 5.5V4a2 2 0 0 1 4 0v1.5" fill="none" stroke="currentColor" stroke-width="1.2"/></svg>';

require ROOT_DIR . '/app/layout/header.php';
?>
<section id="top" class="hero" aria-labelledby="hero-title">
    <div class="wrap hero-inner">
        <p class="eyebrow"><?= t('home.eyebrow') ?></p>
        <h1 id="hero-title"><?= t('home.title') ?></h1>
        <p class="hero-lead"><?= t('home.lead') ?></p>
        <div class="actions">
            <a class="btn btn-blue" href="<?= e(url('index', 'univers')) ?>"><?= t('home.btn_explore') ?> <span aria-hidden="true"><?= t('common.arrow') ?></span></a>
            <a class="btn btn-outline-light" href="<?= e(url('index', 'contact')) ?>"><?= t('home.btn_talk') ?></a>
        </div>
        <p class="hero-motto"><?= t('home.motto') ?></p>
    </div>
</section>

<section id="univers" class="section" aria-labelledby="univers-title">
    <div class="wrap">
        <p class="eyebrow"><?= t('home.univ_eyebrow') ?></p>
        <h2 id="univers-title" class="h2 section-title"><?= t('home.univ_h') ?></h2>
        <div class="univ-grid">
<?php $n = 0; foreach (tl('home.univers') as $id => $universe): $n++; ?>
            <a class="univ-card tone-<?= e($id) ?>" href="<?= e(url('index', $id)) ?>">
                <div class="univ-body">
                    <div class="univ-top"><span class="univ-num">0<?= $n ?></span><span aria-hidden="true"><?= t('common.arrow_up') ?></span></div>
                    <h3><?= e($universe['title']) ?></h3>
                    <p><?= e($universe['text']) ?></p>
                </div>
            </a>
<?php endforeach; ?>
        </div>
    </div>
</section>

<section class="section section-dark" aria-labelledby="approach-title">
    <div class="wrap">
        <p class="eyebrow"><?= t('home.app_eyebrow') ?></p>
        <h2 id="approach-title" class="h2 section-title"><?= t('home.app_h') ?></h2>
        <ol class="steps">
<?php foreach (tl('home.steps') as $i => $step): ?>
            <li>
                <span class="step-num">0<?= $i + 1 ?></span>
                <p class="step-title"><?= e($step['title']) ?></p>
                <p class="step-text"><?= e($step['text']) ?></p>
            </li>
<?php endforeach; ?>
        </ol>
    </div>
</section>

<section id="consulting" class="section tone-consulting" aria-labelledby="consulting-title">
    <div class="wrap">
        <div class="split-head">
            <div>
                <p class="tag"><?= t('home.cons_eyebrow') ?></p>
                <h2 id="consulting-title" class="h2"><?= t('home.cons_h') ?></h2>
            </div>
            <p><?= t('home.cons_lead') ?></p>
        </div>
        <div class="cards cards-expertise">
<?php foreach (tl('home.expertises') as $i => $expertise): ?>
            <article class="card">
                <span class="card-num">0<?= $i + 1 ?></span>
                <h3><?= e($expertise['title']) ?></h3>
                <p><?= e($expertise['text']) ?></p>
            </article>
<?php endforeach; ?>
        </div>
        <div class="cons-foot">
            <p><strong><?= t('home.cons_app_h') ?></strong> <?= t('home.cons_app') ?></p>
            <a class="btn btn-dark" href="<?= e(url('index', 'contact')) ?>"><?= t('home.btn_talk') ?> <span aria-hidden="true"><?= t('common.arrow') ?></span></a>
        </div>
    </div>
</section>

<section id="solutions" class="section section-gray tone-solutions" aria-labelledby="solutions-title">
    <div class="wrap">
        <p class="tag"><?= t('home.sol_eyebrow') ?></p>
        <h2 id="solutions-title" class="h2 section-title"><?= t('home.sol_h') ?></h2>
        <div class="cards cards-solutions">
<?php foreach (tl('home.solutions') as $solution): ?>
            <article class="card solution">
                <div class="solution-top">
                    <span class="solution-cat"><?= e($solution['cat']) ?></span>
<?php if ($solution['confidential']): ?>
                    <span class="badge-confidential"><?= $lockIcon ?><?= t('home.confidential') ?></span>
<?php endif; ?>
                </div>
                <h3><?= e($solution['name']) ?></h3>
<?php if ($solution['text'] !== ''): ?>
                <p><?= e($solution['text']) ?></p>
<?php endif; ?>
            </article>
<?php endforeach; ?>
        </div>
    </div>
</section>

<section id="edition" class="section tone-edition" aria-labelledby="edition-title">
    <div class="wrap edition-teaser">
        <div>
            <p class="tag"><?= t('home.ed_eyebrow') ?></p>
            <h2 id="edition-title" class="h2"><?= t('home.ed_h') ?></h2>
            <p class="muted"><?= t('home.ed_text') ?></p>
            <div class="actions">
                <a class="btn btn-dark" href="<?= e(url('index', 'contact')) ?>"><?= t('home.ed_btn') ?></a>
                <a class="btn btn-text" href="<?= e(url('edition')) ?>"><?= t('home.ed_btn_catalogue') ?> <span aria-hidden="true"><?= t('common.arrow') ?></span></a>
            </div>
        </div>
        <ul class="shelf">
<?php foreach (books() as $id => $book): ?>
            <li>
<?php if ($book['cover'] !== null): ?>
                <img class="cover" src="assets/images/covers/<?= e($book['cover']) ?>" alt="<?= t('books.cover_alt', [':title' => $book['title']]) ?>" width="<?= $book['cover_size'][0] ?>" height="<?= $book['cover_size'][1] ?>" loading="lazy" decoding="async">
<?php else: ?>
                <div class="cover-soon">
                    <span class="cover-soon-label"><?= t('books.soon') ?></span>
                    <span class="cover-soon-title" aria-hidden="true"><bdi><?= e($book['title']) ?></bdi></span>
                </div>
<?php endif; ?>
                <span class="shelf-title"><bdi><?= e($book['title']) ?></bdi></span>
                <span class="shelf-sub"><?= t('books.items.' . $id . '.sub') ?></span>
            </li>
<?php endforeach; ?>
        </ul>
    </div>
</section>

<?php
$ctaId = 'contact';
require ROOT_DIR . '/app/layout/cta.php';
require ROOT_DIR . '/app/layout/footer.php';
