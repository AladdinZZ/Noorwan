<?php

declare(strict_types=1);

// Boutons « Refuser » et « Accepter », de même poids, envoyés à consent.php (marche aussi sans JavaScript).
// $consentBack : page où revenir après le choix (lien relatif du site).
?>
<form class="consent-actions" method="post" action="consent.php?<?= e(http_build_query(['lang' => lang()])) ?>">
    <input type="hidden" name="token" value="<?= e(Csrf::token('consent')) ?>">
    <input type="hidden" name="back" value="<?= e($consentBack) ?>">
    <button class="btn btn-consent" type="submit" name="choice" value="denied"><?= t('consent.refuse') ?></button>
    <button class="btn btn-consent" type="submit" name="choice" value="granted"><?= t('consent.accept') ?></button>
</form>
