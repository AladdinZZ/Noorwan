<?php

declare(strict_types=1);

// Carte d'une solution, sur l'accueil et sur la page Solutions. Attend $solution (une entrée de home.solutions) ;
// $solutionText (facultatif) remplace la description, par exemple « Présentation sur rendez-vous. ».
$cardText = $solutionText ?? $solution['text'];
?>
            <article class="card solution">
                <div class="solution-top">
                    <span class="solution-cat"><?= e($solution['cat']) ?></span>
<?php if ($solution['confidential']): ?>
                    <span class="badge-confidential"><svg width="12" height="12" viewBox="0 0 12 12" aria-hidden="true" focusable="false"><rect x="2" y="5.5" width="8" height="5.5" rx="1.2" fill="none" stroke="currentColor" stroke-width="1.2"/><path d="M4 5.5V4a2 2 0 0 1 4 0v1.5" fill="none" stroke="currentColor" stroke-width="1.2"/></svg><?= t('home.confidential') ?></span>
<?php endif; ?>
                </div>
                <h3><?= e($solution['name']) ?></h3>
<?php if ($cardText !== ''): ?>
                <p><?= e($cardText) ?></p>
<?php endif; ?>
            </article>
