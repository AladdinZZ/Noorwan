<?php

declare(strict_types=1);

// Bandeau « Un projet en tête ? » qui mène au formulaire. $ctaId : ancre de la section (facultative),
// $ctaParams : paramètres du lien (univers présélectionné), $ctaButton : clé du libellé du bouton (facultatifs).
?>
<section<?= isset($ctaId) ? ' id="' . e($ctaId) . '"' : '' ?> class="screen screen-mist cta" aria-labelledby="cta-title">
    <div class="wrap">
        <h2 id="cta-title" class="h2"><?= t('home.cta_h') ?></h2>
        <p class="lead"><?= t('home.cta_text') ?></p>
        <div class="links links-cta">
            <a class="btn btn-blue" href="<?= e(url('contact', '', $ctaParams ?? [])) ?>"><?= t($ctaButton ?? 'home.cta_btn') ?> <span aria-hidden="true"><?= t('common.arrow') ?></span></a>
        </div>
        <p class="cta-mail"><a href="mailto:<?= e(CONTACT_EMAIL) ?>" dir="ltr"><?= e(CONTACT_EMAIL) ?></a></p>
    </div>
</section>
