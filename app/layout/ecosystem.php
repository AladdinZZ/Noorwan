<?php

declare(strict_types=1);

// Écosystème Noorwan (D63), même bloc que sur Inteek : liens vers les autres sites du groupe.
// Adresses lues dans .env (ECOSYSTEM_*_URL) ; une entrée sans adresse est masquée ; le site courant
// (noorwan.com) est nommé sans lien. Jamais de projet confidentiel dans cette liste.
$ecosystemSites = [
    'noorwan' => ['label' => 'common.brand', 'url' => null],
    'account' => ['label' => 'ecosystem.account', 'url' => env('ECOSYSTEM_ACCOUNT_URL', '')],
    'reserva' => ['label' => 'ecosystem.reserva', 'url' => env('ECOSYSTEM_RESERVA_URL', '')],
    'inteek' => ['label' => 'ecosystem.inteek', 'url' => env('ECOSYSTEM_INTEEK_URL', '')],
];
$ecosystemSites = array_filter(
    $ecosystemSites,
    static fn (array $site, string $key): bool => $key === 'noorwan'
        || preg_match('#^https://[^\s"<>]+$#', (string) $site['url']) === 1,
    ARRAY_FILTER_USE_BOTH,
);
if (count($ecosystemSites) < 2) {
    return;
}
?>
        <nav class="ecosystem" aria-label="<?= t('ecosystem.title') ?>">
            <p class="footer-h"><?= t('ecosystem.title') ?></p>
            <ul>
<?php foreach ($ecosystemSites as $key => $site): ?>
<?php if ($key === 'noorwan'): ?>
                <li><span aria-current="page"><?= t($site['label']) ?></span></li>
<?php else: ?>
                <li><a href="<?= e($site['url']) ?>" rel="noopener" dir="auto"><?= t($site['label']) ?></a></li>
<?php endif; ?>
<?php endforeach; ?>
            </ul>
        </nav>
