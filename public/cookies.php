<?php

declare(strict_types=1);

require __DIR__ . '/../app/bootstrap.php';

// Page légale rédigée sur la base du RGPD. Textes dans lang/*.php (legal.cookies).
current_page('cookies');
$meta = ['title' => raw('meta.cookies_title'), 'description' => raw('meta.cookies_description')];
$legalKey = 'cookies';

require ROOT_DIR . '/app/layout/header.php';
?>
<!-- A FAIRE RELIRE PAR UN JURISTE -->
<?php
require ROOT_DIR . '/app/layout/legal.php';

// « Gérer vos choix » : état actuel et mêmes boutons que le bandeau, utilisables sans JavaScript.
if (GTM_ID !== ''):
    $consentBack = url('cookies');
?>
<section id="consent-manage" class="section section-legal" aria-labelledby="consent-manage-title">
    <div class="wrap">
        <div class="legal consent-manage">
            <h2 id="consent-manage-title"><?= t('consent.manage_title') ?></h2>
            <p><?= t('consent.state_' . (consent_state() ?? 'none')) ?></p>
<?php require ROOT_DIR . '/app/layout/consent-form.php'; ?>
        </div>
    </div>
</section>
<?php
endif;
require ROOT_DIR . '/app/layout/footer.php';
