<?php

declare(strict_types=1);

require __DIR__ . '/../app/bootstrap.php';

// Page Contact : formulaire réel, enregistré en base. Aucun e-mail envoyé en v1.
current_page('contact');
$meta = ['title' => raw('meta.contact_title'), 'description' => raw('meta.contact_description')];

$form = ContactForm::blank($_GET['universe'] ?? null);
$notice = null;
$sent = isset($_GET['sent']);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $form = ContactForm::fromInput($_POST);
    $ip = (string) ($_SERVER['REMOTE_ADDR'] ?? '');
    $limit = new RateLimit('contact', 5, 3600);

    if (!Csrf::isValid('contact', $_POST['token'] ?? null)) {
        http_response_code(400);
        $notice = 'expired';
    } elseif ($limit->isExceeded($ip)) {
        http_response_code(429);
        header('Retry-After: 3600');
        $notice = 'rate_limited';
    } elseif (($_POST['website'] ?? '') !== '') {
        // Champ piège rempli : un robot. Réponse identique à un succès, rien n'est enregistré.
        $limit->hit($ip);
        header('Location: ' . url('contact', '', ['sent' => 1]), true, 303);
        exit;
    } elseif (!$form->validate()) {
        http_response_code(422);
    } else {
        try {
            $form->save(lang(), $ip, (string) ($_SERVER['HTTP_USER_AGENT'] ?? ''));
            $limit->hit($ip);
            header('Location: ' . url('contact', '', ['sent' => 1]), true, 303);
            exit;
        } catch (Throwable $exception) {
            error_log('Formulaire de contact : ' . $exception->getMessage());
            http_response_code(500);
            $notice = 'server';
        }
    }
}

$errors = $form->errors;
$v = $form->values;

// Attributs d'accessibilité d'un champ : lien vers son message d'erreur.
$invalid = static fn (string $field): string => isset($errors[$field])
    ? ' aria-invalid="true" aria-describedby="' . e($field) . '-error"'
    : '';
$errorText = static fn (string $field): string => isset($errors[$field])
    ? '<p class="field-error" id="' . e($field) . '-error">' . t('contact.errors.' . $errors[$field]) . '</p>'
    : '';

require ROOT_DIR . '/app/layout/header.php';
?>
<section class="page-hero" aria-labelledby="page-title">
    <div class="wrap">
        <p class="eyebrow"><?= t('contact.tag') ?></p>
        <h1 id="page-title"><?= t('contact.title') ?></h1>
        <p class="page-lead"><?= t('contact.lead') ?></p>
    </div>
</section>

<section class="section contact-section">
    <div class="wrap contact-wrap">
<?php if ($sent): ?>
        <div class="alert alert-success" role="status" tabindex="-1" data-autofocus>
            <p class="alert-title"><?= t('contact.success_title') ?></p>
            <p><?= t('contact.success_text') ?></p>
            <p><a href="<?= e(url('contact')) ?>"><?= t('contact.success_again') ?></a></p>
        </div>
<?php else: ?>
<?php if ($notice !== null || $errors !== []): ?>
        <div class="alert alert-error" role="alert" tabindex="-1" data-autofocus>
            <p class="alert-title"><?= t('contact.errors_title') ?></p>
            <p><?= $notice !== null ? t('contact.errors.' . $notice) : t('contact.errors_summary') ?></p>
<?php if ($errors !== []): ?>
            <ul>
<?php foreach ($errors as $field => $error): ?>
                <li><a href="#field-<?= e($field) ?>"><?= t('contact.errors.' . $error) ?></a></li>
<?php endforeach; ?>
            </ul>
<?php endif; ?>
        </div>
<?php endif; ?>
        <form class="contact-form" method="post" action="<?= e(url('contact')) ?>" aria-label="<?= t('contact.form_label') ?>" novalidate>
            <input type="hidden" name="token" value="<?= e(Csrf::token('contact')) ?>">
            <p class="form-note"><?= t('contact.required_note') ?></p>

            <div class="field">
                <label for="field-name"><?= t('contact.name') ?></label>
                <input id="field-name" name="name" type="text" autocomplete="name" maxlength="120" required value="<?= e($v['name']) ?>"<?= $invalid('name') ?>>
                <?= $errorText('name') ?>
            </div>

            <div class="field-row">
                <div class="field">
                    <label for="field-email"><?= t('contact.email') ?></label>
                    <input id="field-email" name="email" type="email" autocomplete="email" maxlength="190" required dir="ltr" value="<?= e($v['email']) ?>"<?= $invalid('email') ?>>
                    <?= $errorText('email') ?>
                </div>
                <div class="field">
                    <label for="field-phone"><?= t('contact.phone') ?> <span class="optional">(<?= t('contact.optional') ?>)</span></label>
                    <input id="field-phone" name="phone" type="tel" autocomplete="tel" maxlength="40" dir="ltr" value="<?= e($v['phone']) ?>"<?= $invalid('phone') ?>>
                    <?= $errorText('phone') ?>
                </div>
            </div>

            <div class="field">
                <label for="field-universe"><?= t('contact.universe') ?></label>
                <select id="field-universe" name="universe" required<?= $invalid('universe') ?>>
                    <option value=""><?= t('contact.universe_placeholder') ?></option>
<?php foreach (ContactForm::UNIVERSES as $universe): ?>
                    <option value="<?= e($universe) ?>"<?= $v['universe'] === $universe ? ' selected' : '' ?>><?= t('contact.universes.' . $universe) ?></option>
<?php endforeach; ?>
                </select>
                <?= $errorText('universe') ?>
            </div>

            <div class="field">
                <label for="field-message"><?= t('contact.message') ?></label>
                <textarea id="field-message" name="message" rows="6" maxlength="5000" required<?= $invalid('message') ?>><?= e($v['message']) ?></textarea>
                <?= $errorText('message') ?>
            </div>

            <!-- Champ piège : invisible pour les personnes, rempli par les robots. -->
            <div class="hp" aria-hidden="true">
                <label for="field-website"><?= t('contact.honeypot') ?></label>
                <input id="field-website" name="website" type="text" tabindex="-1" autocomplete="off" value="">
            </div>

            <fieldset class="consents">
                <legend><?= t('contact.consents_legend') ?></legend>
                <label class="check">
                    <input type="checkbox" name="consent_offers" value="1"<?= $v['consent_offers'] ? ' checked' : '' ?>>
                    <span><?= t('contact.consent_offers') ?></span>
                </label>
                <label class="check">
                    <input type="checkbox" name="consent_partners" value="1"<?= $v['consent_partners'] ? ' checked' : '' ?>>
                    <span><?= t('contact.consent_partners') ?></span>
                </label>
                <p class="form-note"><?= t('contact.consent_hint') ?></p>
            </fieldset>

            <div class="form-submit">
                <button class="btn btn-blue" type="submit"><?= t('contact.submit') ?> <span aria-hidden="true"><?= t('common.arrow') ?></span></button>
                <p class="form-note"><?= t('contact.privacy_note') ?> <a href="<?= e(url('confidentialite')) ?>"><?= t('contact.privacy_link') ?></a></p>
            </div>
        </form>
<?php endif; ?>
    </div>
</section>
<?php require ROOT_DIR . '/app/layout/footer.php';
