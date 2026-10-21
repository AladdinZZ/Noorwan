<?php

declare(strict_types=1);

/**
 * Connexion PDO unique à la base du site (paramètres lus dans .env).
 */
final class Db
{
    private static ?PDO $pdo = null;

    public static function pdo(): PDO
    {
        if (self::$pdo === null) {
            // DB_HOST accepte « hôte:port » (MAMP : 127.0.0.1:8889).
            [$host, $port] = array_pad(explode(':', (string) env('DB_HOST', '127.0.0.1'), 2), 2, '3306');
            $dsn = sprintf('mysql:host=%s;port=%d;dbname=%s;charset=utf8mb4', $host, (int) $port, (string) env('DB_NAME', 'noorwan_site'));

            self::$pdo = new PDO($dsn, (string) env('DB_USER', ''), (string) env('DB_PASS', ''), [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
            ]);
            self::$pdo->exec("SET time_zone = '+00:00'");
        }

        return self::$pdo;
    }
}
