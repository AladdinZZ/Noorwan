<?php

declare(strict_types=1);

// En-tête commun : <head>, bandeau avec logo, navigation, choix de langue et menu mobile.
// Attend $meta = ['title' => ..., 'description' => ...] (chaînes brutes, échappées ici).

// « À propos » viendra avec sa propre page : il n'est pas dans le menu en v1.
$navItems = [
    ['label' => 'nav.consulting', 'href' => url('index', 'consulting')],
    ['label' => 'nav.solutions', 'href' => url('index', 'solutions')],
    ['label' => 'nav.edition', 'href' => url('index', 'edition')],
    ['label' => 'nav.contact', 'href' => url('index', 'contact')],
];

$asset = static fn (string $path): string => $path . '?v=' . (string) @filemtime(ROOT_DIR . '/public/' . $path);
?>
<!doctype html>
<html lang="<?= e(lang()) ?>" dir="<?= e(dir_attr()) ?>">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><?= e($meta['title']) ?></title>
<meta name="description" content="<?= e($meta['description']) ?>">
<link rel="canonical" href="<?= e(absolute_url(current_page(), lang())) ?>">
<?php foreach (array_keys(LANGS) as $code): ?>
<link rel="alternate" hreflang="<?= e($code) ?>" href="<?= e(absolute_url(current_page(), $code)) ?>">
<?php endforeach; ?>
<link rel="alternate" hreflang="x-default" href="<?= e(absolute_url(current_page(), DEFAULT_LANG)) ?>">
<link rel="icon" href="<?= e($asset('assets/images/favicon.svg')) ?>" type="image/svg+xml">
<?php if (is_rtl()): ?>
<link rel="preload" href="assets/fonts/IBMPlexSansArabic-Regular.woff2" as="font" type="font/woff2" crossorigin>
<?php endif; ?>
<link rel="stylesheet" href="<?= e($asset('assets/css/site.css')) ?>">
<script src="<?= e($asset('assets/js/site.js')) ?>" defer></script>
</head>
<body>
<a class="skip-link" href="#main"><?= t('nav.skip') ?></a>
<header class="site-header">
    <div class="wrap header-bar">
        <a class="logo" href="<?= e(url('index')) ?>" aria-label="<?= t('nav.home_label') ?>" dir="ltr">noorwan<span class="logo-dot">.</span></a>
        <nav class="nav-desktop" aria-label="<?= t('nav.main_label') ?>">
<?php foreach ($navItems as $item): ?>
            <a href="<?= e($item['href']) ?>"><?= t($item['label']) ?></a>
<?php endforeach; ?>
        </nav>
        <div class="header-tools">
            <div class="lang-switch" role="group" aria-label="<?= t('nav.lang_label') ?>">
<?php foreach (LANGS as $code => $info): ?>
                <a href="<?= e(url(current_page(), '', [], $code)) ?>" lang="<?= e($code) ?>" hreflang="<?= e($code) ?>" title="<?= e($info['name']) ?>"<?= $code === lang() ? ' aria-current="true"' : '' ?>><span><?= e($info['label']) ?></span></a>
<?php endforeach; ?>
            </div>
            <button class="menu-toggle" type="button" aria-expanded="false" aria-controls="nav-mobile" hidden>
                <span class="visually-hidden"><?= t('nav.menu') ?></span>
                <svg width="20" height="20" viewBox="0 0 20 20" aria-hidden="true" focusable="false"><g stroke="currentColor" stroke-width="1.6" stroke-linecap="round"><line class="menu-line-1" x1="3" y1="6.5" x2="17" y2="6.5"/><line class="menu-line-2" x1="3" y1="13.5" x2="17" y2="13.5"/></g></svg>
            </button>
        </div>
    </div>
    <nav id="nav-mobile" class="nav-mobile wrap" aria-label="<?= t('nav.mobile_label') ?>">
<?php foreach ($navItems as $item): ?>
        <a href="<?= e($item['href']) ?>"><?= t($item['label']) ?></a>
<?php endforeach; ?>
    </nav>
</header>
<main id="main" tabindex="-1">
