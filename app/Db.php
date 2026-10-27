<?php

declare(strict_types=1);

/**
 * Connexions PDO à la base du site (paramètres lus dans .env).
 *
 * Deux utilisateurs MySQL : DB_USER pour le site (INSERT seulement sur contact_requests,
 * le site ne lit jamais la table) et DB_MAINT_USER pour la maintenance en ligne de commande
 * (SELECT et DELETE, purge des demandes). Sans DB_MAINT_USER (poste local), DB_USER sert aux deux.
 */
final class Db
{
    private static ?PDO $pdo = null;
    private static ?PDO $maintenance = null;

    public static function pdo(): PDO
    {
        return self::$pdo ??= self::connect((string) env('DB_USER', ''), (string) env('DB_PASS', ''));
    }

    public static function maintenance(): PDO
    {
        $user = env('DB_MAINT_USER');

        return self::$maintenance ??= $user === null
            ? self::pdo()
            : self::connect($user, (string) env('DB_MAINT_PASS', ''));
    }

    private static function connect(string $user, string $password): PDO
    {
        // DB_HOST accepte « hôte:port » (MAMP : 127.0.0.1:8889).
        [$host, $port] = array_pad(explode(':', (string) env('DB_HOST', '127.0.0.1'), 2), 2, '3306');
        $dsn = sprintf('mysql:host=%s;port=%d;dbname=%s;charset=utf8mb4', $host, (int) $port, (string) env('DB_NAME', 'noorwan_site'));

        $pdo = new PDO($dsn, $user, $password, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);
        $pdo->exec("SET time_zone = '+00:00'");

        return $pdo;
    }
}
