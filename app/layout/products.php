<?php

declare(strict_types=1);

// Produits de la page Solutions, disposition A (décision de Marwan, 20/11/2026) : Inteek, Reserva, Noorwan Connect, Noor,
// l'un sous l'autre, une ligne chacun, même gabarit et même poids. Illustration puis texte dans le document : au-dessus du texte
// sur téléphone ; sur ordinateur, à gauche puis à droite en alternance (côté début puis côté fin, donc juste en arabe).
// Puis la ligne « Bientôt ». Chaînes : home.products (catégorie, nom, texte, confidentiel) et home.soon.
// Aucun produit confidentiel hors liste (vérifié par tests/run.sh). Noorwan Édition n'y figure pas,
// l'Édition étant présentée dans la page Consulting.
$contactSolutions = url('contact', '', ['universe' => 'solutions']);
// Une ligne par produit, dans l'ordre de la page :
//   link : « En savoir plus » vers sa page quand elle existe, sinon le formulaire (univers Solutions), ou rien (Inteek, détaillé ici) ;
//   text : clé du texte, reprise d'une autre page plutôt que recopiée (Inteek : son introduction ; Noorwan Connect : celle de /connect) ;
//   visual : illustration décorative (assets/img/<nom>.svg, alt vide), abstraite pour les produits confidentiels ;
//   mirror : retournée en arabe (Inteek, comme avant) ; Noorwan Connect reprend le haut de sa page, sans miroir comme sur sa page.
$productRows = [
    'inteek' => ['link' => null, 'text' => 'solutions.inteek_lead', 'visual' => ['inteek', 360, 260], 'mirror' => true],
    'reserva' => ['link' => ['solutions.btn_demo', $contactSolutions], 'text' => null, 'visual' => ['reserva', 360, 260], 'mirror' => false],
    'connect' => ['link' => ['common.learn_more', url('connect')], 'text' => 'connect.lead', 'visual' => ['connect-hero', 640, 400], 'mirror' => false],
    'noor' => ['link' => ['solutions.btn_demo', $contactSolutions], 'text' => null, 'visual' => ['noor', 360, 260], 'mirror' => false],
];
$products = tl('home.products');
?>
<div class="product-rows">
<?php foreach ($productRows as $productId => $row): ?>
<?php $product = $products[$productId]; [$visual, $visualWidth, $visualHeight] = $row['visual']; ?>
    <article id="product-<?= e($productId) ?>" class="product-row" aria-labelledby="product-<?= e($productId) ?>-name">
        <div class="product-row-visual<?= $row['mirror'] ? ' mirror-rtl' : '' ?>"><?= illustration($visual, '', $visualWidth, $visualHeight, ['loading' => 'lazy', 'decoding' => 'async']) ?></div>
        <div class="product-row-body">
            <p class="eyebrow eyebrow-sol product-cat"><?= e($product['cat']) ?></p>
            <h2 id="product-<?= e($productId) ?>-name" class="h2 product-name"><?= e($product['name']) ?></h2>
<?php if ($product['confidential']): ?>
            <p class="badge-confidential"><svg width="12" height="12" viewBox="0 0 12 12" aria-hidden="true" focusable="false"><rect x="2" y="5.5" width="8" height="5.5" rx="1.2" fill="none" stroke="currentColor" stroke-width="1.2"/><path d="M4 5.5V4a2 2 0 0 1 4 0v1.5" fill="none" stroke="currentColor" stroke-width="1.2"/></svg><?= t('home.confidential') ?></p>
            <p class="product-text"><?= t('solutions.on_request') ?></p>
<?php else: ?>
            <p class="product-text"><?= $row['text'] !== null ? t($row['text']) : e($product['text']) ?></p>
<?php endif; ?>
<?php if ($productId === 'inteek'): ?>
            <p class="inteek-text"><?= t('solutions.inteek_text') ?></p>
            <h3 class="modules-title"><?= t('solutions.modules_title') ?></h3>
            <ul class="modules">
<?php foreach (tl('solutions.modules') as $module): ?>
                <li><?= e($module) ?></li>
<?php endforeach; ?>
            </ul>
<?php endif; ?>
<?php if ($row['link'] !== null): ?>
            <p class="links"><a class="more" href="<?= e($row['link'][1]) ?>"><?= t($row['link'][0]) ?></a></p>
<?php endif; ?>
        </div>
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
