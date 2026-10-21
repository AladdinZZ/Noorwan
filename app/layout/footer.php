<?php

declare(strict_types=1);

// Pied de page commun : logo, navigation reprise de l'en-tête ($navItems), liens légaux.
?>
</main>
<footer class="site-footer">
    <div class="wrap">
        <div class="footer-top">
            <div class="footer-brand">
                <span class="logo" dir="ltr">noorwan<span class="logo-dot">.</span></span>
                <span class="footer-line"><?= t('common.foot_line') ?></span>
            </div>
            <nav class="footer-nav" aria-label="<?= t('nav.footer_label') ?>">
<?php foreach ($navItems as $item): ?>
                <a href="<?= e($item['href']) ?>"><?= t($item['label']) ?></a>
<?php endforeach; ?>
            </nav>
        </div>
        <div class="footer-bottom">
            <span><?= t('common.copy', [':year' => date('Y')]) ?></span>
            <div class="footer-legal">
                <a href="<?= e(url('mentions-legales')) ?>"><?= t('legal_nav.mentions') ?></a>
                <a href="<?= e(url('confidentialite')) ?>"><?= t('legal_nav.privacy') ?></a>
                <a href="<?= e(url('cookies')) ?>"><?= t('legal_nav.cookies') ?></a>
            </div>
        </div>
    </div>
</footer>
</body>
</html>
