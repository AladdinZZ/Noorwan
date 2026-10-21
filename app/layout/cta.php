<?php

declare(strict_types=1);

// Bandeau « Un projet en tête ? » qui mène au formulaire. $ctaId : ancre de la section (facultative).
?>
<section<?= isset($ctaId) ? ' id="' . e($ctaId) . '"' : '' ?> class="cta" aria-labelledby="cta-title">
    <div class="wrap cta-panel">
        <div>
            <p class="eyebrow">Noorwan</p>
            <h2 id="cta-title" class="h2"><?= t('home.cta_h') ?></h2>
            <p class="muted"><?= t('home.cta_text') ?></p>
        </div>
        <a class="btn btn-blue" href="<?= e(url('contact', '', $ctaParams ?? [])) ?>"><?= t('home.cta_btn') ?> <span aria-hidden="true"><?= t('common.arrow') ?></span></a>
    </div>
</section>
