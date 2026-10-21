<?php

declare(strict_types=1);

// robots.txt et plan du site, servis par public/robots.php et public/sitemap.php
// (réécriture dans public/.htaccess). Hors production, tout est interdit aux robots.

function robots_txt(bool $indexable): string
{
    if (!$indexable) {
        return "User-agent: *\nDisallow: /\n";
    }

    return "User-agent: *\nAllow: /\n\nSitemap: " . rtrim((string) env('APP_URL', ''), '/') . "/sitemap.xml\n";
}

/**
 * Plan du site : chaque page dans chaque langue, avec ses versions alternatives (hreflang).
 */
function sitemap_xml(): string
{
    $xml = static fn (string $value): string => htmlspecialchars($value, ENT_QUOTES | ENT_XML1, 'UTF-8');

    $out = '<?xml version="1.0" encoding="UTF-8"?>' . "\n"
        . '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">' . "\n";
    foreach (array_keys(PAGES) as $page) {
        $alternates = '';
        foreach (array_keys(LANGS) as $code) {
            $alternates .= '    <xhtml:link rel="alternate" hreflang="' . $xml($code) . '" href="' . $xml(absolute_url($page, $code)) . '"/>' . "\n";
        }
        $alternates .= '    <xhtml:link rel="alternate" hreflang="x-default" href="' . $xml(absolute_url($page, DEFAULT_LANG)) . '"/>' . "\n";

        foreach (array_keys(LANGS) as $lang) {
            $out .= "  <url>\n    <loc>" . $xml(absolute_url($page, $lang)) . "</loc>\n" . $alternates . "  </url>\n";
        }
    }

    return $out . "</urlset>\n";
}
