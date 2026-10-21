<?php

declare(strict_types=1);

// Catalogue Noorwan Édition. Les titres restent en français dans toutes les langues (titres publiés).
// asin : identifiant Amazon de la fiche du livre, à fournir par Marwan. Ne jamais en inventer un.
// Tant qu'il est vide, le bouton « Acheter » mène à la recherche Amazon utilisée par le site actuel.

const AMAZON_SEARCH_URL = 'https://www.amazon.fr/s?k=noorwan';
const AMAZON_PRODUCT_URL = 'https://www.amazon.fr/dp/';

function collections(): array
{
    return ['metaphysique', 'chemins'];
}

function books(): array
{
    return [
        'harmonie' => [
            'title' => 'Harmonie',
            'collection' => 'metaphysique',
            'cover' => 'couverture_harmonie.jpg',
            'cover_size' => [1000, 1430],
            'asin' => '',
            'published' => true,
            'also_in_english' => false,
        ],
        'lumiere' => [
            'title' => 'Lumière',
            'collection' => 'metaphysique',
            'cover' => 'couverture_lumiere.jpg',
            'cover_size' => [1000, 1430],
            'asin' => '',
            'published' => true,
            'also_in_english' => false,
        ],
        'vibration' => [
            'title' => 'Vibration',
            'collection' => 'metaphysique',
            'cover' => null,
            'cover_size' => null,
            'asin' => '',
            'published' => false,
            'also_in_english' => false,
        ],
        'le-mal' => [
            'title' => 'Le Mal',
            'collection' => 'chemins',
            'cover' => 'couverture_7mal.jpg',
            'cover_size' => [1000, 1499],
            'asin' => '',
            'published' => true,
            'also_in_english' => true,
        ],
        'le-bien' => [
            'title' => 'Le Bien',
            'collection' => 'chemins',
            'cover' => 'couverture__7bein.jpg',
            'cover_size' => [1000, 1499],
            'asin' => '',
            'published' => true,
            'also_in_english' => true,
        ],
        'etre-pour-avoir' => [
            'title' => 'Être pour Avoir',
            'collection' => 'chemins',
            'cover' => 'couverture_etre.jpg',
            'cover_size' => [1000, 1499],
            'asin' => '',
            'published' => true,
            'also_in_english' => true,
        ],
    ];
}

function amazon_url(array $book): string
{
    return $book['asin'] !== '' ? AMAZON_PRODUCT_URL . rawurlencode($book['asin']) : AMAZON_SEARCH_URL;
}
