<?php

declare(strict_types=1);

// Versions sombres des illustrations (thème sombre) : php bin/illustrations-dark.php
// Lit chaque public/assets/img/<nom>.svg et écrit <nom>-dark.svg à côté, en changeant seulement les couleurs :
// le noir du dessin devient clair (#F5F5F7), les blancs et gris clairs s'assombrissent, les fonds teintés
// des univers prennent leur teinte sombre ; les couleurs d'univers, l'or et le bleu restent. Aucun dessin nouveau.
// À relancer après toute retouche d'une illustration ; tests/run.sh vérifie que chaque version sombre est à jour.

const IMG_DIR = __DIR__ . '/../public/assets/img';

// Illustrations dessinées pour un fond déjà noir (section ou carte sombre) : version sombre identique.
const DRAWN_FOR_DARK = ['connect-code', 'noor'];

// Couleur claire => couleur sombre (majuscules, six chiffres).
const DARK_COLORS = [
    // Noir du dessin et gris foncés : deviennent clairs.
    '#1D1D1F' => '#F5F5F7',
    '#515154' => '#A1A1A6',
    // Blancs et gris clairs : surfaces assombries (papier, brume, traits).
    '#FFFFFF' => '#1C1C1E',
    '#F5F5F7' => '#2C2C2E',
    '#EEEDE8' => '#111113',
    '#EDEDF0' => '#161618',
    '#E4E3DD' => '#1A1A1C',
    '#E5E5EA' => '#2A2A2C',
    '#D2D2D7' => '#3A3A3C',
    '#B9B9C0' => '#636366',
    // Fonds teintés des univers : leur teinte sombre (Consulting, Solutions, Édition).
    '#F3EEE3' => '#2A2418',
    '#EFE7D6' => '#332C1E',
    '#D9C9A3' => '#4A3F2A',
    '#E9EEF5' => '#1A2230',
    '#D3DDEA' => '#24304A',
    '#C4D1E2' => '#2E3D58',
    '#F5E9EB' => '#2C1C20',
    '#E2C4C9' => '#4A2E35',
    '#D9BCC2' => '#3E262C',
    // Brun très foncé de l'Édition (dos de livre) : éclairci pour rester visible sur le noir.
    '#2A1E21' => '#D9A5AE',
];

function dark_svg(string $svg): string
{
    return (string) preg_replace_callback('/#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})\b/', static function (array $m): string {
        $hex = strtoupper($m[1]);
        if (strlen($hex) === 3) {
            $hex = $hex[0] . $hex[0] . $hex[1] . $hex[1] . $hex[2] . $hex[2];
        }

        return DARK_COLORS['#' . $hex] ?? $m[0];
    }, $svg);
}

$check = in_array('--check', $argv, true);
$stale = [];
foreach (glob(IMG_DIR . '/*.svg') ?: [] as $file) {
    $name = basename($file, '.svg');
    if (str_ends_with($name, '-dark')) {
        continue;
    }
    $svg = (string) file_get_contents($file);
    $dark = in_array($name, DRAWN_FOR_DARK, true) ? $svg : dark_svg($svg);
    $target = IMG_DIR . '/' . $name . '-dark.svg';
    if ($check) {
        if (!is_file($target) || file_get_contents($target) !== $dark) {
            $stale[] = $name;
        }
        continue;
    }
    file_put_contents($target, $dark);
    echo $name . "-dark.svg\n";
}

if ($check) {
    if ($stale !== []) {
        fwrite(STDERR, 'Versions sombres à régénérer : ' . implode(', ', $stale) . "\n");
        exit(1);
    }
    echo "ok\n";
}
