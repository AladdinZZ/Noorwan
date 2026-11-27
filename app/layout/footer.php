<?php

declare(strict_types=1);

// Pied de page commun (charte commune M-120) : logo et phrase du site, quatre colonnes (Consulting, Solutions, Édition,
// Noorwan ; deux par ligne au téléphone), ligne légale. Plus de ligne « Écosystème Noorwan » : le lanceur des sites de
// l'en-tête la remplace (M-121).
// La colonne Édition garde la page Édition, sortie du menu en v6. Connect (page /connect) est dans la colonne Noorwan.
// Pas de « Powered by Noorwan » : noorwan.com est le site du groupe, pas un produit.
$footerColumns = [
    'nav.consulting' => [
        ['label' => 'home.btn_explore', 'href' => url('consulting', 'expertises')],
        ['label' => 'home.btn_talk', 'href' => url('contact', '', ['universe' => 'consulting'])],
    ],
    'nav.solutions' => [
        ['label' => 'home.sol_btn', 'href' => url('solutions')],
        ['label' => 'solutions.btn_demo', 'href' => url('contact', '', ['universe' => 'solutions'])],
    ],
    'nav.edition' => [
        ['label' => 'home.ed_btn_catalogue', 'href' => url('edition', 'catalogue')],
        ['label' => 'home.ed_btn', 'href' => url('contact', '', ['universe' => 'edition'])],
    ],
    'common.brand' => [
        ['label' => 'nav.connect', 'href' => url('connect')],
        ['label' => 'nav.contact', 'href' => url('contact')],
    ],
];
?>
</main>
<footer class="site-footer">
    <div class="wrap">
        <div class="footer-brand">
            <a class="logo" href="<?= e(url('index')) ?>" aria-label="<?= t('nav.home_label') ?>" dir="ltr">noorwan<span class="logo-dot">.</span></a>
            <p class="footer-tagline"><?= t('common.foot_line') ?></p>
        </div>
        <nav class="footer-cols" aria-label="<?= t('nav.footer_label') ?>">
<?php foreach ($footerColumns as $heading => $links): ?>
            <div>
                <p class="footer-h"><?= t($heading) ?></p>
                <ul>
<?php foreach ($links as $link): ?>
                    <li><a href="<?= e($link['href']) ?>"><?= t($link['label']) ?></a></li>
<?php endforeach; ?>
                </ul>
            </div>
<?php endforeach; ?>
        </nav>
        <div class="footer-bottom">
            <p class="footer-copy" dir="ltr"><?= t('common.copy', [':year' => date('Y')]) ?></p>
            <div class="footer-legal">
                <a href="<?= e(url('mentions-legales')) ?>"><?= t('legal_nav.mentions') ?></a>
                <a href="<?= e(url('confidentialite')) ?>"><?= t('legal_nav.privacy') ?></a>
                <a href="<?= e(url('cookies')) ?>"><?= t('legal_nav.cookies') ?></a>
<?php if (GTM_ID !== ''): ?>
                <a href="#consent-panel" aria-controls="consent-panel" aria-expanded="false" data-panel-open><?= t('consent.manage') ?></a>
<?php endif; ?>
            </div>
        </div>
    </div>
</footer>
<?php require ROOT_DIR . '/app/layout/consent.php'; ?>
<?php require ROOT_DIR . '/app/layout/install.php'; ?>
</body>
</html>
