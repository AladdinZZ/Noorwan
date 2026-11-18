<?php

declare(strict_types=1);

require __DIR__ . '/../app/bootstrap.php';
require ROOT_DIR . '/app/books.php';

// Page Consulting (v6), servie à l'adresse /consulting : reprend la section Consulting de l'ancien accueil
// (titre, introduction, cinq expertises), puis « Accompagnement et édition » : l'Édition n'est plus un onglet,
// elle est présentée ici comme une forme d'accompagnement, les livres en bref, avec un lien vers la page Édition.
// Aucun texte inventé : accompagnement à l'écriture (consulting.writing) validé par Marwan en v8.
current_page('consulting');
$meta = ['title' => raw('meta.consulting_title'), 'description' => raw('home.univers.consulting.text')];

$trilogy = books_in('metaphysique');
$chemins = array_map('book_title', books_in('chemins'));

require ROOT_DIR . '/app/layout/header.php';
?>
<!-- TEXTES A VALIDER PAR MARWAN -->
<section class="page-hero consulting-hero tone-consulting" aria-labelledby="page-title">
    <div class="wrap">
        <p class="eyebrow"><?= t('consulting.tag') ?></p>
        <h1 id="page-title" class="h1 h1-page"><?= t('home.cons_app_h') ?></h1>
        <p class="lead"><?= t('home.cons_lead') ?></p>
        <p class="links"><a class="btn btn-dark" href="<?= e(url('contact', '', ['universe' => 'consulting'])) ?>"><?= t('home.btn_talk') ?> <span aria-hidden="true"><?= t('common.arrow') ?></span></a></p>
    </div>
    <div class="shape"><img class="illus" src="assets/img/universe-consulting.svg" alt="" width="760" height="380" decoding="async"></div>
</section>

<section id="expertises" class="section section-mist tone-consulting" aria-labelledby="expertises-title">
    <div class="wrap">
        <h2 id="expertises-title" class="h2 h2-section section-title"><?= t('consulting.expertises_title') ?></h2>
        <ul class="expertises">
<?php foreach (tl('home.expertises') as $expertise): ?>
            <li><strong><?= e($expertise['title']) ?></strong> <span><?= e($expertise['text']) ?></span></li>
<?php endforeach; ?>
        </ul>
        <p class="universe-note"><?= t('home.cons_app') ?></p>
    </div>
</section>

<section id="accompagnement" class="screen tone-edition" aria-labelledby="accompagnement-title">
    <div class="wrap">
        <p class="eyebrow"><?= t('consulting.accomp_tag') ?></p>
        <h2 id="accompagnement-title" class="h2 h2-section"><?= t('home.ed_h') ?></h2>
        <p class="lead"><?= e(tl('home.univers')['edition']['text']) ?></p>
        <p class="accomp-writing"><?= t('consulting.writing') ?></p>
        <ul class="shelf">
<?php foreach ($trilogy as $book): ?>
            <li>
<?php if ($book['cover'] !== null): ?>
                <img class="cover" src="assets/images/covers/<?= e($book['cover']) ?>" alt="<?= t('books.cover_alt', [':title' => book_title($book)]) ?>" width="<?= $book['cover_size'][0] ?>" height="<?= $book['cover_size'][1] ?>" loading="lazy" decoding="async">
<?php else: ?>
                <span class="cover-soon"><span class="cover-soon-label"><?= t('books.soon') ?></span><span class="cover-soon-title"><bdi><?= e(book_title($book)) ?></bdi></span></span>
<?php endif; ?>
            </li>
<?php endforeach; ?>
        </ul>
        <p class="shelf-caption"><?= t('edition.collections.metaphysique.name') ?><?= t('common.colon') ?><?= t('home.author_line') ?></p>
        <p class="shelf-caption"><?= t('edition.collections.chemins.name') ?><?= t('common.colon') ?><bdi><?= e(implode(raw('common.list_sep'), $chemins)) ?></bdi></p>
        <p class="links">
            <a class="more" href="<?= e(url('edition')) ?>"><?= t('common.learn_more') ?></a>
            <a class="more" href="<?= e(url('contact', '', ['universe' => 'edition'])) ?>"><?= t('home.ed_btn') ?></a>
        </p>
    </div>
</section>

<?php
$ctaParams = ['universe' => 'consulting'];
require ROOT_DIR . '/app/layout/cta.php';
require ROOT_DIR . '/app/layout/footer.php';
