# Conv-012 : v8, « Nos savoir-faire », accompagnement à l'écriture (18/11/2026)

## Objectif

Brief v8 de Maestro (18/11/2026, réponses de Marwan) : point « Nos savoir-faire », retrait des quatre phrases qui nomment conseil, logiciel et édition, titre de contact avant la photo sur téléphone, texte de l'accompagnement à l'écriture. Branche `feat/v8-savoir-faire` depuis `main` à jour (v7 fusionnée), sans poussée.

## Décisions

- **« Nos savoir-faire »** : le brief parle du titre « qui disait Trois métiers, devenu Des expertises qui se répondent en v7 ». « Trois métiers » était le titre de la section (« Une même exigence, quel que soit le projet » depuis la v7) ; « Des expertises qui se répondent » est le titre du point 2. Le libellé exact cité désigne le point 2 : c'est lui qui change. Le titre de la section reste inchangé. À confirmer par Marwan.
- **Phrases retirées** : seule la partie qui nomme les trois activités est supprimée, le reste est gardé mot pour mot (aucun mot ajouté). L'introduction de la méthode disparaît entièrement, son paragraphe aussi. La description pour les moteurs de recherche, copie de l'introduction, suit. Le titre de l'onglet du navigateur n'est pas une phrase : inchangé.
- **Titre avant la photo** : la photo suit le titre dans le document (ordre lu sur téléphone et par les lecteurs d'écran) ; à partir de 768 px, `.wrap-photo` passe en colonne flexible et la photo remonte (`order: -1`), donc grand écran et tablette inchangés. Bandeau de contact et page Contact.
- **Accompagnement à l'écriture** : texte de Marwan, espaces insécables avant « : » et « ; » ; traductions anglaise et arabe (littéraire) de l'exécutant. `todo()` reste dans `app/i18n.php` : c'est la convention du dépôt pour tout texte à fournir.

## Ce qui a été fait (commits)

1. `Renommer le point « Nos savoir-faire » et retirer les phrases qui nomment les trois activités`
2. `Remplacer le texte à fournir de l'accompagnement à l'écriture`
3. `Placer le titre de contact avant la photo sur téléphone`
4. `Mettre les tests à jour pour la v8`
5. `Consigner l'état v8 dans CONTENUS.md et le journal de séance`

## Vérifications

- `tests/run.sh` vert, 652 contrôles (635 en v7) : serveur intégré de PHP (127.0.0.1:8018, `tests/router.php`), MariaDB jetable (port 3318, utilisateurs et droits de la CI), `.env` temporaire retiré à la fin. Nouveaux contrôles : aucun « À FOURNIR » dans `lang/`, texte de l'écriture non surligné, « Nos savoir-faire » dans les trois langues, phrases retirées absentes de l'accueil, méthode sans introduction, titre puis photo dans le document, photo au-dessus à partir de 768 px.
- Captures (Chromium sans tête, Playwright) à 390 px en FR, EN, AR (accueil, Consulting, Contact), à 768 et 1440 px en FR, et 1440 px en AR. Aucun débordement horizontal.

## Ce qui reste

- Marwan : confirmer que « Nos savoir-faire » remplace bien le point 2 (et non le titre de la section) ; relire les phrases raccourcies et la traduction arabe.
- Fusion par Marwan ; aucune migration, aucun réglage nouveau sur le VPS.

## Pièges

- `lang/ar.php` a deux clés `writing` (`edition.writing` « قيد الكتابة » et `consulting.writing`) et le texte arabe de l'écriture contient lui-même « قيد الكتابة » : viser la clé par sa section, pas par un mot.
