<?php

declare(strict_types=1);

// Arbre des applications (accueil, 27/11/2026, demande de Marwan) : le tronc est Noorwan, trois branches pour les trois
// univers (Consulting, Solutions, Édition), et au bout de la branche Solutions les applications publiques (tree_apps() :
// Reserva, Inteek, Connect), chacune avec son icône de la famille commune et son nom, vers son adresse (?lang=, ?via=launcher).
// Dessin original en SVG dans la page (aucune image tierce), décoratif (aria-hidden) : les noms et les liens sont en HTML
// par-dessus, posés en pourcentage du dessin (site.css, .tree-at-*). Deux dessins : vertical au téléphone, large dès 768 px.
// Couleurs par variables de site.css (thème sombre compris), miroir en arabe, aucune animation.
// Titre et phrase de la section : à fournir par Marwan (docs/CONTENUS.md).
// $asset et $launcherDot viennent de app/layout/header.php (icône versionnée, pastille de secours de site.js).
$universes = tl('home.univers');
$treeBranches = [
    'consulting' => url('consulting'),
    'solutions' => url('solutions'),
    'edition' => url('edition'),
];
$treeApps = tree_apps();
?>
<section id="arbre" class="screen tree-screen" aria-labelledby="tree-title">
    <div class="wrap">
        <h2 id="tree-title" class="h2"><?= todo('home.tree_h') ?></h2>
        <p class="lead"><?= todo('home.tree_text') ?></p>
    </div>
    <div class="tree">
        <svg class="tree-art tree-art-narrow" viewBox="0 0 360 520" width="360" height="520" aria-hidden="true" focusable="false">
            <ellipse class="tree-canopy" cx="180" cy="112" rx="172" ry="104"/>
            <path class="tree-ground" d="M40 494 H320"/>
            <path class="tree-root" d="M166 492 C154 500 138 504 120 504 M194 492 C206 500 222 504 240 504"/>
            <path class="tree-bark" d="M158 494 C165 444 168 392 171 340 L189 340 C192 392 195 444 202 494 Z"/>
            <path class="tree-limb tree-limb-cons" d="M176 396 C140 376 96 352 62 300"/>
            <path class="tree-limb tree-limb-ed" d="M184 388 C220 370 264 350 298 300"/>
            <path class="tree-limb tree-limb-sol" d="M180 344 C180 300 180 262 180 224"/>
            <path class="tree-twig tree-limb-sol" d="M180 238 C152 206 112 156 70 95 M180 230 C180 170 180 110 180 55 M180 238 C208 206 248 156 290 95"/>
            <circle class="tree-leaf tree-leaf-cons" cx="62" cy="258" r="40"/>
            <circle class="tree-leaf tree-leaf-ed" cx="298" cy="258" r="40"/>
            <circle class="tree-leaf tree-leaf-sol" cx="70" cy="95" r="50"/>
            <circle class="tree-leaf tree-leaf-sol" cx="180" cy="55" r="50"/>
            <circle class="tree-leaf tree-leaf-sol" cx="290" cy="95" r="50"/>
            <ellipse class="tree-bud tree-bud-cons" cx="122" cy="358" rx="11" ry="5" transform="rotate(-32 122 358)"/>
            <ellipse class="tree-bud tree-bud-ed" cx="240" cy="352" rx="11" ry="5" transform="rotate(32 240 352)"/>
            <ellipse class="tree-bud tree-bud-sol" cx="194" cy="286" rx="10" ry="5" transform="rotate(-40 194 286)"/>
            <ellipse class="tree-bud tree-bud-sol" cx="128" cy="168" rx="10" ry="5" transform="rotate(30 128 168)"/>
            <ellipse class="tree-bud tree-bud-sol" cx="234" cy="168" rx="10" ry="5" transform="rotate(-30 234 168)"/>
        </svg>
        <svg class="tree-art tree-art-wide" viewBox="0 0 1000 560" width="1000" height="560" aria-hidden="true" focusable="false">
            <ellipse class="tree-canopy" cx="500" cy="124" rx="300" ry="112"/>
            <path class="tree-ground" d="M120 534 H880"/>
            <path class="tree-root" d="M480 532 C462 542 436 546 404 546 M520 532 C538 542 564 546 596 546"/>
            <path class="tree-bark" d="M472 534 C481 470 485 412 488 360 L512 360 C515 412 519 470 528 534 Z"/>
            <path class="tree-limb tree-limb-cons" d="M494 424 C400 398 262 362 150 262"/>
            <path class="tree-limb tree-limb-ed" d="M506 418 C600 394 738 358 850 262"/>
            <path class="tree-limb tree-limb-sol" d="M500 364 C500 322 500 276 500 238"/>
            <path class="tree-twig tree-limb-sol" d="M500 252 C450 212 390 162 330 112 M500 240 C500 184 500 124 500 72 M500 252 C550 212 610 162 670 112"/>
            <circle class="tree-leaf tree-leaf-cons" cx="150" cy="212" r="50"/>
            <circle class="tree-leaf tree-leaf-ed" cx="850" cy="212" r="50"/>
            <circle class="tree-leaf tree-leaf-sol" cx="330" cy="112" r="58"/>
            <circle class="tree-leaf tree-leaf-sol" cx="500" cy="72" r="58"/>
            <circle class="tree-leaf tree-leaf-sol" cx="670" cy="112" r="58"/>
            <ellipse class="tree-bud tree-bud-cons" cx="330" cy="372" rx="14" ry="6" transform="rotate(-18 330 372)"/>
            <ellipse class="tree-bud tree-bud-cons" cx="232" cy="326" rx="12" ry="5" transform="rotate(-34 232 326)"/>
            <ellipse class="tree-bud tree-bud-ed" cx="670" cy="372" rx="14" ry="6" transform="rotate(18 670 372)"/>
            <ellipse class="tree-bud tree-bud-ed" cx="768" cy="326" rx="12" ry="5" transform="rotate(34 768 326)"/>
            <ellipse class="tree-bud tree-bud-sol" cx="418" cy="186" rx="12" ry="5" transform="rotate(36 418 186)"/>
            <ellipse class="tree-bud tree-bud-sol" cx="582" cy="186" rx="12" ry="5" transform="rotate(-36 582 186)"/>
        </svg>
        <ul class="tree-map" aria-labelledby="tree-title">
            <li><span class="tree-node tree-trunk tree-at-noorwan"><?= t('common.brand') ?></span>
                <ul>
<?php foreach ($treeBranches as $key => $href): ?>
                    <li><a class="tree-node tree-branch tree-branch-<?= e($key) ?> tree-at-<?= e($key) ?>" href="<?= e($href) ?>"><?= e($universes[$key]['title']) ?></a>
<?php if ($key === 'solutions'): ?>
                        <ul>
<?php foreach ($treeApps as $app): ?>
                            <li><a class="tree-node tree-app tree-at-<?= e($app['key']) ?>" href="<?= e($app['url']) ?>" data-tree-app="<?= e($app['key']) ?>" rel="noopener"><span class="launcher-icon" data-launcher-icon><img class="launcher-img" src="<?= e($asset($app['icon'])) ?>" alt="" width="48" height="48" loading="lazy" decoding="async"><?= $launcherDot($app['color'], $app['letter']) ?></span><bdi><?= t($app['label']) ?></bdi></a></li>
<?php endforeach; ?>
                        </ul>
<?php endif; ?>
                    </li>
<?php endforeach; ?>
                </ul>
            </li>
        </ul>
    </div>
</section>
