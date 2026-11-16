# Conv-009 : v5 bis, plus de « Mon compte », Noorwan Connect présenté sur sa page (16/11/2026)

## Objectif

Brief v5 bis de Maestro (16/11/2026, d'après Marwan) : le site institutionnel ne gère pas de compte. Noorwan Connect est le moyen d'entrer dans l'écosystème ; il est présenté sur `/connect`, et c'est depuis cette page seulement qu'on crée son compte ou qu'on y entre. Travail sur la branche existante `feat/v5-noorwan-connect` (demande de fusion n° 4, pas encore fusionnée), sans poussée.

## Décisions

- **« Mon compte » disparaît partout hors de `/connect`** : pastille de l'en-tête, menu mobile, pied de page, quel que soit `COMPTE_LINK_ENABLED`. La clé `nav.account` et les styles `.btn-account`, `.nav-mobile .nav-account` sont retirés (pas de code mort). `account_url()` ne sert plus qu'à `/connect`.
- **Page Solutions** : la phrase sous l'introduction (« Un seul compte pour tous les services Noorwan. Découvrir Noorwan Connect → ») mène à `/connect` et s'affiche toujours. Clés `solutions.connect_text` et `solutions.connect_link` (remplacent `account_text`), classe `.page-connect` (remplace `.page-account`).
- **Page `/connect`** : « Créer mon compte » et « J'ai déjà un compte » (lien seul, remplace « Déjà un compte ? Mon compte »), masqués avec le bandeau final tant que le Compte n'est pas en service. Dans les textes, « Mon compte » devient « votre compte Noorwan Connect » (EN « your Noorwan Connect account », AR « حسابك على Noorwan Connect »), espace insécable dans « Noorwan Connect ».
- **Arabe** : espace insécable aussi entre « اكتشف » et « Noorwan Connect », sinon le verbe restait seul en fin de ligne à 390 px.
- **Non touché** : le bloc « Écosystème Noorwan » (D63) peut toujours nommer le Compte Noorwan si `ECOSYSTEM_ACCOUNT_URL` est renseignée ; le bandeau final de `/connect` garde « Créez votre Compte Noorwan ». Deux questions pour Marwan (voir « Ce qui reste »).

## Ce qui a été fait (commits)

1. `Retirer « Mon compte » de l'en-tête, du menu mobile et du pied de page`.
2. `Mener la phrase de la page Solutions vers la page Noorwan Connect`.
3. `Garder sur /connect seuls « Créer mon compte » et « J'ai déjà un compte »` : libellés, textes des données, clé `nav.account` retirée, commentaires de `app/i18n.php` et `app/bootstrap.php`.
4. `Mettre les tests à jour : aucun lien vers le Compte hors de /connect` : section « 2 undecies » réécrite (aucun lien vers le Compte, activé ou non, sur l'accueil, Solutions, Édition, Contact, Cookies ; en-tête sans lien hors choix de langue ; menu mobile et pied de page finissent par Noorwan Connect puis Contact ; clé `nav.account` absente ; phrase de Solutions vers `/connect` dans les deux états ; trois liens réglables sur `/connect` ; site servi sans lien). Section « 2 septdecies » : « J'ai déjà un compte » et « votre compte Noorwan Connect » deux fois. Page Édition : plus aucun texte à fournir (attendu 0 au lieu de 1, depuis la page auteur Amazon du 15/11).
5. `Garder « اكتشف Noorwan Connect » sur une ligne en arabe`.
6. `Consigner l'état v5 bis du 16/11/2026 dans CONTENUS.md`.
7. Ce journal.

## Vérifications

- `tests/run.sh` vert, 523 contrôles, deux fois : `COMPTE_LINK_ENABLED` à `true` puis absent. Serveur intégré de PHP sur 127.0.0.1:8000 avec `tests/router.php`, MariaDB jetable (port 3307, utilisateurs et droits comme la CI), `.env` temporaire calqué sur la CI, retiré à la fin.
- Avant les changements, sur `22b1124`, sans base : 34 échecs, dont les trois « texte à fournir surligné (ASIN seulement) » ; tous les autres venaient de l'absence de `.env` et de MySQL.
- Captures Chrome sans tête : Solutions FR et AR à 390 px, EN à 1440 px ; `/connect` FR et AR à 390 px, lien activé. En-tête sans pastille, phrase de Solutions sur deux lignes propres, aucun débordement. Le site n'a pas de thème sombre.

## Ce qui reste

- Marwan : relire les textes (CONTENUS.md, section v5 bis) ; arabe à relire par un arabophone.
- Marwan, à trancher : le bandeau final de `/connect` doit-il dire « Créez votre compte Noorwan Connect » plutôt que « Créez votre Compte Noorwan » ? Le bloc « Écosystème Noorwan » doit-il continuer à pouvoir lier le Compte Noorwan (`ECOSYSTEM_ACCOUNT_URL`), alors que le site ne mène plus au Compte hors de `/connect` ?
- Fusion de la demande n° 4 par Marwan ; aucune action sur le VPS, aucune migration, aucun réglage nouveau.

## Pièges

- Avec la locale `C`, `printf ' '` de bash rend le texte littéral : dans `tests/run.sh`, les caractères spéciaux s'écrivent en octets (`$'\xc2\xa0'`, `$'\xe2\x81\xa6'`).
- `e()` échappe l'apostrophe en `&apos;` (ENT_HTML5) : les tests qui cherchent « J'ai déjà un compte » dans le HTML attendent `J&apos;ai`.
- `MYSQL` est appelé entre guillemets dans `tests/run.sh` : il doit nommer un exécutable seul, sans option.
