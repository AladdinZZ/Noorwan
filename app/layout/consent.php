<?php

declare(strict_types=1);

// Choix de cookies commun à tous les sites Noorwan (M-129, règle charte-commune/consentement.md), seulement si Tag
// Manager est réglé (sans conteneur, il n'y a rien à accepter : ni bandeau ni volet).
// - Bandeau en bas, sans voile, tant que la personne n'a pas choisi : texte commun, « Tout accepter » et « Tout refuser »
//   de même forme, lien « Choisir » dessous qui ouvre le volet.
// - Volet #consent-panel de fin de ligne : deux interrupteurs (mesure d'audience, publicité) réglés sur le choix actuel,
//   « Enregistrer ». « Gérer les cookies » (pied de page, page Cookies) le rouvre.
// Sans JavaScript, les formulaires vont à consent.php et le volet s'ouvre par son ancre.
if (GTM_ID === '') {
    return;
}
$consentBack = url(current_page());
$consentChoice = consent_choice();
$consentAction = 'consent.php?' . http_build_query(['lang' => lang()]);
?>
<?php if ($consentChoice === null): ?>
<section id="consent" class="consent" aria-label="<?= t('consent.title') ?>">
    <form class="consent-inner" method="post" action="<?= e($consentAction) ?>" data-consent-form>
        <input type="hidden" name="token" value="<?= e(Csrf::token('consent')) ?>">
        <input type="hidden" name="back" value="<?= e($consentBack) ?>">
        <p class="consent-text"><?= t('consent.text') ?> <a href="<?= e(url('confidentialite')) ?>"><?= t('consent.more') ?></a></p>
        <div class="consent-actions">
            <button class="btn btn-outline btn-consent" type="submit" name="choice" value="all"><?= t('consent.accept_all') ?></button>
            <button class="btn btn-outline btn-consent" type="submit" name="choice" value="none"><?= t('consent.refuse_all') ?></button>
            <a class="consent-choose" href="#consent-panel" aria-controls="consent-panel" aria-expanded="false" data-panel-open><?= t('consent.choose') ?></a>
        </div>
    </form>
</section>
<?php endif; ?>
<div id="consent-panel" class="panel-layer panel-end" data-panel data-analytics="<?= ($consentChoice['analytics'] ?? false) ? '1' : '0' ?>" data-ads="<?= ($consentChoice['ads'] ?? false) ? '1' : '0' ?>">
    <a class="panel-scrim" href="#" tabindex="-1" aria-hidden="true" data-panel-close></a>
    <section class="panel" role="dialog" aria-modal="true" aria-labelledby="consent-panel-title">
        <div class="panel-head">
            <h2 id="consent-panel-title" class="panel-title"><?= t('consent.panel_title') ?></h2>
            <a class="panel-close" href="#" data-panel-close><span class="visually-hidden"><?= t('nav.close') ?></span><?= $closeIcon ?></a>
        </div>
        <form id="consent-choice" class="panel-body consent-choice" method="post" action="<?= e($consentAction) ?>" data-consent-form>
            <input type="hidden" name="token" value="<?= e(Csrf::token('consent')) ?>">
            <input type="hidden" name="back" value="<?= e($consentBack) ?>">
            <input type="hidden" name="choice" value="custom">
            <p class="panel-text"><?= t('consent.panel_lead') ?></p>
<?php foreach (['analytics', 'ads'] as $consentKind): ?>
            <label class="consent-switch">
                <span class="consent-switch-text">
                    <span class="consent-switch-name"><?= t('consent.' . $consentKind) ?></span>
                    <span class="consent-switch-hint"><?= t('consent.' . $consentKind . '_hint') ?></span>
                </span>
                <input class="switch" type="checkbox" role="switch" name="<?= $consentKind ?>" value="1"<?= ($consentChoice[$consentKind] ?? false) ? ' checked' : '' ?>>
            </label>
<?php endforeach; ?>
            <p><a class="more" href="<?= e(url('confidentialite')) ?>"><?= t('consent.more') ?></a></p>
        </form>
        <div class="panel-foot">
            <button class="btn btn-dark btn-block" type="submit" form="consent-choice"><?= t('consent.save') ?></button>
        </div>
    </section>
</div>
