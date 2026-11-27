# Conv-027 : proposer l'installation à chaque visite (27/11/2026)

## Objectif

Décision de Marwan du 27/11/2026 sur la barre « Installer l'application Noorwan » (M-132), changement commun aux sites Noorwan (M-128) : « je veux qu'on la propose à chaque fois ». Branche `fix/installer-sans-plus-tard` depuis `origin/main`.

## Décisions

- **« Plus tard »** ferme la barre pour la page en cours seulement, sans cookie ; la barre revient à chaque visite sur l'accueil et à l'arrivée par `?via=qr` ou `?via=launcher`. `install_postponed()`, `INSTALL_COOKIE` et `INSTALL_MAX_AGE` retirés ; `install_auto()` ne dépend plus que de la page.
- **Ancien cookie** `nw_install_later` : plus lu ; `install_forget_legacy()` (`app/bootstrap.php`, après `consent_migrate()`) l'efface une fois côté serveur, hôte seul, `Path=/`, `SameSite=Lax`, comme il avait été posé. Fait côté serveur, comme la reprise de l'ancien choix des cookies : marche sans JavaScript et le nom ne paraît plus dans les pages.
- **Page Cookies** : section `nw_install_later` retirée dans les trois langues ; `docs/CONTENUS.md` et `CLAUDE.md` suivent (avec `nw_consent`, seuls cookies du site hors Google Analytics).
- **Inchangé** : jamais avec le bandeau des cookies, jamais en mode application ni dans l'application Android, Android après `beforeinstallprompt`, mode d'emploi iPhone, entrée du volet du menu.

## Fait

- `app/bootstrap.php`, `app/layout/install.php` (plus de `data-cookie`, `data-max-age`, `data-secure`), `public/assets/js/site.js` (« Plus tard » appelle seulement `hide()`), `lang/{fr,en,ar}.php`, `docs/CONTENUS.md`, `CLAUDE.md`.
- `tests/run.sh` : la barre revient avec l'ancien cookie (accueil, `?via=qr`, `?via=launcher`) ; l'ancien cookie est effacé (en-tête `Set-Cookie` à `Max-Age=0`, `path=/`), rien n'est posé sans lui ; le script ne pose aucun cookie ; la page Cookies ne le cite plus. Tous les tests passent (MariaDB locale sur le port de `.env`).

## Reste

- Rien sur le VPS (pas de base touchée) ; le déploiement suit la fusion.

## Pièges

- Sans base MySQL, `tests/run.sh` rapporte 10 échecs du formulaire et de la purge, sans lien avec ce chantier : lancer la base avant.
