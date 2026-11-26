# Conv-024 : choix de cookies commun à tous les sites Noorwan (26/11/2026)

## Objectif

Décision M-129 de Marwan : un seul choix de cookies pour tous les sites Noorwan (règle `annexes/chartes/charte-commune/consentement.md` de Maestro, branche `docs/consentement-courbes-fidelite`). Modèle : Connect (`app/Support/Consent.php`, branche `feat/consentement-commun` du Compte). Branche `feat/consentement-commun` depuis `origin/main` (c490960).

## Ce qui a été fait

| Étape | Contenu | Commit |
|---|---|---|
| Cookie commun | `nw_consent` = `v1.a{0|1}.m{0|1}`, six mois (`Max-Age=15552000`), `Path=/`, `SameSite=Lax`, `Secure` en https, jamais `HttpOnly`, `.noorwan.com` pour noorwan.com et ses sous-domaines, sinon l'hôte seul. Fonctions `consent_parse`, `consent_choice`, `consent_cookie_options`, `consent_store`, `consent_migrate` dans `app/bootstrap.php`. | 17d6b46 |
| Ancienne valeur | « granted » devient `v1.a1.m0`, « denied » `v1.a0.m0`, recopiée à la première page vue ; sur le domaine commun, l'ancien cookie de l'hôte (même nom, HttpOnly) est effacé avant la pose. Les deux cookies reçus ensemble : la valeur commune l'emporte (lecture de l'en-tête `Cookie` entier). | 17d6b46 |
| Bandeau et volet | Bandeau en bas, pleine largeur, sans voile ni ombre : texte commun, « En savoir plus » vers Confidentialité, « Tout accepter » et « Tout refuser » (`btn-outline`, même forme), lien souligné « Choisir ». Volet `#consent-panel` de fin de ligne : interrupteurs « Mesure d'audience » et « Publicité » réglés sur le choix actuel, « Enregistrer ». « Gérer les cookies » (pied de page, page Cookies) ouvre le volet. Sans JavaScript : ancre du volet et `public/consent.php` (`all`, `none`, `custom`). `app/layout/consent-form.php` retiré. | 17d6b46 |
| Tag Manager | Rien avant `a1` ; mode consentement tout refusé par défaut, puis `analytics_storage` accordé et `ad_*` accordés seulement si `m1`. `site.js` : envoi en arrière-plan, Tag Manager chargé sur un nouvel accord, rechargement si un accord est retiré ou depuis la page Cookies. | 17d6b46 |
| Pages légales | Confidentialité : Noorwan SARL responsable, publicité seulement avec accord à part, cookie commun six mois valable pour tous les sites. Cookies : cookie commun, publicité, volet. Datées du 26 novembre 2026 (à faire relire par un juriste, comme avant). | c4e8004 |

## Vérifications

- `tests/run.sh` vert (1182 contrôles) : `php -S 127.0.0.1:8010 -t public tests/router.php`, MariaDB jetable (port 3398, droits de la CI). Nouveaux cas : sans cookie bandeau et aucun script Google ; `a1` Tag Manager, `a1.m1` publicité accordée, `a0` rien ; valeur inconnue comme sans cookie ; ancienne valeur reprise (rendu et `Set-Cookie` servi) ; domaine commun pour noorwan.com et `www.noorwan.com`, hôte seul ailleurs (et `evilnoorwan.com`) ; pas de `HttpOnly` ; `Secure` en https ; volet « Choisir » ; « Gérer les cookies ».
- Playwright (Chrome) avec `GTM_ID=GTM-TEST000`, 390 et 1440 px, clair et sombre, français et arabe : bandeau, volet ouvert par « Choisir », mesure seule enregistrée (`v1.a1.m0`, non HttpOnly), bandeau et volet fermés, Tag Manager chargé, aucune page plus large que l'écran, aucune erreur de console. Aucune requête vers Google avant le choix ni après « Tout refuser ». Sans JavaScript : volet ouvert par l'ancre, publicité seule enregistrée (`v1.a0.m1`) et retour à la page. Captures dans `Conv-024-captures/`.

## Décisions

- Le lien « En savoir plus » mène à la page Confidentialité (règle commune) ; la page Cookies reste, avec sa section « Gérer vos choix » (choix actuel et bouton vers le volet).
- En arabe, « Noorwan » s'écrit « نوروان » comme partout sur le site ; les autres textes arabes et anglais reprennent ceux de Connect.
- La publicité acceptée sans la mesure (`a0.m1`) ne charge rien : Tag Manager attend l'accord de mesure (règle commune).

## Ce qui reste

- Rien sur le Mac. VPS : aucune commande ; les visiteurs qui avaient répondu voient leur choix recopié sur `.noorwan.com` à leur prochaine visite.
- Pages légales à faire relire par un juriste (inchangé).
