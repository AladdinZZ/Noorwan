<?php

declare(strict_types=1);

require __DIR__ . '/../app/bootstrap.php';

// Page Solutions : notre façon de faire, Inteek en détail, puis les solutions confidentielles.
// Le titre et l'introduction reprennent ceux de la section Solutions de l'accueil.
current_page('solutions');
$meta = ['title' => raw('meta.solutions_title'), 'description' => raw('meta.solutions_description')];

$contactSolutions = url('contact', '', ['universe' => 'solutions']);
$solutions = tl('home.solutions');
$inteek = array_column($solutions, null, 'name')['Inteek'];
$confidential = array_filter($solutions, static fn (array $solution): bool => $solution['confidential']);

require ROOT_DIR . '/app/layout/header.php';
?>
<!-- TEXTES A VALIDER PAR MARWAN -->
<section class="page-hero tone-solutions" aria-labelledby="page-title">
    <div class="wrap">
        <p class="tag"><?= t('solutions.tag') ?></p>
        <h1 id="page-title"><?= t('home.sol_h') ?></h1>
        <p class="page-lead"><?= t('home.sol_text') ?></p>
        <div class="actions">
            <a class="btn btn-dark" href="<?= e($contactSolutions) ?>"><?= t('solutions.btn_demo') ?> <span aria-hidden="true"><?= t('common.arrow') ?></span></a>
        </div>
    </div>
</section>

<section class="section tone-solutions" aria-labelledby="approach-title">
    <div class="wrap">
        <h2 id="approach-title" class="h2 section-title"><?= t('solutions.approach_title') ?></h2>
        <ol class="cards cards-steps">
<?php foreach (tl('solutions.principles') as $i => $principle): ?>
            <li class="card">
                <span class="card-num">0<?= $i + 1 ?></span>
                <h3><?= e($principle['title']) ?></h3>
                <p><?= e($principle['text']) ?></p>
            </li>
<?php endforeach; ?>
        </ol>
    </div>
</section>

<section id="inteek" class="section section-gray tone-solutions" aria-labelledby="inteek-title">
    <div class="wrap inteek">
        <div class="inteek-intro">
            <p class="tag"><?= e($inteek['cat']) ?></p>
            <h2 id="inteek-title" class="h2"><?= e($inteek['name']) ?></h2>
            <p class="inteek-lead"><?= t('solutions.inteek_lead') ?></p>
            <p class="muted"><?= t('solutions.inteek_text') ?></p>
        </div>
        <div class="inteek-modules">
            <h3><?= t('solutions.modules_title') ?></h3>
            <ul>
<?php foreach (tl('solutions.modules') as $module): ?>
                <li><?= e($module) ?></li>
<?php endforeach; ?>
            </ul>
        </div>
    </div>
</section>

<section class="section tone-solutions" aria-labelledby="others-title">
    <div class="wrap">
        <h2 id="others-title" class="h2 section-title"><?= t('solutions.others_title') ?></h2>
        <div class="cards cards-solutions">
<?php $solutionText = raw('solutions.on_request'); ?>
<?php foreach ($confidential as $solution): ?>
<?php require ROOT_DIR . '/app/layout/solution-card.php'; ?>
<?php endforeach; ?>
        </div>
    </div>
</section>

<?php
$ctaParams = ['universe' => 'solutions'];
$ctaButton = 'solutions.btn_demo';
require ROOT_DIR . '/app/layout/cta.php';
require ROOT_DIR . '/app/layout/footer.php';
