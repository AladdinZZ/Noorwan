<?php

declare(strict_types=1);

require __DIR__ . '/../app/bootstrap.php';

// Page Noorwan Connect (v5) : le compte unique du groupe expliqué aux particuliers et aux professionnels,
// d'après la maquette « parcours » de Maestro (14/11/2026), en version site. Servie à l'adresse /connect.
// Illustrations dessinées (assets/img/connect-*.svg), aucune capture réelle de compte.
// Seule page du site qui mène au Compte Noorwan : « Créer mon compte » et « J'ai déjà un compte » y conduisent
// et disparaissent tant qu'il n'est pas en service (account_url()).
// Partenaires : « bientôt », sans date.
current_page('connect');
$meta = ['title' => raw('meta.connect_title'), 'description' => raw('meta.connect_description')];

$accountUrl = account_url();

/**
 * Section d'explication : petit titre, titre, texte, illustration, puis trois points.
 */
$block = static function (string $id, string $class, string $key, string $image, string $pointsKey, string $listClass = 'connect-points'): void {
    ?>
<section id="<?= e($id) ?>" class="screen <?= e($class) ?>" aria-labelledby="<?= e($id) ?>-title">
    <div class="wrap">
        <p class="eyebrow"><?= t('connect.' . $key . '_tag') ?></p>
        <h2 id="<?= e($id) ?>-title" class="h2 h2-section"><?= t('connect.' . $key . '_h') ?></h2>
        <p class="lead"><?= t('connect.' . $key . '_text') ?></p>
        <div class="connect-visual"><?= illustration($image, 'illus', 320, 220, ['loading' => 'lazy', 'decoding' => 'async']) ?></div>
        <ol class="<?= e($listClass) ?>">
<?php foreach (tl('connect.' . $pointsKey) as $i => $point): ?>
            <li>
                <span class="connect-num" aria-hidden="true">0<?= $i + 1 ?></span>
                <strong><?= e($point['title']) ?></strong>
                <span class="connect-point-text"><?= e($point['text']) ?></span>
            </li>
<?php endforeach; ?>
        </ol>
<?php if ($key === 'pro'): ?>
        <p class="connect-note"><?= t('connect.pro_note') ?></p>
<?php endif; ?>
    </div>
</section>
<?php
};

require ROOT_DIR . '/app/layout/header.php';
?>
<!-- TEXTES PROPOSES PAR MAESTRO, A VALIDER PAR MARWAN -->
<section class="page-hero connect-hero" aria-labelledby="page-title">
    <div class="wrap">
        <p class="eyebrow eyebrow-connect"><?= t('connect.tag') ?></p>
        <h1 id="page-title" class="h1 h1-page"><?= t('connect.title') ?></h1>
        <p class="lead"><?= t('connect.lead') ?></p>
<?php if ($accountUrl !== null): ?>
        <p class="links"><a class="btn btn-blue connect-create" href="<?= e($accountUrl) ?>"><?= t('connect.btn_create') ?> <span aria-hidden="true"><?= t('common.arrow') ?></span></a></p>
        <p class="connect-already"><a href="<?= e($accountUrl) ?>"><?= t('connect.already') ?></a></p>
<?php endif; ?>
    </div>
    <div class="hero-visual connect-hero-visual"><?= illustration('connect-hero', 'illus', 640, 400, ['decoding' => 'async']) ?></div>
</section>

<?php
$block('particuliers', 'connect-section', 'personal', 'connect-personal', 'personal_points');
$block('professionnels', 'screen-mist connect-section', 'pro', 'connect-pro', 'pro_points');
$block('sans-mot-de-passe', 'screen-dark connect-section', 'phone', 'connect-code', 'phone_steps', 'connect-points connect-steps');
$block('donnees', 'connect-section', 'data', 'connect-data', 'data_points');
?>

<section id="partenaires" class="screen screen-mist connect-section" aria-labelledby="partenaires-title">
    <div class="wrap">
        <p class="badge-soon"><?= t('connect.partner_tag') ?></p>
        <h2 id="partenaires-title" class="h2 h2-section"><?= t('connect.partner_h') ?></h2>
        <p class="lead"><?= t('connect.partner_text') ?></p>
        <div class="connect-visual"><?= illustration('connect-partner', 'illus', 320, 220, ['loading' => 'lazy', 'decoding' => 'async']) ?></div>
        <p class="links"><a class="more" href="<?= e(url('contact', '', ['universe' => 'solutions'])) ?>"><?= t('connect.partner_btn') ?></a></p>
    </div>
</section>

<?php if ($accountUrl !== null): ?>
<section id="creer" class="screen connect-final" aria-labelledby="creer-title">
    <div class="wrap">
        <h2 id="creer-title" class="h2 h2-section"><?= t('connect.final_h') ?></h2>
        <p class="lead"><?= t('connect.final_text') ?></p>
        <p class="links"><a class="btn btn-blue connect-create" href="<?= e($accountUrl) ?>"><?= t('connect.btn_create') ?> <span aria-hidden="true"><?= t('common.arrow') ?></span></a></p>
    </div>
</section>
<?php endif; ?>

<?php
require ROOT_DIR . '/app/layout/footer.php';
