# Conv-019 : lanceur des sites (24/11/2026)

## Objectif

Brief de Maestro « noorwan.com : lanceur des sites » (M-121), socle commun L1 à L6. Branche `feat/lanceur` depuis `main` (05e7bfb). Dessin repris du lanceur de Reserva (branche `feat/lanceur`, Conv 181), adapté à ce site PHP sans framework.

## Décisions

- **Un volet de plus, pas un composant à part** : le lanceur est une troisième couche `panel-layer` (`#launcher-panel`, `panel-end panel-launcher`). Il hérite de tout `site.js` (ouverture sans changer l'adresse, Échap, voile, croix, retour arrière, focus gardé puis rendu) et de l'ouverture par l'ancre sans JavaScript. Aucun script ajouté.
- **Panneau dès 640 px** (même seuil que Reserva) : la feuille replace le volet sous l'en-tête, 344 px, aligné sur la fin de ligne de l'écran (à gauche en arabe), voile transparent qui garde la fermeture par un toucher à côté. Il n'est pas aligné au pixel sur le bouton : l'en-tête a un `backdrop-filter`, un élément fixe ne peut pas y vivre, et placer le panneau en script demanderait un style en ligne.
- **Liste publique seulement** : noorwan.com n'a pas de session Connect (brief, point 2). `launcher_sites()` (bootstrap) : noorwan.com toujours présent, marqué (`aria-current`, fond doux), vers l'accueil dans la langue courante ; Connect, Reserva, Inteek par `LAUNCHER_*_URL`, puis les anciennes `ECOSYSTEM_*_URL` en repli ; https seulement ; entrée sans adresse masquée. Couleurs et lettres de Connect (contrat L4) : n et C en bleu #0071E3, r en #0F6F66, i en #A85A00. Pastilles en SVG, couleur par l'attribut `fill` (CSP sans style en ligne).
- **« Mon compte Connect »** : vers l'adresse de Connect du lanceur, masqué sans elle. Jamais déduite de `COMPTE_URL` : la règle v5 bis (le site ne lie le Compte que par « Continuer avec Noorwan » et `/connect`) reste vraie tant que `LAUNCHER_CONNECT_URL` est vide.
- **Écosystème retiré** : `app/layout/ecosystem.php`, le bloc du volet du menu, les styles `.ecosystem` et les clés `ecosystem.*` (remplacées par `launcher.*`). Le trait au-dessus de la ligne légale existait déjà.
- **Thème (L6)** : `theme-init.js` garde le choix dans le cookie `nw_theme` (182 jours, `Path=/`, `SameSite=Lax`, `Secure` en https) au lieu de `localStorage` ; un ancien choix de `localStorage` est repris une fois puis effacé. L'écoute `storage` entre onglets disparaît (un cookie ne la déclenche pas).
- **Page Cookies** : elle disait `nw_consent` seul cookie. Une section `nw_theme` est ajoutée dans les trois langues avec `[À COMPLÉTER]` (surligné), le texte n'étant pas dans `docs/CONTENUS.md` : à fournir par Marwan, avec la relecture juridique déjà prévue. L'introduction de la page n'est pas touchée.
- **Libellés** : « Sites Noorwan », « Mon compte Connect » et leurs traductions anglaise et arabe sont ceux de Reserva.

## Ce qui a été fait (commits)

1. `Adapter les conventions du site au lanceur des sites` (CLAUDE.md)
2. `Ajouter le lanceur des sites et retirer la ligne écosystème`
3. `Garder six mois le thème choisi par un visiteur`
4. `Contrôler le lanceur des sites et le cookie du thème`
5. `Consigner le lanceur des sites` (CONTENUS.md, journal, captures)

## Vérifications

- `tests/run.sh` sur le serveur intégré de PHP (`tests/router.php`, port 8010) : 1 091 contrôles passés ; 10 échecs, tous dus à la base absente dans ce conteneur (envoi du formulaire, purge des demandes : `Connection refused`), sans rapport avec le chantier. Section 2 quindecies réécrite pour le lanceur (liste vide, ordre, adresses, repli, https, `COMPTE_URL` jamais utilisée, OnePay, plus d'écosystème, traductions, feuille) ; section 5 : ordre de l'en-tête avec le lanceur, trois volets ; thème : cookie de six mois et section de la page Cookies.
- Chrome sans écran (Playwright, script hors dépôt), 182 contrôles : fr, en, ar à 390, 768 et 1440 px ; en-tête sur une ligne de 48 px et aucun débordement (accueil, Contact, Cookies) ; bouton de 44 px ; ouverture avec `aria-expanded`, plein écran à 390 px, panneau sous l'en-tête en fin de ligne à 768 et 1440 px ; trois tuiles par ligne ; focus sur la croix puis rendu au bouton ; Échap, retour arrière, toucher à côté et croix ferment ; adresse inchangée ; sans JavaScript, ouverture par l'ancre et fermeture ; thème : cookie `nw_theme` de six mois, rien dans `localStorage`, gardé au rechargement, effacé au retour au thème de l'appareil, ancien choix repris. Aucune erreur de script.
- Captures dans `docs/Audit/charte-commune/` : lanceur ouvert à 390 px (fr, ar, clair, sombre), 768 px fr clair, 1440 px fr clair et ar sombre ; en-tête à 390 px fr et ar ; pied de page sans écosystème à 390 px fr clair et sombre. Adresses d'essai `.invalid` pour les captures.

## Ce qui reste

- Marwan : relire et fusionner ; texte de la section `nw_theme` de la page Cookies (trois langues) ; arabe à relire (مواقع Noorwan، حسابي في Connect).
- VPS : dans `.env`, `LAUNCHER_CONNECT_URL`, `LAUNCHER_RESERVA_URL`, `LAUNCHER_INTEEK_URL` quand ces sites sont ouverts au public (sans elles, les `ECOSYSTEM_*_URL` déjà en place servent ; vides, seul noorwan.com paraît).

## Pièges

- Un élément `position: fixed` placé dans l'en-tête serait enfermé par son `backdrop-filter` : le panneau reste une couche hors de l'en-tête.
- Insertion dans les tableaux de `lang/` : chercher la fin d'une section par `"\n                ],\n"` et non `"                ],\n"`, qui trouve d'abord la fin d'un `body` plus indenté.
