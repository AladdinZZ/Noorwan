<?php

declare(strict_types=1);

// Ligne « Écosystème Noorwan » du pied de page (D63, charte commune M-120) : liens vers les autres sites du groupe
// (ecosystem_sites(), adresses de .env). Le site courant n'y figure pas ; sans autre site, la ligne disparaît.
$ecosystemSites = ecosystem_sites();
if ($ecosystemSites === []) {
    return;
}
?>
        <nav class="ecosystem" aria-label="<?= t('ecosystem.title') ?>">
            <p class="footer-h"><?= t('ecosystem.title') ?></p>
            <ul>
<?php foreach ($ecosystemSites as $label => $siteUrl): ?>
                <li><a href="<?= e($siteUrl) ?>" rel="noopener" dir="auto"><?= t($label) ?></a></li>
<?php endforeach; ?>
            </ul>
        </nav>
