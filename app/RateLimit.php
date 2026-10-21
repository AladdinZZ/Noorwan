<?php

declare(strict_types=1);

/**
 * Limite d'envois par IP sur une fenêtre glissante, stockée en fichiers (storage/ratelimit/).
 * Le nom du fichier est une empreinte salée de l'IP : l'adresse n'est jamais écrite en clair.
 */
final class RateLimit
{
    public function __construct(
        private readonly string $bucket,
        private readonly int $max = 5,
        private readonly int $window = 3600,
    ) {
    }

    public function isExceeded(string $ip): bool
    {
        return count($this->recentHits($ip)) >= $this->max;
    }

    public function hit(string $ip): void
    {
        $file = $this->file($ip);
        $handle = fopen($file, 'c+');
        if ($handle === false) {
            throw new RuntimeException('Impossible d\'écrire la limite d\'envoi');
        }

        flock($handle, LOCK_EX);
        $hits = $this->filter((string) stream_get_contents($handle));
        $hits[] = time();
        ftruncate($handle, 0);
        rewind($handle);
        fwrite($handle, implode("\n", $hits));
        flock($handle, LOCK_UN);
        fclose($handle);
    }

    private function recentHits(string $ip): array
    {
        $file = $this->file($ip);

        return is_file($file) ? $this->filter((string) file_get_contents($file)) : [];
    }

    private function filter(string $content): array
    {
        $since = time() - $this->window;

        return array_values(array_filter(
            array_map('intval', array_filter(explode("\n", $content))),
            static fn (int $time): bool => $time > $since,
        ));
    }

    private function file(string $ip): string
    {
        $dir = STORAGE_DIR . '/ratelimit';
        if (!is_dir($dir) && !mkdir($dir, 0700, true) && !is_dir($dir)) {
            throw new RuntimeException('Impossible de créer ' . $dir);
        }

        return $dir . '/' . $this->bucket . '-' . hash_hmac('sha256', $ip, app_secret()) . '.log';
    }
}
