<?php

declare(strict_types=1);

// Les cinq expertises du Consulting en cartes illustrées (planche « Nos expertises », variante 1, validée par Marwan le 19/11/2026),
// puis une sixième carte sombre : « Clarifier avant d'accélérer. » et sa ligne d'explication (home.cons_app_h, home.cons_app).
// Pictogrammes décoratifs (alt vide), dans l'ordre de home.expertises, version sombre à côté (expertises/*-dark.svg).
// Gabarit commun : à inclure dans une section qui porte déjà le titre « Nos expertises ».
$expertiseIcons = ['strategy', 'marketing', 'ecommerce', 'web', 'training'];
?>
        <ul class="expertises">
<?php foreach (tl('home.expertises') as $i => $expertise): ?>
            <li class="expertise">
                <?= illustration('expertises/' . $expertiseIcons[$i], 'expertise-icon', 64, 64, ['loading' => 'lazy', 'decoding' => 'async']) ?>
                <strong><?= e($expertise['title']) ?></strong>
                <span><?= e($expertise['text']) ?></span>
            </li>
<?php endforeach; ?>
            <li class="expertise expertise-motto">
                <strong><?= t('home.cons_app_h') ?></strong>
                <span><?= t('home.cons_app') ?></span>
            </li>
        </ul>
