<?php

declare(strict_types=1);

// Barre « Installer l'application Noorwan » (M-132, modèle Reserva) : installer noorwan.com depuis le navigateur, sans
// magasin. Barre discrète en bas de l'écran, sans voile, jamais une fenêtre surgissante, jamais en même temps que le
// bandeau des cookies (les cookies d'abord, elle vient après le choix). Cachée (attribut hidden) : sans JavaScript, elle
// ne paraît jamais. site.js choisit sa forme :
// - Android (le navigateur a proposé l'installation, beforeinstallprompt) : « Installer » ouvre sa petite fenêtre ;
// - iPhone et iPad (Safari) : mode d'emploi « Partager, puis Sur l'écran d'accueil », dessins faits ici, sans marque.
// Elle s'ouvre d'elle-même sur un téléphone seulement si data-auto vaut 1 (install_auto() : accueil, ?via=qr,
// ?via=launcher, à chaque visite) ; « Installer l'application » du volet du menu l'ouvre aussi. « Plus tard » la ferme
// pour la page en cours seulement, sans cookie. Rien en mode application ni dans l'application Android.
if (!install_available()) {
    return;
}
?>
<section id="install-bar" class="install-bar" aria-labelledby="install-bar-title" data-auto="<?= install_auto() ? '1' : '0' ?>" hidden>
    <div class="install-inner">
        <img class="install-icon" src="<?= e($asset('images/icons/icon-192.png')) ?>" alt="" width="44" height="44">
        <div class="install-body">
            <p id="install-bar-title" class="install-title"><?= t('install.title') ?></p>
            <p class="install-text" data-install-for="android"><?= t('install.text') ?></p>
            <ol class="install-steps" data-install-for="ios">
                <li>
                    <svg class="install-glyph" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="M8.5 9.5H7a2 2 0 0 0-2 2v7a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-7a2 2 0 0 0-2-2h-1.5"/><path d="M12 14.5V3.5"/><path d="M8.5 7 12 3.5 15.5 7"/></svg>
                    <span><?= t('install.ios_share') ?></span>
                </li>
                <li>
                    <svg class="install-glyph" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><rect x="4" y="4" width="16" height="16" rx="4"/><path d="M12 8.5v7M8.5 12h7"/></svg>
                    <span><?= t('install.ios_home') ?></span>
                </li>
            </ol>
        </div>
        <div class="install-actions">
            <button class="btn btn-dark btn-install" type="button" data-install-for="android" data-install-now><?= t('install.now') ?></button>
            <button class="btn btn-outline btn-install" type="button" data-install-later><?= t('install.later') ?></button>
        </div>
    </div>
</section>
