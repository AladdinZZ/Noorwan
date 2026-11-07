<?php

declare(strict_types=1);

// Pied de page commun : quatre colonnes (Consulting, Solutions, Édition, Noorwan), Écosystème Noorwan, ligne légale.
// « Connexion » rejoint la colonne Noorwan quand le Compte Noorwan est en service ($accountUrl, de l'en-tête).
$footerColumns = [
    'nav.consulting' => [
        ['label' => 'home.btn_explore', 'href' => url('index', 'consulting')],
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
        ['label' => 'nav.contact', 'href' => url('contact')],
    ],
];
if ($accountUrl !== null) {
    $footerColumns['common.brand'][] = ['label' => 'nav.account', 'href' => $accountUrl, 'class' => 'nav-account'];
}
?>
</main>
<footer class="site-footer">
    <div class="wrap">
        <nav class="footer-cols" aria-label="<?= t('nav.footer_label') ?>">
<?php foreach ($footerColumns as $heading => $links): ?>
            <div>
                <p class="footer-h"><?= t($heading) ?></p>
                <ul>
<?php foreach ($links as $link): ?>
                    <li><a href="<?= e($link['href']) ?>"<?= isset($link['class']) ? ' class="' . e($link['class']) . '"' : '' ?>><?= t($link['label']) ?></a></li>
<?php endforeach; ?>
                </ul>
            </div>
<?php endforeach; ?>
        </nav>
<?php require ROOT_DIR . '/app/layout/ecosystem.php'; ?>
        <div class="footer-bottom">
            <p class="footer-line"><span><?= t('common.foot_line') ?></span> <span dir="ltr"><?= t('common.copy', [':year' => date('Y')]) ?></span></p>
            <div class="footer-legal">
                <a href="<?= e(url('mentions-legales')) ?>"><?= t('legal_nav.mentions') ?></a>
                <a href="<?= e(url('confidentialite')) ?>"><?= t('legal_nav.privacy') ?></a>
                <a href="<?= e(url('cookies')) ?>"><?= t('legal_nav.cookies') ?></a>
<?php if (GTM_ID !== ''): ?>
                <a href="<?= e(url('cookies', 'consent-manage')) ?>" data-consent-open><?= t('consent.manage') ?></a>
<?php endif; ?>
            </div>
        </div>
    </div>
</footer>
<?php require ROOT_DIR . '/app/layout/consent.php'; ?>
</body>
</html>
