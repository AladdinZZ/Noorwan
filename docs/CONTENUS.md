# noorwan.com : contenus de la refonte

> Document de travail du chantier « refonte de noorwan.com » (ROADMAP, 21/10/2026). Les contenus sont validés ici, page par page, avant tout code. Base existante : version de travail `noorwan.com/test/` (lot SITE-DEV V2). Le contenu actuel de `noorwan.com` (site d'auteur) rejoint la page Édition.

## État de validation

| Page | État |
|---|---|
| Accueil | **Validé v1 le 21/10/2026** (maquette `data/noorwan-site/maquette-accueil-v1.dc.html`, FR/EN/AR). Une v2 est prévue plus tard. |
| Consulting | À rédiger |
| Solutions (Reserva, Inteek, OnePay, plateforme IA, Développeurs) | À rédiger |
| Édition (prestation, catalogue, Nour Kids) | À rédiger |
| À propos | À rédiger |
| Contact | À rédiger |
| Mentions légales, Confidentialité | À rédiger (modèle commun Maestro) |

## Cadrage acté le 21/10/2026

- Noorwan est un groupe à vocation internationale, pas seulement technologique : ne pas écrire « djiboutien » sur le site. Trois univers : Consulting, Solutions, Édition. Bloc « Bientôt » : restauration, distribution automatique de boissons chaudes.
- Solutions : Reserva, Inteek, OnePay, plateforme IA ; Immobilier et Shopping « Bientôt » ; page Développeurs pour les API OnePay et IA.
- Édition : accompagnement des auteurs jusqu'à la publication sur Amazon, plus les collections Noorwan ({méta}Physique, Chemins de l'Âme) et Nour Kids. Liens Amazon directs par livre (le site actuel pointe vers une recherche).
- Langues FR, EN, AR (RTL), mobile first 390 px.
- Contact : un seul formulaire réel, champ « univers » pour le routage, deux cases de consentement non pré-cochées (offres Noorwan, offres partenaires), alimentant le CRM du Référentiel.
- Chat IA avec traduction FR/EN/AR : phase 2, quand la plateforme IA tourne. Phase 1 : contact direct.

- Les livres sont réels et publiés sur Amazon (Harmonie, Lumière, Le Mal, Le Bien, Être pour Avoir ; Vibration à paraître). Liens actuels : recherche Amazon « noorwan », à remplacer par les fiches de chaque livre (ASIN à fournir).
- Logo repris de /test/ : « N » + « noorwan. » + signature « CONSULTING · SOLUTIONS · ÉDITION ». Brouillon v1 ivoire et or écarté (jugé trop proche d'un style IA) ; trois directions proposées : A Bleu institution, B Monochrome et signal, C Graphite et cuivre.

## En attente de décision

- M-26 : direction artistique (maquette 3, ivoire et or).
- M-31 : nom de la plateforme IA (recommandation : NourIA).
- M-32 : registre de consentements unique (Compte Noorwan pour les personnes, Référentiel pour les entreprises), au lieu d'une table par produit.

## Accueil (FR, brouillon v1)

### Bandeau

Des idées pour des solutions concrètes.
Conseil, logiciels pour les entreprises, édition : un même groupe, une même exigence.
Boutons : [Découvrir nos univers] [Parlons de votre projet]

### Trois univers

- **01 Consulting** : 20 ans de digital, de marketing et d'eCommerce au service de vos projets. Stratégie, présence en ligne, formation.
- **02 Solutions** : des logiciels pensés pour Djibouti. Réservation, ressources humaines, paiement mobile, intelligence artificielle. Mobiles d'abord, en français, en anglais et en arabe.
- **03 Édition** : nous accompagnons les auteurs jusqu'à la publication de leur livre sur Amazon, et nous publions nos propres collections.

### Nos solutions

- **Reserva** : la prise de rendez-vous et de réservations pour les commerces et services.
- **Inteek** : les RH simplifiées, du recrutement à la gestion des équipes.
- **OnePay** : encaisser tous les portefeuilles mobiles avec un seul QR code.
- **[Plateforme IA, nom à valider]** : l'intelligence artificielle intégrée à nos solutions, avec une API pour les développeurs.
- **Bientôt** : Immobilier, Shopping.

### Notre approche

Comprendre le besoin · Structurer la réponse · Concevoir la solution · Apprendre et évoluer.

### Le groupe grandit

**Bientôt** : restauration, distribution automatique de boissons chaudes.

### Un projet en tête ?

Conseil, démonstration d'une solution ou publication d'un livre : écrivez-nous.
Bouton : [Nous contacter]

### Écarts avec /test/

- « Projets sélectionnés » (PromptEspace, Labo Tech, CEREBRO) remplacé par les produits de la carte Maestro.
- Deux blocs « Bientôt » ajoutés.
- Aucun chiffre ni nom de client tant qu'ils ne sont pas confirmés.

## Accueil v1 validé (21/10/2026)

Direction artistique (remplace la proposition ivoire et or de M-26) : reprise du style de `noorwan.com/test/`.

- Logo : le mot « noorwan. » seul (minuscules grasses, interlettrage serré, point bleu `#0071E3`), sans « N » ni signature. Toujours en latin, y compris en arabe.
- Police système Apple (SF Pro, repli Helvetica/Arial), titres graisse 650 très serrés ; IBM Plex Sans Arabic pour l'arabe (RTL).
- Couleurs de base : noir doux `#1D1D1F`, gris `#F5F5F7`, blanc, gris texte `#515154` / `#6E6E73`, doré `#F5D58A` pour les petits titres sur fond sombre.
- Code couleur des univers, discret : Consulting bronze (`#A8915F`, texte `#6F5B2E`), Solutions bleu ardoise (`#7C93B2`, texte `#3D5A80`), Édition bordeaux sourd (`#B07A84`, texte `#7D2E3B`). Bandeau fin en haut des cartes, grand numéro fin dans le ton, étiquette teintée pour les petits titres, liseré sur les cartes de section.
- Boutons rectangulaires (rayon 3 px, hauteur 48 px), flèche horizontale ; primaire noir, bleu `#0071E3` seulement en haut de page et au contact.
- Haut de page sombre avec l'image `hero.png` de /test/ (la maquette l'imite en dégradés).

Ordre de la page : haut de page · trois univers · « De l'idée à l'action » (approche) · Consulting (5 expertises, sur la même page) · Solutions · Édition · contact · pied de page.

Contenus arrêtés :
- Plus de « djiboutien » ; plus de bloc « Bientôt » restauration ou boissons ; plus de bandeau API ; un seul message en haut (« Une vision claire. Des étapes concrètes. »).
- Solutions : Inteek (ressources humaines, avec description), OnePay et Plateforme IA marqués « Confidentiel » sans description. Reserva, Immobilier, Shopping retirés du site.
- Édition : vraies couvertures (Harmonie, Lumière, Le Mal, Le Bien, Être pour Avoir), Vibration « À paraître ». Couvertures dans `data/noorwan-site/couvertures/` (non versionné). Liens Amazon par livre à fournir.
