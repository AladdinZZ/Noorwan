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

// « Gérer vos choix » : choix actuel, et le bouton qui ouvre le volet « Choisir » (par son ancre sans JavaScript).
if (GTM_ID !== ''):
    $manageChoice = consent_choice();
?>
<section id="consent-manage" class="section section-legal" aria-labelledby="consent-manage-title">
    <div class="wrap">
        <div class="legal consent-manage">
            <h2 id="consent-manage-title"><?= t('consent.manage_title') ?></h2>
<?php if ($manageChoice === null): ?>
            <p><?= t('consent.state_none') ?></p>
<?php else: ?>
            <ul>
                <li><?= t('consent.state_line', [':name' => raw('consent.analytics'), ':state' => raw('consent.' . ($manageChoice['analytics'] ? 'state_on' : 'state_off'))]) ?></li>
                <li><?= t('consent.state_line', [':name' => raw('consent.ads'), ':state' => raw('consent.' . ($manageChoice['ads'] ? 'state_on' : 'state_off'))]) ?></li>
            </ul>
<?php endif; ?>
            <p><a class="btn btn-outline consent-manage-open" href="#consent-panel" aria-controls="consent-panel" aria-expanded="false" data-panel-open><?= t('consent.manage') ?></a></p>
        </div>
    </div>
</section>
<?php
endif;
require ROOT_DIR . '/app/layout/footer.php';
