<?php

declare(strict_types=1);

// Photo de « Parlons de votre projet » (v7) : réunion de trois personnes, en tête de la page Contact et dans le bandeau de contact.
// WebP en deux largeurs (600 et 1200 px), choisies par le navigateur. $photoLazy (facultatif) : false en tête de page.
?>
        <div class="cta-visual"><img class="photo" src="assets/img/contact-reunion-600.webp" srcset="assets/img/contact-reunion-600.webp 600w, assets/img/contact-reunion-1200.webp 1200w" sizes="(min-width: 600px) 520px, calc(100vw - 48px)" alt="<?= t('contact.photo_alt') ?>" width="1200" height="800"<?= ($photoLazy ?? true) ? ' loading="lazy"' : '' ?> decoding="async"></div>
