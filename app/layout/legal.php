<?php

declare(strict_types=1);

// Gabarit des pages légales. $legalKey : « mentions », « privacy » ou « cookies » (clés legal.* de lang/).
// Chaque section : ['title' => ..., 'body' => [paragraphe, ['list' => [...]], ...]].

// Les marqueurs [À COMPLÉTER] sont surlignés pour rester visibles tant qu'ils ne sont pas remplacés.
// Les adresses e-mail deviennent des liens, toujours lues de gauche à droite (pages en arabe).
$legalText = static fn (string $text): string => preg_replace(
    '/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/',
    '<a href="mailto:$0" dir="ltr">$0</a>',
    str_replace('[À COMPLÉTER]', '<mark class="todo">[À COMPLÉTER]</mark>', e($text)),
);
?>
<section class="page-hero" aria-labelledby="page-title">
    <div class="wrap">
        <p class="eyebrow"><?= t('legal.eyebrow') ?></p>
        <h1 id="page-title"><?= t('legal.' . $legalKey . '.title') ?></h1>
        <p class="page-lead"><?= $legalText(raw('legal.' . $legalKey . '.intro')) ?></p>
        <p class="legal-updated"><?= t('legal.updated') ?></p>
    </div>
</section>

<section class="section">
    <div class="wrap">
    <div class="legal">
<?php foreach (tl('legal.' . $legalKey . '.sections') as $section): ?>
        <h2><?= e($section['title']) ?></h2>
<?php foreach ($section['body'] as $block): ?>
<?php if (is_array($block)): ?>
        <ul>
<?php foreach ($block['list'] as $item): ?>
            <li><?= $legalText($item) ?></li>
<?php endforeach; ?>
        </ul>
<?php else: ?>
        <p><?= $legalText($block) ?></p>
<?php endif; ?>
<?php endforeach; ?>
<?php endforeach; ?>
    </div>
    </div>
</section>
