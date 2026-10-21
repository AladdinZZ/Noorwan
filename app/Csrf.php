<?php

declare(strict_types=1);

/**
 * Jeton anti-falsification du formulaire, signé et daté, sans session ni cookie.
 *
 * Le site ne pose aucun cookie : le jeton prouve que le formulaire a été servi par ce site
 * il y a moins de MAX_AGE secondes. Il est complété par la vérification de l'en-tête Origin.
 */
final class Csrf
{
    private const MAX_AGE = 7200;

    public static function token(string $form): string
    {
        $payload = time() . '.' . bin2hex(random_bytes(8));

        return $payload . '.' . self::sign($form, $payload);
    }

    public static function isValid(string $form, mixed $token): bool
    {
        if (!is_string($token) || substr_count($token, '.') !== 2) {
            return false;
        }

        [$issuedAt, $nonce, $signature] = explode('.', $token);
        if (!ctype_digit($issuedAt) || !hash_equals(self::sign($form, $issuedAt . '.' . $nonce), $signature)) {
            return false;
        }

        $age = time() - (int) $issuedAt;

        return $age >= 0 && $age <= self::MAX_AGE && self::isSameOrigin();
    }

    /**
     * Refuse un envoi venu d'un autre site quand le navigateur indique l'origine.
     */
    private static function isSameOrigin(): bool
    {
        $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
        if ($origin === '') {
            return true;
        }

        $expected = parse_url((string) env('APP_URL', ''));
        $actual = parse_url($origin);

        return isset($expected['host'], $actual['host'])
            && strcasecmp($expected['host'], $actual['host']) === 0
            && ($expected['port'] ?? null) === ($actual['port'] ?? null);
    }

    private static function sign(string $form, string $payload): string
    {
        return hash_hmac('sha256', $form . '|' . $payload, app_secret());
    }
}
