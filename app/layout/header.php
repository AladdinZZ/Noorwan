<?php

declare(strict_types=1);

// En-tête commun (charte commune M-118, M-120) : <head>, barre fixe de 48 px (Menu, logo, liens principaux dès 900 px,
// langue, thème, lanceur des sites, « Connexion »), puis les volets : le menu en début de ligne, le lanceur des sites
// (M-121 : volet plein écran au téléphone, panneau sous l'en-tête dès 640 px) et la connexion en fin de ligne.
// Sans JavaScript, chaque volet s'ouvre par son ancre (:target) et se ferme par « # » ; site.js y ajoute Échap,
// le voile, le retour arrière et le focus. Jamais de fenêtre surgissante.
// Attend $meta = ['title' => ..., 'description' => ...] (chaînes brutes, échappées ici).

$navItems = [
    ['page' => 'consulting', 'label' => 'nav.consulting', 'href' => url('consulting')],
    ['page' => 'solutions', 'label' => 'nav.solutions', 'href' => url('solutions')],
    ['page' => 'contact', 'label' => 'nav.contact', 'href' => url('contact')],
];
// Volet du menu : toutes les rubriques du site, Accueil et Édition comprises (maquette « noorwan-menu », 24/11/2026).
$panelItems = array_merge(
    [['page' => 'index', 'label' => 'nav.home', 'href' => url('index')]],
    array_slice($navItems, 0, 2),
    [['page' => 'edition', 'label' => 'nav.edition', 'href' => url('edition')]],
    array_slice($navItems, 2),
);
// Onglet de la page affichée : aria-current="page", mis en avant par la feuille de style (v7).
$navCurrent = static fn (array $item): string => $item['page'] === current_page() ? ' aria-current="page"' : '';
// Le site ne gère aucun compte : « Continuer avec Noorwan » mène au Compte (Connect) seulement quand il est en service
// (account_url(), COMPTE_LINK_ENABLED), dans les deux volets et sur la page /connect ; sinon le volet de connexion
// présente Connect et renvoie vers sa page.
$accountUrl = account_url();
$closeIcon = '<svg width="20" height="20" viewBox="0 0 20 20" aria-hidden="true" focusable="false"><path d="M5 5l10 10M15 5L5 15" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/></svg>';

// Lanceur des sites (M-121, M-124) : liste publique (launcher_sites()) et lien « Mon compte Connect ».
// Les tuiles des autres sites portent ?via=launcher (M-132 : leur barre d'installation s'ouvre à l'arrivée), jamais
// la tuile de noorwan.com ni « Mon compte Connect ».
// Tuile : icône du site (charte commune) ; si elle ne se charge pas, site.js montre la pastille, rond à sa couleur et
// sa lettre en blanc, en SVG (couleur par l'attribut fill, jamais de style en ligne).
$launcherAccount = launcher_account_url();
$launcherDot = static fn (string $color, string $letter): string => '<svg class="launcher-dot" width="48" height="48" viewBox="0 0 48 48"'
    . ' aria-hidden="true" focusable="false"><circle cx="24" cy="24" r="23" fill="' . e($color) . '"/>'
    . '<text x="24" y="24" text-anchor="middle" dominant-baseline="central" fill="#FFFFFF" font-size="22" font-weight="600">'
    . e($letter) . '</text></svg>';

$asset = static fn (string $path): string => $path . '?v=' . (string) @filemtime(ROOT_DIR . '/public/' . $path);

// Bouton du thème (v9), dans la barre sur toutes les largeurs (charte commune) : masqué sans JavaScript
// (le site suit alors l'appareil), réglé par theme-init.js.
// Icône du thème vers lequel on bascule (croissant de lune en clair, soleil en sombre), comme sur les autres sites ;
// le libellé dit ce que fait le clic.
$themeToggle = static function (): string {
    $icons = '<svg class="theme-icon theme-icon-sun" width="20" height="20" viewBox="0 0 20 20" aria-hidden="true" focusable="false">'
        . '<g fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"><circle cx="10" cy="10" r="3.5"/>'
        . '<path d="M10 2v1.8M10 16.2V18M2 10h1.8M16.2 10H18M4.3 4.3l1.3 1.3M14.4 14.4l1.3 1.3M4.3 15.7l1.3-1.3M14.4 5.6l1.3-1.3"/></g></svg>'
        . '<svg class="theme-icon theme-icon-moon" width="20" height="20" viewBox="0 0 20 20" aria-hidden="true" focusable="false">'
        . '<path d="M16.5 12.6A7 7 0 0 1 7.4 3.5a7 7 0 1 0 9.1 9.1z" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/></svg>';

    return '<button class="theme-toggle theme-toggle-bar" type="button" hidden aria-label="' . t('nav.theme_to_dark') . '"'
        . ' data-label-dark="' . t('nav.theme_to_dark') . '" data-label-light="' . t('nav.theme_to_light') . '">'
        . $icons . "</button>\n";
};
?>
<!doctype html>
<html lang="<?= e(lang()) ?>" dir="<?= e(dir_attr()) ?>">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="color-scheme" content="light dark">
<meta name="theme-color" content="#F6F5F1" media="(prefers-color-scheme: light)" data-theme-media="light">
<meta name="theme-color" content="#000000" media="(prefers-color-scheme: dark)" data-theme-media="dark">
<script src="<?= e($asset('assets/js/theme-init.js')) ?>"></script>
<title><?= e($meta['title']) ?></title>
<meta name="description" content="<?= e($meta['description']) ?>">
<link rel="canonical" href="<?= e(absolute_url(current_page(), lang())) ?>">
<?php foreach (array_keys(LANGS) as $code): ?>
<link rel="alternate" hreflang="<?= e($code) ?>" href="<?= e(absolute_url(current_page(), $code)) ?>">
<?php endforeach; ?>
<link rel="alternate" hreflang="x-default" href="<?= e(absolute_url(current_page(), DEFAULT_LANG)) ?>">
<?php // Icônes communes des sites Noorwan (charte commune, M-120) : « n » blanc sur carré encre, point bleu ; version par la date du fichier. ?>
<link rel="icon" href="<?= e($asset('favicon.svg')) ?>" type="image/svg+xml">
<link rel="icon" href="<?= e($asset('favicon.ico')) ?>" sizes="48x48">
<link rel="apple-touch-icon" href="<?= e($asset('apple-touch-icon.png')) ?>">
<?php // Manifeste de l'application installable sans magasin (M-132) ; use-credentials : le manifeste passe aussi derrière un mot de passe Apache. ?>
<link rel="manifest" href="manifest.json" crossorigin="use-credentials">
<?php if (is_rtl()): ?>
<link rel="preload" href="assets/fonts/IBMPlexSansArabic-Regular.woff2" as="font" type="font/woff2" crossorigin>
<?php endif; ?>
<link rel="stylesheet" href="<?= e($asset('assets/css/site.css')) ?>">
<?php if (GTM_ID !== ''): ?>
<script nonce="<?= e(csp_nonce()) ?>" id="gtm-bootstrap" data-gtm-id="<?= e(GTM_ID) ?>">
window.dataLayer = window.dataLayer || [];
function gtag() { window.dataLayer.push(arguments); }
gtag('consent', 'default', { ad_storage: 'denied', ad_user_data: 'denied', ad_personalization: 'denied', analytics_storage: 'denied' });
</script>
<?php if (consent_analytics()): $adsState = consent_ads() ? 'granted' : 'denied'; ?>
<script nonce="<?= e(csp_nonce()) ?>">
gtag('consent', 'update', { analytics_storage: 'granted', ad_storage: '<?= $adsState ?>', ad_user_data: '<?= $adsState ?>', ad_personalization: '<?= $adsState ?>' });
(function (w, d, s, l, i) {
    w[l].push({ 'gtm.start': new Date().getTime(), event: 'gtm.js' });
    var f = d.getElementsByTagName(s)[0], j = d.createElement(s);
    j.async = true;
    j.src = 'https://www.googletagmanager.com/gtm.js?id=' + i;
    j.setAttribute('nonce', d.getElementById('gtm-bootstrap').nonce);
    f.parentNode.insertBefore(j, f);
})(window, document, 'script', 'dataLayer', '<?= e(GTM_ID) ?>');
</script>
<?php endif; ?>
<?php endif; ?>
<script src="<?= e($asset('assets/js/site.js')) ?>" defer></script>
</head>
<body>
<a class="skip-link" href="#main"><?= t('nav.skip') ?></a>
<header class="site-header">
    <div class="header-bar">
        <a class="menu-toggle" href="#menu-panel" aria-controls="menu-panel" aria-expanded="false" data-panel-open>
            <span class="visually-hidden"><?= t('nav.menu') ?></span>
            <svg width="20" height="20" viewBox="0 0 20 20" aria-hidden="true" focusable="false"><path d="M3 5.5h14M3 10h14M3 14.5h14" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg>
        </a>
        <a class="logo" href="<?= e(url('index')) ?>" aria-label="<?= t('nav.home_label') ?>" dir="ltr">noorwan<span class="logo-dot">.</span></a>
        <nav class="nav-desktop" aria-label="<?= t('nav.main_label') ?>">
<?php foreach ($navItems as $item): ?>
            <a href="<?= e($item['href']) ?>"<?= $navCurrent($item) ?>><?= t($item['label']) ?></a>
<?php endforeach; ?>
        </nav>
        <div class="header-tools">
            <details class="lang-menu">
                <summary><span class="visually-hidden"><?= t('nav.lang_label') ?>, <?= e(LANGS[lang()]['name']) ?></span><span aria-hidden="true"><?= e(LANGS[lang()]['label']) ?></span><svg class="lang-chevron" width="10" height="10" viewBox="0 0 10 10" aria-hidden="true" focusable="false"><path d="M2 3.5l3 3 3-3" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg></summary>
                <ul class="lang-list" aria-label="<?= t('nav.lang_label') ?>">
<?php foreach (LANGS as $code => $info): ?>
                    <li><a href="<?= e(url(current_page(), '', [], $code)) ?>" lang="<?= e($code) ?>" hreflang="<?= e($code) ?>"<?= $code === lang() ? ' aria-current="true"' : '' ?>><?= e($info['name']) ?></a></li>
<?php endforeach; ?>
                </ul>
            </details>
            <?= $themeToggle() ?>
            <a class="launcher-toggle" href="#launcher-panel" aria-controls="launcher-panel" aria-expanded="false" aria-label="<?= t('launcher.title') ?>" title="<?= t('launcher.title') ?>" data-panel-open>
                <svg width="20" height="20" viewBox="0 0 20 20" aria-hidden="true" focusable="false"><g fill="currentColor"><circle cx="4" cy="4" r="1.6"/><circle cx="10" cy="4" r="1.6"/><circle cx="16" cy="4" r="1.6"/><circle cx="4" cy="10" r="1.6"/><circle cx="10" cy="10" r="1.6"/><circle cx="16" cy="10" r="1.6"/><circle cx="4" cy="16" r="1.6"/><circle cx="10" cy="16" r="1.6"/><circle cx="16" cy="16" r="1.6"/></g></svg>
            </a>
            <a class="account-toggle" href="#connect-panel" aria-controls="connect-panel" aria-expanded="false" data-panel-open><?= t('nav.sign_in') ?></a>
        </div>
    </div>
</header>
<div id="menu-panel" class="panel-layer panel-start" data-panel>
    <a class="panel-scrim" href="#" tabindex="-1" aria-hidden="true" data-panel-close></a>
    <section class="panel" role="dialog" aria-modal="true" aria-labelledby="menu-panel-title">
        <div class="panel-head">
            <h2 id="menu-panel-title" class="visually-hidden"><?= t('nav.menu_panel_label') ?></h2>
            <a class="logo" href="<?= e(url('index')) ?>" aria-label="<?= t('nav.home_label') ?>" dir="ltr">noorwan<span class="logo-dot">.</span></a>
            <a class="panel-close" href="#" data-panel-close><span class="visually-hidden"><?= t('nav.close') ?></span><?= $closeIcon ?></a>
        </div>
        <div class="panel-body">
            <nav id="nav-mobile" class="nav-mobile" aria-label="<?= t('nav.mobile_label') ?>">
                <ul class="panel-list">
<?php foreach ($panelItems as $item): ?>
                    <li><a href="<?= e($item['href']) ?>"<?= $navCurrent($item) ?>><?= t($item['label']) ?></a></li>
<?php endforeach; ?>
                </ul>
            </nav>
<?php if (install_available()): ?>
<?php // « Installer l'application » (M-132) : montrée par site.js seulement quand l'installation est possible (Android) ou expliquée (iPhone, iPad) ; sans JavaScript, rien. ?>
            <ul class="panel-list panel-install" data-install-entry hidden>
                <li><button class="panel-install-btn" type="button" data-install-open><?= t('install.menu') ?></button></li>
            </ul>
<?php endif; ?>
        </div>
<?php if ($accountUrl !== null): ?>
        <div class="panel-foot">
            <a class="btn btn-connect btn-block connect-continue" href="<?= e($accountUrl) ?>"><?= t('connect.continue') ?></a>
        </div>
<?php endif; ?>
    </section>
</div>
<div id="launcher-panel" class="panel-layer panel-end panel-launcher" data-panel>
    <a class="panel-scrim" href="#" tabindex="-1" aria-hidden="true" data-panel-close></a>
    <section class="panel" role="dialog" aria-modal="true" aria-labelledby="launcher-panel-title">
        <div class="panel-head">
            <h2 id="launcher-panel-title" class="panel-title"><?= t('launcher.title') ?></h2>
            <a class="panel-close" href="#" data-panel-close><span class="visually-hidden"><?= t('nav.close') ?></span><?= $closeIcon ?></a>
        </div>
        <div class="panel-body">
            <ul class="launcher-grid">
<?php foreach (launcher_sites() as $site): ?>
                <li><a class="launcher-tile" href="<?= e($site['current'] ? $site['url'] : with_origin($site['url'], 'launcher')) ?>" data-launcher-site="<?= e($site['key']) ?>"<?= $site['current'] ? ' aria-current="page"' : ' rel="noopener"' ?>><span class="launcher-icon" data-launcher-icon><img class="launcher-img" src="<?= e($asset($site['icon'])) ?>" alt="" width="48" height="48" decoding="async"><?= $launcherDot($site['color'], $site['letter']) ?></span><bdi><?= t($site['label']) ?></bdi></a></li>
<?php endforeach; ?>
            </ul>
        </div>
<?php if ($launcherAccount !== null): ?>
        <div class="panel-foot">
            <a class="launcher-account" href="<?= e($launcherAccount) ?>" rel="noopener"><?= t('launcher.account') ?></a>
        </div>
<?php endif; ?>
    </section>
</div>
<div id="connect-panel" class="panel-layer panel-end" data-panel>
    <a class="panel-scrim" href="#" tabindex="-1" aria-hidden="true" data-panel-close></a>
    <section class="panel" role="dialog" aria-modal="true" aria-labelledby="connect-panel-title">
        <div class="panel-head">
            <h2 id="connect-panel-title" class="panel-title"><?= t('nav.sign_in') ?></h2>
            <a class="panel-close" href="#" data-panel-close><span class="visually-hidden"><?= t('nav.close') ?></span><?= $closeIcon ?></a>
        </div>
        <div class="panel-body panel-connect">
            <p class="connect-lockup" dir="ltr" lang="en">noorwan<span class="logo-dot">.</span><span class="connect-lockup-name">Connect</span></p>
            <p class="panel-lead"><?= t('connect.title') ?></p>
            <p class="panel-text"><?= t('connect.lead') ?></p>
<?php if ($accountUrl !== null): ?>
            <a class="btn btn-connect btn-block connect-continue" href="<?= e($accountUrl) ?>"><?= t('connect.continue') ?></a>
<?php endif; ?>
            <p><a class="more" href="<?= e(url('connect')) ?>"><?= t('common.learn_more') ?></a></p>
        </div>
    </section>
</div>
<main id="main" tabindex="-1">
