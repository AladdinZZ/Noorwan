<?php

declare(strict_types=1);

// Grille des produits de Solutions (accueil et page Solutions) : un écran par produit, puis la ligne « Bientôt ».
// Chaînes : home.products (catégorie, nom, texte, confidentiel) et home.soon. Aucun produit confidentiel hors liste (vérifié par tests/run.sh).
// Lien de chaque carte : sa présentation détaillée quand elle existe, sinon le formulaire (univers Solutions).
$productLinks = [
    'reserva' => ['label' => 'solutions.btn_demo', 'href' => url('contact', '', ['universe' => 'solutions'])],
    'inteek' => ['label' => 'common.learn_more', 'href' => url('solutions', 'inteek')],
    'noor' => ['label' => 'solutions.btn_demo', 'href' => url('contact', '', ['universe' => 'solutions'])],
    'edition' => ['label' => 'common.learn_more', 'href' => url('edition')],
];
// Ton de chaque carte : clair pour les produits en service, sombre pour les autres (comme la maquette A).
$productTones = ['reserva' => 'light', 'inteek' => 'light', 'noor' => 'dark', 'edition' => 'dark'];
?>
<div class="products">
<?php foreach (tl('home.products') as $productId => $product): ?>
    <article id="product-<?= e($productId) ?>" class="product product-<?= e($productTones[$productId]) ?> glyph-<?= e($productId) ?>" aria-labelledby="product-<?= e($productId) ?>-name">
        <p class="product-cat"><?= e($product['cat']) ?></p>
        <h3 id="product-<?= e($productId) ?>-name"><?= e($product['name']) ?></h3>
<?php if ($product['confidential']): ?>
        <p class="badge-confidential"><svg width="12" height="12" viewBox="0 0 12 12" aria-hidden="true" focusable="false"><rect x="2" y="5.5" width="8" height="5.5" rx="1.2" fill="none" stroke="currentColor" stroke-width="1.2"/><path d="M4 5.5V4a2 2 0 0 1 4 0v1.5" fill="none" stroke="currentColor" stroke-width="1.2"/></svg><?= t('home.confidential') ?></p>
        <p class="product-text"><?= t('solutions.on_request') ?></p>
<?php else: ?>
        <p class="product-text"><?= e($product['text']) ?></p>
<?php endif; ?>
        <p class="links"><a class="more" href="<?= e($productLinks[$productId]['href']) ?>"><?= t($productLinks[$productId]['label']) ?></a></p>
        <div class="glyph" aria-hidden="true"></div>
    </article>
<?php endforeach; ?>
</div>
<div class="soon-row">
    <p class="soon-label"><?= t('home.soon_label') ?></p>
    <ul>
<?php foreach (tl('home.soon') as $name): ?>
        <li><?= e($name) ?></li>
<?php endforeach; ?>
    </ul>
</div>
