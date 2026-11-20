<?php

declare(strict_types=1);

// Grille des produits de la page Solutions : un écran par produit (Reserva, Noorwan Connect, Noor), puis la ligne « Bientôt ».
// Chaînes : home.products (catégorie, nom, texte, confidentiel) et home.soon. Aucun produit confidentiel hors liste (vérifié par tests/run.sh).
// v6 : Inteek n'y figure pas (sa présentation détaillée est sur la même page) ; Noorwan Édition non plus,
// l'Édition étant présentée dans la page Consulting (« Accompagnement et édition »).
// Lien de chaque carte : sa présentation détaillée quand elle existe, sinon le formulaire (univers Solutions).
// Noorwan Connect (produit de Solutions depuis le 20/11/2026) : sa page /connect.
$productLinks = [
    'reserva' => ['label' => 'solutions.btn_demo', 'href' => url('contact', '', ['universe' => 'solutions'])],
    'connect' => ['label' => 'common.learn_more', 'href' => url('connect')],
    'noor' => ['label' => 'solutions.btn_demo', 'href' => url('contact', '', ['universe' => 'solutions'])],
];
// Texte repris d'une autre page plutôt que recopié : l'introduction de /connect pour Noorwan Connect.
$productTextKeys = ['connect' => 'connect.lead'];
// Catégorie encore à fournir par Marwan (catégorie vide dans home.products) : « [À FOURNIR : …] » surligné.
$productCatTodos = ['connect' => 'solutions.connect_cat'];
// Ton de chaque carte : clair pour les produits en service, sombre pour les autres (comme la maquette A).
// Illustration de chaque carte : assets/img/<produit>.svg, décorative (alt vide), abstraite pour les produits confidentiels ;
// Noorwan Connect reprend l'illustration du haut de sa page (connect-hero), sans miroir en arabe comme sur sa page.
$productTones = ['reserva' => 'light', 'connect' => 'light', 'noor' => 'dark'];
$productVisuals = ['connect' => ['connect-hero', 640, 400]];
?>
<div class="products">
<?php foreach (array_intersect_key(tl('home.products'), $productLinks) as $productId => $product): ?>
    <article id="product-<?= e($productId) ?>" class="product product-<?= e($productTones[$productId]) ?> glyph-<?= e($productId) ?>" aria-labelledby="product-<?= e($productId) ?>-name">
        <p class="product-cat"><?= $product['cat'] === '' && isset($productCatTodos[$productId]) ? todo($productCatTodos[$productId]) : e($product['cat']) ?></p>
        <h3 id="product-<?= e($productId) ?>-name"><?= e($product['name']) ?></h3>
<?php if ($product['confidential']): ?>
        <p class="badge-confidential"><svg width="12" height="12" viewBox="0 0 12 12" aria-hidden="true" focusable="false"><rect x="2" y="5.5" width="8" height="5.5" rx="1.2" fill="none" stroke="currentColor" stroke-width="1.2"/><path d="M4 5.5V4a2 2 0 0 1 4 0v1.5" fill="none" stroke="currentColor" stroke-width="1.2"/></svg><?= t('home.confidential') ?></p>
        <p class="product-text"><?= t('solutions.on_request') ?></p>
<?php else: ?>
        <p class="product-text"><?= isset($productTextKeys[$productId]) ? t($productTextKeys[$productId]) : e($product['text']) ?></p>
<?php endif; ?>
        <p class="links"><a class="more" href="<?= e($productLinks[$productId]['href']) ?>"><?= t($productLinks[$productId]['label']) ?></a></p>
<?php [$visual, $visualWidth, $visualHeight] = $productVisuals[$productId] ?? [$productId, 360, 260]; ?>
        <div class="glyph"><?= illustration($visual, '', $visualWidth, $visualHeight, ['loading' => 'lazy', 'decoding' => 'async']) ?></div>
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
