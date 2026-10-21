<?php

declare(strict_types=1);

// Catalogue Noorwan Édition. Les titres publiés en français s'affichent en FR et en AR.
// title_en : titre de l'édition anglaise, repris du site actuel (version anglaise) ; null si le livre n'existe qu'en français.
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
            'title_en' => null,
            'collection' => 'metaphysique',
            'cover' => 'couverture_harmonie.jpg',
            'cover_size' => [1000, 1430],
            'asin' => '',
            'published' => true,
            'also_in_english' => false,
        ],
        'lumiere' => [
            'title' => 'Lumière',
            'title_en' => null,
            'collection' => 'metaphysique',
            'cover' => 'couverture_lumiere.jpg',
            'cover_size' => [1000, 1430],
            'asin' => '',
            'published' => true,
            'also_in_english' => false,
        ],
        'vibration' => [
            'title' => 'Vibration',
            'title_en' => null,
            'collection' => 'metaphysique',
            'cover' => null,
            'cover_size' => null,
            'asin' => '',
            'published' => false,
            'also_in_english' => false,
        ],
        'le-mal' => [
            'title' => 'Le Mal',
            'title_en' => 'Evil',
            'collection' => 'chemins',
            'cover' => 'couverture_7mal.jpg',
            'cover_size' => [1000, 1499],
            'asin' => '',
            'published' => true,
            'also_in_english' => true,
        ],
        'le-bien' => [
            'title' => 'Le Bien',
            'title_en' => 'Good',
            'collection' => 'chemins',
            'cover' => 'couverture__7bein.jpg',
            'cover_size' => [1000, 1499],
            'asin' => '',
            'published' => true,
            'also_in_english' => true,
        ],
        'etre-pour-avoir' => [
            'title' => 'Être pour Avoir',
            'title_en' => 'Being vs Having',
            'collection' => 'chemins',
            'cover' => 'couverture_etre.jpg',
            'cover_size' => [1000, 1499],
            'asin' => '',
            'published' => true,
            'also_in_english' => true,
        ],
    ];
}

/**
 * Titre affiché : le titre anglais sur les pages en anglais quand le livre existe en anglais, sinon le titre français.
 */
function book_title(array $book): string
{
    return lang() === 'en' && $book['title_en'] !== null ? $book['title_en'] : $book['title'];
}

function amazon_url(array $book): string
{
    return $book['asin'] !== '' ? AMAZON_PRODUCT_URL . rawurlencode($book['asin']) : AMAZON_SEARCH_URL;
}
