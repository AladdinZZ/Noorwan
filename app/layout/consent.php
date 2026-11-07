<?php

declare(strict_types=1);

// Bandeau de consentement à la mesure d'audience (M-59), en bas de page, seulement si Tag Manager est réglé.
// Ouvert tant que la personne n'a pas choisi ; « Gérer les cookies » (pied de page) le rouvre.
if (GTM_ID === '') {
    return;
}
$consentBack = url(current_page());
?>
<section id="consent" class="consent" aria-labelledby="consent-title"<?= consent_state() !== null ? ' hidden' : '' ?> data-state="<?= e(consent_state() ?? '') ?>">
    <div class="consent-inner">
        <div class="consent-body">
            <h2 id="consent-title" class="consent-title"><?= t('consent.title') ?></h2>
            <p class="consent-text"><?= t('consent.text') ?> <a href="<?= e(url('cookies')) ?>"><?= t('consent.more') ?></a></p>
        </div>
<?php require ROOT_DIR . '/app/layout/consent-form.php'; ?>
    </div>
</section>
