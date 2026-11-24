# Conv-018 : charte commune (24/11/2026)

## Objectif

Brief de Maestro « noorwan.com : charte commune » (M-116, M-118, M-119, M-120), socle commun C1 à C10, d'après Marwan : « ok va y met tout en place au complet ». Branche `feat/charte-commune` depuis `main` (ec55446). Maquettes suivies : `noorwan-accueil.dc.html`, `noorwan-menu.dc.html`.

## Décisions

- **CLAUDE.md d'abord** : il disait « noorwan.com nommé sans lien » dans l'écosystème, la charte dit « jamais le site courant ». Règle du socle : la mise à jour est proposée dans le même chantier, en commit séparé (le fichier n'a ni version ni changelog). Trois lignes : écosystème sans le site courant, en-tête et volets communs, nom « Connect ».
- **Déjà conformes, gardés** : police du système et IBM Plex Sans Arabic servie par le site (C1), jetons de couleur clairs et sombres, thème qui suit l'appareil et choix gardé (C2), boutons plats de 48 px à coins de 3 px, cartes de 28 px, logo officiel (C7). Ajoutés : jetons `--control-line`, `--scrim`, `--focus` (dans les trois blocs), champs à coins de 3 px et bord `control-line`, formulaire de contact en carte de 28 px, anneau de focus décalé de 2 px.
- **En-tête (C3)** : barre pleine largeur, Menu, logo, liens dès 900 px (au lieu de 834), langue (`<details>` gardé : marche sans script), thème (désormais toujours dans la barre ; la ligne « Passer en sombre » du menu téléphone disparaît), « Connexion ».
- **Volets (C4)** : deux couches `panel-layer` placées après l'en-tête, chacune avec un voile (`<a href="#">`) et un `<section role="dialog">`. Sans script : ancre et `:target`, la croix et le voile mènent à `#`. Avec script (`site.js`, classe `js-panels` qui coupe `:target`) : ouverture par `pushState` (l'adresse ne change pas, le retour arrière ferme), Échap, voile, croix, focus sur la croix puis rendu au bouton, tabulation gardée dans le volet, page figée (`has-panel`), le volet du menu se ferme en passant à 900 px. Propriétés logiques seulement : en arabe, le menu s'ouvre à droite et la connexion à gauche.
- **Volet du menu** : Accueil, Consulting, Solutions, Édition, Contact (Accueil et Édition comme dans la maquette ; la barre garde ses trois liens), puis l'écosystème. **Volet de connexion** : logotype Connect, titre et introduction de `/connect`, « Continuer avec Noorwan » (bleu #0071E3 fixe) et « En savoir plus ».
- **Compte (v5 bis)** : le site ne gère toujours aucun compte. « Continuer avec Noorwan » n'apparaît que si `COMPTE_LINK_ENABLED=true` (deux volets et `/connect`) ; sinon le volet de connexion présente Connect et renvoie vers sa page. Le test « aucun lien vers le Compte hors de /connect » devient « Compte lié seulement dans les deux volets, jamais dans la page ».
- **Écosystème (C5)** : liste commune `ecosystem_sites()` (bootstrap) pour le pied de page et le volet du menu ; nouvelle entrée Connect (`ECOSYSTEM_CONNECT_URL`, vide par défaut, donc masquée) ; noorwan.com n'y est plus nommé ; OnePay jamais.
- **Pied de page (C5)** : logo et phrase existante, quatre colonnes inchangées, ligne écosystème, ligne légale (« © 2026 Noorwan », Mentions légales, Confidentialité, Cookies, « Gérer les cookies » quand `GTM_ID` est réglé, comme avant). Pas de « Powered by Noorwan » (noorwan.com n'est pas un produit).
- **Textes (C8)** : « Noorwan Connect » devient « Connect » dans les trois langues ; le bouton cité dans « Pour les particuliers » devient « Continuer avec Noorwan » (AR « المتابعة باستخدام Noorwan », libellé du Compte). Libellés d'interface ajoutés : Accueil, Fermer, Connexion, Menu du site, Continuer avec Noorwan ; consignés dans `docs/CONTENUS.md`. Commentaires du code non touchés (noms techniques).
- **C9** : indexation de noorwan.com non touchée.
- **C4, recensement** : `grep` de `<dialog`, `modal`, `confirm(`, `alert(`, `window.open`, `popup` : rien sur le site, avant comme après. Le bandeau de consentement est une barre en bas de page, pas une fenêtre : gardé (M-59). Aucune fenêtre restante.
- **Captures** dans `docs/Audit/charte-commune/` et non `docs/audit/` : le Mac ne distingue pas les majuscules et `docs/Audit/` existe déjà (même choix qu'en Conv-017).

## Ce qui a été fait (commits)

1. `Adapter les conventions du site à la charte commune` (CLAUDE.md)
2. `Nommer le compte « Connect » dans les textes affichés`
3. `Mettre en place l'en-tête fixe, les volets et le pied de page communs`
4. `Contrôler la charte commune dans les tests`
5. `Consigner la charte commune` (CONTENUS.md, journal, captures)

## Vérifications

- `tests/run.sh` vert, 1 093 contrôles (928 avant) : serveur intégré de PHP (`tests/router.php`, port 8010), MariaDB jetable (port 3398, droits de la CI), `.env` temporaire non versionné. Section 5 nouvelle : ordre des boutons de l'en-tête et deux volets sur les 9 pages en 3 langues, pied de page, écosystème (pied de page et volet) sans le site courant ni OnePay, aucun « Noorwan Connect » ni « Compte Noorwan » affiché tout activé, volet de connexion, menu des langues, « Gérer les cookies », propriétés logiques, ouverture sans script, Échap et retour arrière dans `site.js`, aucune fenêtre surgissante, police unique, bouton Connect bleu, jetons.
- Chrome sans écran (Playwright, script hors dépôt), 46 contrôles de comportement en français et en arabe : menu ouvert plein écran du côté de début, focus sur la croix puis rendu, tabulation gardée, Échap, retour arrière, croix, voile, connexion de 400 px du côté de fin à 1280 px, bouton Menu masqué dès 900 px, menu des langues (ouvre, coche, toucher à côté et Échap ferment, changer de langue garde la page) ; sans script : volets ouverts par leur ancre, menu des langues natif. Aucune erreur de script.
- 71 captures : 9 pages (accueil, Consulting, Solutions, Édition, Connect, Contact, trois pages légales) à 390 px fr et ar, clair et sombre, et 1440 px fr clair ; pied de page ; volets du menu et de connexion et menu des langues (390, 768, 1440 px) ; deux volets avec le Compte en service. Écosystème rempli d'adresses d'essai `.invalid` pour les captures. Aucun débordement horizontal.

## Ce qui reste

- Marwan : relire et fusionner. Arabe à relire (الرئيسية، إغلاق، قائمة الموقع).
- VPS : ajouter `ECOSYSTEM_CONNECT_URL=` (vide tant que Connect n'est pas ouvert au public) au `.env` si on veut Connect dans l'écosystème ; rien d'autre.
- Proposition faite à Marwan (CLAUDE.md, commit 1) à valider en même temps que la fusion.

## Pièges

- `pushState` ne met pas à jour `:target` : sans la classe `js-panels`, un volet ouvert par une ancre au chargement serait resté affiché après fermeture.
- Remplacer « Noorwan Connect » dans les chaînes : en français, les guillemets « » sont suivis d'une espace insécable, et certaines chaînes ont une insécable entre « Noorwan » et « Connect » : vérifier après coup chaque phrase du bouton.
- Une capture pendant un défilement doux est floue de position : `reduced_motion='reduce'` et capture d'élément pour le pied de page, en-tête masqué.
