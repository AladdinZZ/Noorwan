<?php

declare(strict_types=1);

require __DIR__ . '/../app/bootstrap.php';
require ROOT_DIR . '/app/books.php';

// Page Édition : la prestation d'accompagnement des auteurs, puis le catalogue (deux collections et « Prochainement »).
current_page('edition');
$meta = ['title' => raw('meta.edition_title'), 'description' => raw('meta.edition_description')];

$contactEdition = url('contact', '', ['universe' => 'edition']);

// Rubriques du catalogue : les deux collections, puis « Prochainement » (livres annoncés, sans bouton « Acheter »).
$rubrics = [];
foreach (collections() as $collection) {
    $rubrics[$collection] = [
        'name' => raw('edition.collections.' . $collection . '.name'),
        'text' => raw('edition.collections.' . $collection . '.text'),
        'books' => books_in($collection),
    ];
}
$rubrics['upcoming'] = ['name' => raw('edition.upcoming'), 'text' => '', 'books' => books_in(null)];

require ROOT_DIR . '/app/layout/header.php';
?>
<section class="page-hero tone-edition" aria-labelledby="page-title">
    <div class="wrap">
        <p class="tag"><?= t('edition.tag') ?></p>
        <h1 id="page-title"><?= t('edition.title') ?></h1>
        <p class="page-lead"><?= t('edition.lead') ?></p>
        <div class="actions">
            <a class="btn btn-dark" href="<?= e($contactEdition) ?>"><?= t('edition.btn_publish') ?> <span aria-hidden="true"><?= t('common.arrow') ?></span></a>
            <a class="btn btn-text" href="#catalogue"><?= t('edition.btn_catalogue') ?></a>
        </div>
    </div>
</section>

<!-- A VALIDER PAR MARWAN : les quatre étapes de la prestation (textes dans lang/*.php, edition.service_*). -->
<section class="section tone-edition" aria-labelledby="service-title">
    <div class="wrap">
        <div class="split-head">
            <div>
                <p class="eyebrow"><?= t('edition.service_eyebrow') ?></p>
                <h2 id="service-title" class="h2"><?= t('edition.service_title') ?></h2>
            </div>
            <p><?= t('edition.service_lead') ?></p>
        </div>
        <ol class="cards cards-steps">
<?php foreach (tl('edition.service_steps') as $i => $step): ?>
            <li class="card">
                <span class="card-num">0<?= $i + 1 ?></span>
                <h3><?= e($step['title']) ?></h3>
                <p><?= e($step['text']) ?></p>
            </li>
<?php endforeach; ?>
        </ol>
    </div>
</section>

<section id="catalogue" class="section section-gray tone-edition" aria-labelledby="catalogue-title">
    <div class="wrap">
        <p class="eyebrow"><?= t('edition.catalogue_eyebrow') ?></p>
        <h2 id="catalogue-title" class="h2 section-title"><?= t('edition.catalogue_title') ?></h2>
<?php foreach ($rubrics as $rubricId => $rubric): ?>
<?php if ($rubric['books'] === []) { continue; } ?>
        <section class="collection" aria-labelledby="collection-<?= e($rubricId) ?>">
            <div class="collection-head">
                <h3 id="collection-<?= e($rubricId) ?>"><?= e($rubric['name']) ?></h3>
<?php if ($rubric['text'] !== ''): ?>
                <p class="muted"><?= e($rubric['text']) ?></p>
<?php endif; ?>
            </div>
            <div class="books">
<?php foreach ($rubric['books'] as $id => $book): ?>
                <article class="book" aria-labelledby="book-<?= e($id) ?>">
<?php if ($book['cover'] !== null): ?>
                    <img class="cover" src="assets/images/covers/<?= e($book['cover']) ?>" alt="<?= t('books.cover_alt', [':title' => book_title($book)]) ?>" width="<?= $book['cover_size'][0] ?>" height="<?= $book['cover_size'][1] ?>" loading="lazy" decoding="async">
<?php else: ?>
                    <div class="cover-soon" aria-hidden="true">
                        <span class="cover-soon-label"><?= t('books.soon') ?></span>
                        <span class="cover-soon-title"><bdi><?= e(book_title($book)) ?></bdi></span>
                    </div>
<?php endif; ?>
                    <div class="book-body">
<?php if ($book['status'] === 'upcoming'): ?>
                        <p class="book-flag"><?= t('books.soon') ?></p>
<?php elseif ($book['also_in_english']): ?>
                        <p class="book-flag"><?= t('edition.also_in_english') ?></p>
<?php endif; ?>
                        <h4 id="book-<?= e($id) ?>"><bdi><?= e(book_title($book)) ?></bdi></h4>
                        <p class="book-sub"><?= t('books.items.' . $id . '.sub') ?></p>
<?php if ($book['status'] === 'writing'): ?>
                        <p class="book-status"><?= t('books.soon') ?> · <?= t('edition.writing') ?></p>
<?php else: ?>
                        <p class="book-lead"><?= t('books.items.' . $id . '.lead') ?></p>
                        <p class="book-summary"><?= t('books.items.' . $id . '.summary') ?></p>
<?php endif; ?>
<?php if ($book['status'] === 'published'): ?>
                        <a class="btn btn-dark book-buy" href="<?= e(amazon_url($book)) ?>" rel="noopener" aria-label="<?= t('edition.buy_label', [':title' => book_title($book)]) ?>"><?= t('edition.buy') ?> <span aria-hidden="true"><?= t('common.arrow_up') ?></span></a>
<?php endif; ?>
                    </div>
                </article>
<?php endforeach; ?>
            </div>
        </section>
<?php endforeach; ?>
    </div>
</section>

<?php
$ctaParams = ['universe' => 'edition'];
require ROOT_DIR . '/app/layout/cta.php';
require ROOT_DIR . '/app/layout/footer.php';
