# noorwan.com : contenus de la refonte

> Document de travail du chantier « refonte de noorwan.com » (ROADMAP, 21/10/2026). Les contenus sont validés ici, page par page, avant tout code. Base existante : version de travail `noorwan.com/test/` (lot SITE-DEV V2). Le contenu actuel de `noorwan.com` (site d'auteur) rejoint la page Édition.

## État de validation

| Page | État |
|---|---|
| Accueil | **En ligne.** v1 validée le 21/10/2026 (maquette `docs/maquette/maquette-accueil-v1.dc.html`), modifiée par le lot v1.1 du 27/10/2026 : introduction Solutions et section Édition **à valider**. Une v2 est prévue plus tard. |
| Consulting | Section de l'accueil (5 expertises), pas de page propre. |
| Solutions | **En ligne, textes à valider** (lot v1.1, 27/10/2026) : `solutions.php`. Reserva, Immobilier, Shopping et page Développeurs hors site. |
| Édition | **En ligne.** Prestation (4 étapes **à valider**) et catalogue ; annonce Zahra **à valider** (27/10/2026). |
| À propos | À rédiger (hors menu). |
| Contact | En ligne. |
| Mentions légales, Confidentialité, Cookies | En ligne, **à faire relire par un juriste**. Mentions légales en cours de mise à jour (encadré). |

L'état réel du site est décrit dans « État du site au 27/10/2026 », en fin de document. Les sections intermédiaires sont l'historique des décisions.

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

## Accueil (FR, brouillon v1, historique : remplacé par la v1 validée)

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

## État du site au 27/10/2026 (lot v1.1)

Textes français tels qu'en ligne, sources dans `lang/fr.php` (EN dans `lang/en.php`, AR dans `lang/ar.php`). Les textes arabes hors maquette sont des traductions à relire par un arabophone. Marqueur dans le code : `A VALIDER PAR MARWAN`.

### Commun

- Menu : Consulting (accueil), Solutions (`solutions.php`), Édition (accueil), Contact (accueil). « À propos » hors menu.
- Choix de la langue : un bouton « FR / EN / AR » qui ouvre la liste Français, English, العربية.
- Pied de page : « Des idées pour des solutions concrètes. », liens légaux (Mentions légales, Confidentialité, Cookies).
- Bandeau de contact en bas de chaque page : « Un projet en tête ? » ; « Conseil, démonstration d'une solution ou publication d'un livre : échangeons sur vos objectifs. » ; bouton « Parlons de votre projet » (« Demander une présentation » sur la page Solutions).

### Accueil

Ordre : haut de page · trois univers · approche · Consulting · Solutions · Édition · contact.

- **Haut de page** (moins haut depuis le lot v1.1, titre sur une ligne à 1440 px) : « Noorwan · Vision & création » ; « Des idées pour des solutions concrètes » ; « Conseil, solutions numériques et édition : trois univers complémentaires pour transformer les idées en réalisations utiles. » ; boutons [Découvrir nos expertises] [Parlons de votre projet] ; « Une vision claire. Des étapes concrètes. »
- **Nos univers**, « Trois univers, une même exigence » :
  - 01 Consulting : « Clarifier votre positionnement, structurer vos priorités et piloter vos projets numériques : stratégie, marketing digital, eCommerce, formation. »
  - 02 Solutions : « Des logiciels pour les entreprises : ressources humaines, paiement mobile et intelligence artificielle. Mobiles d'abord, en trois langues. »
  - 03 Édition : « Nous accompagnons les auteurs jusqu'à la publication de leur livre sur Amazon, et nous publions nos propres collections. »
- **Notre approche**, « De l'idée à l'action » : Comprendre le besoin (Écouter avant de proposer.) · Structurer la réponse (Prioriser ce qui compte.) · Concevoir la solution (Livrer un outil utile.) · Apprendre et évoluer (Mesurer, ajuster, transmettre.).
- **Consulting**, « Donner une direction claire à vos projets » : « Un conseil stratégique et un accompagnement numérique, avec une approche pragmatique, fondés sur vingt ans de digital, de marketing et d'eCommerce. » Cinq expertises : Stratégie et structuration de projet ; Marketing digital et présence en ligne ; E-commerce et parcours client ; Développement web et outils numériques ; Formation. « Clarifier avant d'accélérer. Une étape utile livrée vaut mieux qu'un grand plan sur le papier. »
- **Solutions**, « Des outils conçus pour les entreprises » :
  - introduction **à valider** : « Des logiciels pensés pour les entreprises, conçus pour le téléphone d'abord et disponibles en trois langues. Certains sont en service, d'autres en préparation. » ; lien « Découvrir nos solutions » vers la page Solutions ;
  - cartes : Inteek (Ressources humaines, « Du recrutement à la gestion des équipes, les RH simplifiées. ») ; OnePay (Paiement) et Plateforme IA (Intelligence artificielle) marqués « Confidentiel », sans description.
- **Édition** (petit titre « Édition » depuis le lot v1.1), « Des idées à lire, découvrir et transmettre » : « Noorwan Édition accompagne les auteurs à chaque étape, jusqu'à la publication de leur livre sur Amazon. Nos propres collections, {méta}Physique et Chemins de l'Âme, en sont la preuve. » Les couvertures ont laissé place au bloc « Quatre étapes jusqu'à la publication » (mêmes textes que la page Édition, **à valider**). Boutons [Publier votre livre] [Voir le catalogue].

### Page Solutions (`solutions.php`) : textes à valider

- En-tête : étiquette « Noorwan Solutions », titre et introduction de la section Solutions de l'accueil, bouton [Demander une présentation] (formulaire, univers Solutions présélectionné).
- « Notre façon de faire » :
  - Pensés pour le téléphone d'abord : « Chaque écran est conçu pour le téléphone, puis adapté à l'ordinateur. »
  - Trois langues, dont l'arabe : « Français, anglais et arabe, avec un affichage de droite à gauche pour l'arabe. »
  - Des données protégées : « Données hébergées et protégées, accès selon le rôle de chacun. »
- Inteek (Ressources humaines) : « Les ressources humaines en modules, à activer selon les besoins de votre entreprise. » ; « Vous commencez par les modules qui comptent pour vous et ajoutez les autres quand le besoin se présente. » Modules : Recrutement et base de CV ; Enquêtes auprès des équipes ; Congés ; Pointage ; Dossiers du personnel. Ni prix, ni clients, ni chiffres.
- « Autres solutions » : OnePay et Plateforme IA, « Confidentiel », « Présentation sur rendez-vous. »

### Page Édition (`edition.php`)

- En-tête : « Noorwan Édition » ; « De votre manuscrit à votre livre sur Amazon » ; même introduction que l'accueil ; [Publier votre livre] [Voir le catalogue].
- « La prestation », « Quatre étapes jusqu'à la publication » (**à valider**) : « Un accompagnement adapté à votre projet, que vous ayez un manuscrit achevé ou un texte encore en chantier. »
  - Manuscrit : « Relecture de votre texte, conseils de structure et corrections, pour un manuscrit prêt à publier. »
  - Mise en forme : « Mise en page de l'intérieur du livre, en version imprimée et en version numérique. »
  - Couverture : « Une couverture à l'image de votre livre, aux formats demandés par Amazon. »
  - Mise en ligne : « Création de la fiche du livre sur Amazon, choix des catégories et du prix, publication. »
- Catalogue, « Nos collections » :
  - {méta}Physique : Harmonie (tome 1), Lumière (tome 2), Vibration (tome 3, « À paraître · En cours de rédaction »).
  - Chemins de l'Âme : Le Mal, Le Bien, Être pour Avoir (disponibles aussi en anglais : Evil, Good, Being vs Having).
  - Bouton « Acheter sur Amazon » par livre paru ; liens vers la recherche Amazon « noorwan » tant que les ASIN manquent.
- « Prochainement » (après les collections) : *Les belles manières du petit musulman*, Collection Zahra · Volume 1, étiquette « À paraître », sans bouton « Acheter ». Titre en français dans les trois langues ; « Zahra » reste en latin en arabe. Textes **à valider** : « Un livre de coloriage pour les enfants de 6 à 8 ans. » ; « 15 morales autour de la bienveillance, du respect et de la gratitude, un guide pour les parents et 3 niveaux de difficulté. »

### Contact et pages légales

- Contact : « Parlons de votre projet », un formulaire (nom, e-mail, téléphone facultatif, univers Consulting / Solutions / Édition / Autre, message), deux accords facultatifs non cochés (offres de Noorwan, offres de partenaires).
- Pages légales datées du 27 octobre 2026, à faire relire par un juriste. Confidentialité : demandes conservées 3 ans après la dernière demande envoyée par le formulaire ; données de limitation des envois 2 heures au plus. Cookies : aucun cookie, aucune mesure d'audience.
