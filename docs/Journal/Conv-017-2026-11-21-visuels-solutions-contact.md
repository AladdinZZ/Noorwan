# Conv-017 : en-tête en photo de Contact, texte alternatif de Solutions (21/11/2026)

## Objectif

Brief de Maestro (21/11/2026), d'après la demande de Marwan : « Comme pour Consulting, il faut que Solutions ait également son visuel ; pour Contact, reprendre le visuel et le mettre de la même manière que Consulting. » Branche `feat/visuels-solutions-contact` depuis `main` à jour (#12, photo de Consulting, fusionnée).

Consigne de Maestro pour cette session : faire la partie Contact ; pour Solutions, l'image n'existe pas encore, donc aucune image créée et aucun changement du code d'affichage, seulement le texte alternatif dans les trois langues et le compte des `[À FOURNIR]` des tests.

## Décisions

- **Contact, même gabarit que Consulting** : `hero_photo()` et la classe `has-photo` (image en fond, voile dégradé, même hauteur : 600 px au téléphone, 680 px dès 768 px). Titre, introduction et adresse en HTML par-dessus. Ajout d'une seule règle de couleur : l'adresse `contact@noorwan.com` (`.cta-mail`) en blanc sur la photo, comme les autres liens des en-têtes en photo.
- **Pas de 1440** : la photo de réunion n'existe qu'en 1200 x 800. Grande largeur gardée à 1200 (`contact-hero-1200.webp`, copie exacte de `contact-reunion-1200.webp`, sans nouvelle compression). Sur un écran de 1440 px, c'est le navigateur qui étire l'image (1,2 fois) pour couvrir l'en-tête, sous le voile ; aucun fichier agrandi. Une version plus grande demanderait l'image d'origine (Canva).
- **Petite largeur recadrée, pas réduite** : `contact-hero-780.webp` est un découpage de 780 x 800 au centre de l'original, sans redimensionnement. Au téléphone, l'en-tête est plus haut que large : une image réduite à 780 x 520 aurait été agrandie 2,3 fois pour le couvrir, le découpage ne l'est que 1,5 fois et garde la personne du centre nette. À 768 px, les deux personnes des bords sont coupées (comme le serait toute version pour ce cadre).
- **`hero_photo()`** prend en troisième paramètre la liste des largeurs, `[780, 1440]` par défaut : Consulting, Solutions et Édition ne changent pas ; Contact passe `[780, 1200]`.
- **Plus de photo en double** : l'inclusion de `contact-photo.php` dans l'en-tête de Contact est retirée (et la classe `wrap-photo`, devenue inutile ici). Le gabarit reste pour le bandeau de contact des autres pages, chargé à la demande. Contact n'a pas de bandeau de contact : la photo n'apparaît qu'une fois sur la page.
- **Texte alternatif de Contact** : celui de la photo de contact (`contact.photo_alt`), déjà validé. Rien de nouveau.
- **Solutions** : `solutions.hero_alt` écrit d'après la description de l'illustration donnée par Maestro. Tant que les deux fichiers manquent, `hero_photo()` rend une chaîne vide et la page garde son rendu actuel. Il reste trois `[À FOURNIR]` dans `lang/` (texte alternatif d'Édition).
- **Captures** rangées dans `docs/Audit/visuels-contact/` (avec un A majuscule, comme les dossiers d'audit existants) : un dossier `docs/audit` à côté de `docs/Audit` se confondrait sur le disque du Mac, qui ne distingue pas les majuscules.

## Ce qui a été fait (commits)

1. `Mettre la photo de réunion en en-tête de la page Contact`
2. `Écrire le texte alternatif de la photo d'en-tête de Solutions`
3. `Consigner l'en-tête en photo de Contact` (CONTENUS.md, journal, captures)

## Vérifications

- `tests/run.sh` vert, 926 contrôles : serveur intégré de PHP (`tests/router.php`, port 8010), MariaDB jetable (port 3398, droits de la CI, utilisateurs anonymes retirés), `.env` temporaire non versionné. Nouveaux contrôles : `contact-hero-780.webp` et `-1200.webp` servis, moins de 300 Ko (31 et 48 Ko), largeur exacte et hauteur de l'original (800 px, donc aucun agrandissement) ; en-tête `has-photo` avec les deux largeurs, le texte alternatif traduit, les dimensions et le titre après l'image, en français, anglais et arabe ; plus de `cta-visual` ni de `contact-reunion-` sur la page Contact ; adresse sous l'introduction et en blanc ; texte alternatif de Solutions écrit dans les trois langues ; trois `[À FOURNIR]` restants (Édition).
- Chrome sans écran (Playwright), 18 captures du haut de la page Contact dans `docs/Audit/visuels-contact/` : 390, 768 et 1440 px, français, anglais, arabe, clair et sombre. Aucun débordement horizontal, aucune erreur de console ; image choisie mesurée : 780 à 390 et 768 px, 1200 à 1440 px ; titre et adresse blancs dans les deux thèmes ; arabe de droite à gauche, photo jamais en miroir.

## Ce qui reste

- Marwan : relire et fusionner. Déposer `solutions-hero-780.webp` et `-1440.webp` quand Maestro fournit l'illustration (marche à suivre du journal Conv-015) ; le texte alternatif est prêt. Image et texte alternatif d'Édition.
- Arabe à relire par un arabophone : texte alternatif de Solutions (« رسم توضيحي: شخصان يجمّعان شاشات تطبيقات ووحدات مترابطة. »).
- Si une photo de Contact plus nette est voulue sur grand écran : fournir l'original de la photo de réunion en 1440 px au moins.
- Aucun réglage nouveau sur le VPS.

## Pièges

- Le motif de `grep` sur une chaîne PHP doit tenir compte de l'apostrophe échappée (`d\'en-tête`) : un motif avec `d'en-tête` ne trouve rien.
- Découper une partie de commit sans `git add -p` (interactif refusé ici) : écrire la version intermédiaire du fichier, valider, puis remettre la version complète.
