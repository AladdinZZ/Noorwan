<?php

declare(strict_types=1);

// Purge des demandes de contact : supprime toutes les demandes d'une adresse e-mail
// dont le dernier envoi date de plus de 3 ans (politique de confidentialité, « Durée de conservation »).
// Ligne de commande uniquement : php bin/purge-contacts.php [--dry-run]
// Une ligne de journal par exécution sur la sortie standard (le cron l'ajoute à storage/logs/purge.log).

if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}

require __DIR__ . '/../app/bootstrap.php';

const RETENTION_YEARS = 3;

$dryRun = in_array('--dry-run', array_slice($argv, 1), true);
$unknown = array_diff(array_slice($argv, 1), ['--dry-run']);
if ($unknown !== []) {
    fwrite(STDERR, 'Option inconnue : ' . implode(' ', $unknown) . PHP_EOL . 'Usage : php bin/purge-contacts.php [--dry-run]' . PHP_EOL);
    exit(2);
}

// Adresses dont le dernier envoi est antérieur à la limite. Dates en UTC des deux côtés.
// La comparaison des adresses suit l'interclassement de la colonne (insensible à la casse).
$expired = 'SELECT email FROM contact_requests GROUP BY email
            HAVING MAX(created_at) < UTC_TIMESTAMP() - INTERVAL ' . RETENTION_YEARS . ' YEAR';

try {
    $join = 'contact_requests c JOIN (' . $expired . ') expired ON expired.email = c.email';
    $statement = Db::maintenance()->prepare($dryRun ? 'SELECT COUNT(*) FROM ' . $join : 'DELETE c FROM ' . $join);
    $statement->execute();
    $count = $dryRun ? (int) $statement->fetchColumn() : $statement->rowCount();
} catch (Throwable $exception) {
    fwrite(STDERR, gmdate('Y-m-d\TH:i:s\Z') . ' purge-contacts ERREUR : ' . $exception->getMessage() . PHP_EOL);
    exit(1);
}

fwrite(STDOUT, gmdate('Y-m-d\TH:i:s\Z') . ' purge-contacts ' . ($dryRun
    ? 'simulation : ' . $count . ' demande(s) à supprimer, rien n\'est supprimé'
    : $count . ' demande(s) supprimée(s)') . PHP_EOL);
