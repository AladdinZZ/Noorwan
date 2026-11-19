<?php

declare(strict_types=1);

require __DIR__ . '/../app/bootstrap.php';

// Accueil, maquette A épurée (M-56, validée le 6/11/2026) : un message par écran.
// v6 : une page par onglet, l'accueil résume chaque onglet en quelques lignes avec « En savoir plus » vers sa page.
// Ordre : haut de page, Consulting, Solutions, Noorwan Connect (un écran chacun), méthode en trois étapes,
// Pourquoi Noorwan, contact. Illustrations dessinées dans assets/img, décoratives (alt vide).
// Les anciennes ancres (#consulting, #edition-univers, #edition) mènent à la page Consulting (data-hash-redirect, site.js) ;
// sans JavaScript, elles tombent sur le résumé du Consulting, qui y mène aussi.
current_page('index');
$meta = ['title' => raw('meta.home_title'), 'description' => raw('meta.home_description')];

$universes = tl('home.univers');
// « Une vision claire. Des étapes concrètes. » : la seconde phrase passe en gris sur sa propre ligne.
[$mottoFirst, $mottoSecond] = preg_split('/(?<=\.)\s+/u', raw('home.motto'), 2) + [1 => ''];
// Illustration de chaque étape de la méthode, dans l'ordre de home.steps.
$stepVisuals = ['field', 'build', 'improve'];
$accompaniment = url('consulting', 'accompagnement');

require ROOT_DIR . '/app/layout/header.php';
?>
<section id="top" class="screen hero" aria-labelledby="hero-title">
    <div class="wrap">
        <h1 id="hero-title" class="h1"><?= e($mottoFirst) ?><?php if ($mottoSecond !== ''): ?> <span class="h1-soft"><?= e($mottoSecond) ?></span><?php endif; ?></h1>
        <p class="lead"><?= t('home.lead') ?></p>
        <p class="links">
            <a class="more" href="<?= e(url('consulting')) ?>"><?= t('home.btn_explore') ?></a>
            <a class="more" href="<?= e(url('index', 'contact')) ?>"><?= t('home.btn_talk') ?></a>
        </p>
    </div>
    <div class="hero-visual"><?= illustration('hero', 'illus', 1600, 1000, ['fetchpriority' => 'high', 'decoding' => 'async']) ?></div>
</section>

<div id="univers">
<section id="consulting" class="screen universe screen-mist tone-consulting" aria-labelledby="consulting-title" data-hash-redirect="<?= e(url('consulting')) ?>">
    <span id="edition-univers" data-hash-redirect="<?= e($accompaniment) ?>"></span><span id="edition" data-hash-redirect="<?= e($accompaniment) ?>"></span>
    <div class="wrap">
        <p class="num" aria-hidden="true">01</p>
        <p class="eyebrow"><?= e($universes['consulting']['title']) ?></p>
        <h2 id="consulting-title" class="h2"><?= t('home.cons_app_h') ?></h2>
        <p class="lead"><?= e($universes['consulting']['text']) ?></p>
        <p class="links"><a class="more" href="<?= e(url('consulting')) ?>"><?= t('common.learn_more') ?></a></p>
    </div>
    <div class="shape"><?= illustration('universe-consulting', 'illus', 760, 380, ['loading' => 'lazy', 'decoding' => 'async']) ?></div>
</section>

<section id="solutions" class="screen universe screen-dark tone-solutions" aria-labelledby="solutions-title">
    <div class="wrap">
        <p class="num" aria-hidden="true">02</p>
        <p class="eyebrow"><?= e($universes['solutions']['title']) ?></p>
        <h2 id="solutions-title" class="h2"><?= t('home.sol_h') ?></h2>
        <p class="lead"><?= e($universes['solutions']['text']) ?></p>
        <p class="links"><a class="more" href="<?= e(url('solutions')) ?>"><?= t('common.learn_more') ?></a></p>
    </div>
    <div class="shape"><?= illustration('universe-solutions', 'illus', 760, 380, ['loading' => 'lazy', 'decoding' => 'async']) ?></div>
</section>

<section id="connect" class="screen universe screen-mist tone-connect" aria-labelledby="connect-title">
    <div class="wrap">
        <p class="num" aria-hidden="true">03</p>
        <p class="eyebrow"><?= t('connect.tag') ?></p>
        <h2 id="connect-title" class="h2"><?= t('connect.title') ?></h2>
        <p class="lead"><?= t('connect.lead') ?></p>
        <p class="links"><a class="more" href="<?= e(url('connect')) ?>"><?= t('common.learn_more') ?></a></p>
    </div>
    <div class="shape"><?= illustration('connect-hero', 'illus', 640, 400, ['loading' => 'lazy', 'decoding' => 'async']) ?></div>
</section>
</div>

<section id="methode" class="screen method" aria-labelledby="method-title">
    <div class="wrap">
        <h2 id="method-title" class="h2"><?= t('home.app_h') ?></h2>
        <ol class="method-steps">
<?php foreach (tl('home.steps') as $i => $step): ?>
            <li>
                <div class="step-visual"><?= illustration('step-' . $stepVisuals[$i], 'illus', 320, 220, ['loading' => 'lazy', 'decoding' => 'async']) ?></div>
                <span class="method-num" aria-hidden="true"><?= $i + 1 ?></span>
                <strong><?= e($step['title']) ?></strong>
                <span class="step-text"><?= e($step['text']) ?></span>
            </li>
<?php endforeach; ?>
        </ol>
    </div>
</section>

<section class="screen screen-dark" aria-labelledby="why-title">
    <div class="wrap">
        <p class="eyebrow eyebrow-gold"><?= t('home.why_eyebrow') ?></p>
        <h2 id="why-title" class="h2"><?= t('home.why_h') ?></h2>
        <p class="lead"><?= t('home.why_text') ?></p>
        <ul class="why-points">
<?php foreach (tl('home.why_points') as $point): ?>
            <li><strong><?= e($point['title']) ?></strong> <span><?= e($point['text']) ?></span></li>
<?php endforeach; ?>
        </ul>
    </div>
</section>

<?php
$ctaId = 'contact';
require ROOT_DIR . '/app/layout/cta.php';
require ROOT_DIR . '/app/layout/footer.php';
