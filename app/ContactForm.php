<?php

declare(strict_types=1);

/**
 * Formulaire de contact : lecture des champs, validation, enregistrement dans contact_requests.
 * Les messages d'erreur sont des clés de traduction (contact.errors.*).
 */
final class ContactForm
{
    public const UNIVERSES = ['consulting', 'solutions', 'edition', 'autre'];

    private const MAX = ['name' => 120, 'email' => 190, 'phone' => 40, 'message' => 5000];

    /** @var array<string, string> champ => clé d'erreur */
    public array $errors = [];

    private function __construct(public readonly array $values)
    {
    }

    /**
     * Formulaire vide ; l'univers peut être présélectionné (?universe=edition depuis la page Édition).
     */
    public static function blank(mixed $universe = null): self
    {
        return new self([
            'name' => '',
            'email' => '',
            'phone' => '',
            'universe' => in_array($universe, self::UNIVERSES, true) ? $universe : '',
            'message' => '',
            'consent_offers' => false,
            'consent_partners' => false,
        ]);
    }

    public static function fromInput(array $input): self
    {
        $text = static fn (string $key): string => is_string($input[$key] ?? null) ? trim($input[$key]) : '';

        return new self([
            'name' => $text('name'),
            'email' => $text('email'),
            'phone' => $text('phone'),
            'universe' => $text('universe'),
            'message' => $text('message'),
            // Cases non pré-cochées : seule une case explicitement cochée vaut accord (M-32).
            'consent_offers' => ($input['consent_offers'] ?? '') === '1',
            'consent_partners' => ($input['consent_partners'] ?? '') === '1',
        ]);
    }

    public function validate(): bool
    {
        $v = $this->values;
        $this->errors = [];

        if ($v['name'] === '') {
            $this->errors['name'] = 'name_required';
        } elseif (mb_strlen($v['name']) < 2 || mb_strlen($v['name']) > self::MAX['name']) {
            $this->errors['name'] = 'name_length';
        }

        if ($v['email'] === '') {
            $this->errors['email'] = 'email_required';
        } elseif (mb_strlen($v['email']) > self::MAX['email'] || filter_var($v['email'], FILTER_VALIDATE_EMAIL) === false) {
            $this->errors['email'] = 'email_invalid';
        }

        if ($v['phone'] !== '' && preg_match('/^\+?[0-9 ().-]{6,' . self::MAX['phone'] . '}$/', $v['phone']) !== 1) {
            $this->errors['phone'] = 'phone_invalid';
        }

        if (!in_array($v['universe'], self::UNIVERSES, true)) {
            $this->errors['universe'] = 'universe_required';
        }

        if ($v['message'] === '') {
            $this->errors['message'] = 'message_required';
        } elseif (mb_strlen($v['message']) < 10 || mb_strlen($v['message']) > self::MAX['message']) {
            $this->errors['message'] = 'message_length';
        }

        return $this->errors === [];
    }

    public function save(string $lang, string $ip, string $userAgent): void
    {
        $statement = Db::pdo()->prepare(
            'INSERT INTO contact_requests
                (created_at, lang, universe, name, email, phone, message,
                 consent_offers, consent_partners, consent_text_version, ip_hash, user_agent)
             VALUES
                (:created_at, :lang, :universe, :name, :email, :phone, :message,
                 :consent_offers, :consent_partners, :consent_text_version, :ip_hash, :user_agent)'
        );

        $statement->execute([
            'created_at' => gmdate('Y-m-d H:i:s'),
            'lang' => $lang,
            'universe' => $this->values['universe'],
            'name' => $this->values['name'],
            'email' => $this->values['email'],
            'phone' => $this->values['phone'] !== '' ? $this->values['phone'] : null,
            'message' => $this->values['message'],
            'consent_offers' => (int) $this->values['consent_offers'],
            'consent_partners' => (int) $this->values['consent_partners'],
            'consent_text_version' => CONSENT_TEXT_VERSION,
            'ip_hash' => self::ipHash($ip),
            'user_agent' => $userAgent !== '' ? mb_substr($userAgent, 0, 255) : null,
        ]);
    }

    /**
     * Empreinte salée de l'IP (HMAC-SHA256 avec APP_SECRET) : permet de repérer les abus sans garder l'adresse.
     */
    public static function ipHash(string $ip): string
    {
        return hash_hmac('sha256', $ip, app_secret());
    }
}
