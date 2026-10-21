-- Base du site noorwan.com (MySQL 8, utf8mb4).
-- Création locale de la base :
--   CREATE DATABASE noorwan_site CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- puis : mysql noorwan_site < database/schema.sql
-- Utilisateurs et droits (site : INSERT ; maintenance : SELECT, DELETE) : docs/Tech-Notes/Deploiement-VPS.md.

-- Demandes reçues par le formulaire de contact. Dates en UTC.
-- ip_hash : HMAC-SHA256 de l'IP salé par APP_SECRET, jamais l'IP en clair.
-- consent_text_version : version des libellés de consentement affichés (CONSENT_TEXT_VERSION).
-- synced_at : date d'envoi vers le CRM du Référentiel (synchronisation à venir), NULL tant que non envoyé.
CREATE TABLE IF NOT EXISTS contact_requests (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    created_at DATETIME NOT NULL,
    lang CHAR(2) NOT NULL,
    universe ENUM('consulting', 'solutions', 'edition', 'autre') NOT NULL,
    name VARCHAR(120) NOT NULL,
    email VARCHAR(190) NOT NULL,
    phone VARCHAR(40) NULL,
    message TEXT NOT NULL,
    consent_offers TINYINT(1) NOT NULL DEFAULT 0,
    consent_partners TINYINT(1) NOT NULL DEFAULT 0,
    consent_text_version VARCHAR(20) NOT NULL,
    ip_hash CHAR(64) NOT NULL,
    user_agent VARCHAR(255) NULL,
    synced_at DATETIME NULL,
    PRIMARY KEY (id),
    KEY idx_contact_requests_created_at (created_at),
    KEY idx_contact_requests_email (email),
    KEY idx_contact_requests_synced_at (synced_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
