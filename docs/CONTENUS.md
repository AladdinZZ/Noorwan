# noorwan.com : contenus de la refonte

> Document de travail du chantier « refonte de noorwan.com » (ROADMAP, 21/10/2026). Les contenus sont validés ici, page par page, avant tout code. Base existante : version de travail `noorwan.com/test/` (lot SITE-DEV V2). Le contenu actuel de `noorwan.com` (site d'auteur) rejoint la page Édition.

## État de validation

| Page | État |
|---|---|
| Accueil | **v2 en ligne. v3 (textes fournis, Reserva confidentiel, illustrations) sur la branche `feat/v3-textes-visuels` ; v4 (textes resserrés, méthode en trois étapes, illustrations dessinées) sur `feat/v4-textes-visuels`, à relire par Marwan avant fusion.** Voir « État du site au 11/11/2026 (v4) ». |
| Consulting | Section de l'accueil (5 expertises), pas de page propre. |
| Solutions | **En ligne, textes à valider** (lot v1.1, 27/10/2026) : `solutions.php`. Reserva, Immobilier, Shopping et page Développeurs hors site. |
| Édition | **En ligne.** Prestation (4 étapes **à valider**) et catalogue ; annonce Ikra.M **à valider** (27/10/2026). |
| À propos | À rédiger (hors menu). |
| Contact | En ligne. |
| Mentions légales, Confidentialité, Cookies | En ligne, **à faire relire par un juriste**. Mentions légales en cours de mise à jour (encadré). Confidentialité et Cookies réécrites en v2 pour la mesure d'audience avec accord (M-59), **à valider**. |

L'état de la v2 est décrit dans « État du site au 6/11/2026 (v2) », en fin de document ; l'état en ligne avant sa fusion, dans « État du site au 27/10/2026 » (complété le 30/10/2026 par le lien « Connexion »), en fin de document. Les sections intermédiaires sont l'historique des décisions.

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
- **02 Solutions** : des logiciels pensés pour Djibouti. Réservation, ressources humaines, intelligence artificielle. Mobiles d'abord, en français, en anglais et en arabe.
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
- Lien « Connexion » (EN « Sign in », AR « الدخول ») vers le Compte Noorwan, `https://compte.noorwan.com/?lang=` suivi de la langue courante (Conv-004, 30/10/2026) : dernier élément du menu, en style secondaire, et dans le pied de page. **Masqué** tant que `COMPTE_LINK_ENABLED` vaut `false` (valeur par défaut) ; Marwan le passe à `true` sur le VPS après la mise en ligne du Compte. Adresse réglable par `COMPTE_URL` dans `.env`.
- Choix de la langue : un bouton « FR / EN / AR » qui ouvre la liste Français, English, العربية.
- Pied de page : « Des idées pour des solutions concrètes. », menu (avec « Connexion » quand le lien est activé), liens légaux (Mentions légales, Confidentialité, Cookies).
- Bandeau de contact en bas de chaque page : « Un projet en tête ? » ; « Conseil, démonstration d'une solution ou publication d'un livre : échangeons sur vos objectifs. » ; bouton « Parlons de votre projet » (« Demander une présentation » sur la page Solutions).

### Accueil

Ordre : haut de page · trois univers · approche · Consulting · Solutions · Édition · contact.

- **Haut de page** (moins haut depuis le lot v1.1, titre sur une ligne à 1440 px) : « Noorwan · Vision & création » ; « Des idées pour des solutions concrètes » ; « Conseil, solutions numériques et édition : trois univers complémentaires pour transformer les idées en réalisations utiles. » ; boutons [Découvrir nos expertises] [Parlons de votre projet] ; « Une vision claire. Des étapes concrètes. »
- **Nos univers**, « Trois univers, une même exigence » :
  - 01 Consulting : « Clarifier votre positionnement, structurer vos priorités et piloter vos projets numériques : stratégie, marketing digital, eCommerce, formation. »
  - 02 Solutions : « Des logiciels pour les entreprises : réservation en ligne, ressources humaines et intelligence artificielle. Mobiles d'abord, en trois langues. »
  - 03 Édition : « Nous accompagnons les auteurs jusqu'à la publication de leur livre sur Amazon, et nous publions nos propres collections. »
- **Notre approche**, « De l'idée à l'action » : Comprendre le besoin (Écouter avant de proposer.) · Structurer la réponse (Prioriser ce qui compte.) · Concevoir la solution (Livrer un outil utile.) · Apprendre et évoluer (Mesurer, ajuster, transmettre.).
- **Consulting**, « Donner une direction claire à vos projets » : « Un conseil stratégique et un accompagnement numérique, avec une approche pragmatique, fondés sur vingt ans de digital, de marketing et d'eCommerce. » Cinq expertises : Stratégie et structuration de projet ; Marketing digital et présence en ligne ; E-commerce et parcours client ; Développement web et outils numériques ; Formation. « Clarifier avant d'accélérer. Une étape utile livrée vaut mieux qu'un grand plan sur le papier. »
- **Solutions**, « Des outils conçus pour les entreprises » :
  - introduction **à valider** : « Des logiciels pensés pour les entreprises, conçus pour le téléphone d'abord et disponibles en trois langues. Certains sont en service, d'autres en préparation. » ; lien « Découvrir nos solutions » vers la page Solutions ;
  - cartes : Inteek (Ressources humaines, « Du recrutement à la gestion des équipes, les RH simplifiées. ») ; OnePay (Paiement) et Plateforme IA (Intelligence artificielle) marqués « Confidentiel », sans description.
- **Édition** (petit titre « Édition » depuis le lot v1.1), « Des idées à lire, découvrir et transmettre » : « Noorwan Édition accompagne les auteurs à chaque étape, jusqu'à la publication de leur livre sur Amazon. Nos propres collections, {méta}Physique et Chemins de l'Âme, en sont la preuve. » Les couvertures ont laissé place au bloc « Quatre étapes jusqu'à la publication » (mêmes textes que la page Édition, **à valider**). Boutons [Publier votre livre] [Voir le catalogue].

### Page Solutions (`solutions.php`) : textes à valider

- En-tête : étiquette « Noorwan Solutions », titre et introduction de la section Solutions de l'accueil, bouton [Demander une présentation] (formulaire, univers Solutions présélectionné).
- Sous l'introduction, quand le lien « Connexion » est activé : « Un seul compte pour tous les services Noorwan. » suivi du lien « Connexion » (EN « One account for all Noorwan services. », AR « حساب واحد لجميع خدمات نوروان. », à relire par un arabophone).
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
- « Prochainement » (après les collections) : *Les belles manières du petit musulman*, Collection Ikra.M · Volume 1, étiquette « À paraître », sans bouton « Acheter ». Titre en français dans les trois langues ; « Ikra.M » reste en latin dans les trois langues. Textes **à valider** : « Un livre de coloriage pour les enfants de 6 à 8 ans. » ; « 15 morales autour de la bienveillance, du respect et de la gratitude, un guide pour les parents et 3 niveaux de difficulté. »

### Contact et pages légales

- Contact : « Parlons de votre projet », un formulaire (nom, e-mail, téléphone facultatif, univers Consulting / Solutions / Édition / Autre, message), deux accords facultatifs non cochés (offres de Noorwan, offres de partenaires).
- Pages légales datées du 27 octobre 2026, à faire relire par un juriste. Confidentialité : demandes conservées 3 ans après la dernière demande envoyée par le formulaire ; données de limitation des envois 2 heures au plus. Cookies : aucun cookie, aucune mesure d'audience.

## État du site au 6/11/2026 (v2, branche `feat/site-v2`, à relire avant fusion)

Direction visuelle : maquette A épurée (M-56), validée par Marwan le 6/11/2026. Les textes ci-dessous reprennent ceux de l'état du 27/10/2026 ; seuls les éléments nouveaux sont listés. Textes nouveaux **à valider** ; arabe à relire par un arabophone.

### Commun

- Menu : Consulting (accueil), Solutions, Édition (page Édition), Contact (page Contact). « Connexion » devient une pastille noire dans la barre (et le dernier lien du menu mobile, et la colonne Noorwan du pied de page), toujours masquée tant que `COMPTE_LINK_ENABLED` vaut `false`.
- Pied de page en quatre colonnes : Consulting (Découvrir nos expertises, Parlons de votre projet), Solutions (Découvrir nos solutions, Demander une présentation), Édition (Voir le catalogue, Publier votre livre), Noorwan (Contact, Connexion). Puis « Écosystème Noorwan » (D63 : Noorwan, Compte Noorwan, Reserva, Inteek ; entrée sans adresse masquée), puis « Des idées pour des solutions concrètes. », « © année Noorwan », liens légaux et « Gérer les cookies ».
- Bandeau « Un projet en tête ? » : même texte, bouton bleu, adresse contact@noorwan.com dessous.
- Bandeau de consentement (M-59), seulement si `GTM_ID` est réglé : « Mesure d'audience » ; « Avec votre accord, nous mesurons la fréquentation du site de façon statistique (Google Analytics), sans publicité. Votre choix est gardé six mois. » ; « En savoir plus » ; [Refuser] [Accepter], de même poids.

### Accueil

Ordre : haut de page · Consulting (01) · Solutions (02) · Édition (03) · produits · {méta}Physique · Pourquoi Noorwan · contact.

- Haut de page : petit titre « Consulting, Solutions, Édition » ; titre « Une vision claire. » puis, en gris, « Des étapes concrètes. » ; accroche « Conseil, solutions numériques et édition : trois univers complémentaires pour transformer les idées en réalisations utiles. » ; liens « Découvrir nos expertises › » et « Parlons de votre projet › » ; image sombre avec « noorwan. ».
- 01 Consulting : « Clarifier avant d'accélérer. », introduction du Consulting, les cinq expertises, « Une étape utile livrée vaut mieux qu'un grand plan sur le papier. », lien « Parlons de votre projet ».
- 02 Solutions : « Des outils conçus pour les entreprises », texte de l'univers Solutions, « Découvrir nos solutions ».
- 03 Édition : « Des idées à lire, découvrir et transmettre », texte de l'univers Édition, « En savoir plus ».
- Produits (brief M-56) : Reserva (Réservation, « La prise de rendez-vous et de réservations pour les commerces et services. », texte du brouillon du 21/10), Inteek (Ressources humaines), Noor (Intelligence artificielle, « Confidentiel », « Présentation sur rendez-vous. »), Noorwan Édition (texte de l'univers). Ligne « Bientôt : Immobilier, Shopping ». OnePay n'apparaît nulle part.
- {méta}Physique : couvertures d'Harmonie et Lumière, Vibration « À paraître », « Chemins de l'Âme : Le Mal, Le Bien, Être pour Avoir », liens catalogue et « Publier votre livre ». **[À FOURNIR : phrase d'auteur]**.
- Pourquoi Noorwan : « De l'idée à l'action », **[À FOURNIR : texte « Pourquoi Noorwan » (chiffres clés à confirmer)]**, puis les quatre étapes de l'approche.

### Pages

- Solutions : en-tête, « Notre façon de faire » (trois principes), mêmes produits que l'accueil, Inteek en détail (modules). « Autres solutions » disparaît.
- Édition : en-tête, prestation en quatre étapes sur fond sombre, catalogue. **[À FOURNIR : ASIN des cinq livres parus]** sous le titre du catalogue ; **[À FOURNIR : phrase d'auteur]** sous la présentation de {méta}Physique.
- Contact : même formulaire sur un panneau blanc ; adresse contact@noorwan.com sous l'introduction.
- Confidentialité et Cookies (datées du 6 novembre 2026) : mesure d'audience par Google Analytics seulement avec accord ; cookie `nw_consent` six mois ; cookies `_ga` 13 mois au plus ; données dans Google Analytics 14 mois au plus ; Google Ireland Limited comme sous-traitant, transfert possible aux États-Unis (Data Privacy Framework) ; retrait par « Gérer les cookies » ; section « Gérer vos choix » sur la page Cookies. Mentions légales : la phrase « aucun cookie » renvoie désormais à la page Cookies.

## État du site au 10/11/2026 (v3, branche `feat/v3-textes-visuels`, à relire avant fusion)

Brief v3 de Maestro du 7/11/2026. Textes nouveaux **à valider** par Marwan ; arabe à relire par un arabophone. Seuls les changements par rapport à la v2 sont listés.

### Reserva confidentiel (décision de Marwan, 7/11)

- Carte Reserva (accueil et page Solutions) : catégorie « Réservation », pastille « Confidentiel », « Présentation sur rendez-vous. », comme Noor. Plus aucune description de Reserva sur le site (contrôlé par `tests/run.sh`).

### Phrase d'auteur de {méta}Physique (accueil et catalogue)

Tirée des présentations publiques d'Harmonie et de Lumière (science et spiritualité, origine du monde, conscience humaine, raison, foi et mystère) ; rien n'est ajouté sur le contenu.

- FR : « Une trilogie entre science et spiritualité : de l'origine du monde à la conscience humaine, elle cherche le fil qui relie la raison, la foi et le mystère. »
- EN : « A trilogy between science and spirituality: from the origin of the world to human consciousness, it seeks the thread that links reason, faith and mystery. »
- AR : « ثلاثية بين العلم والروحانية: من أصل العالم إلى الوعي الإنساني، تبحث عن الخيط الذي يجمع العقل والإيمان والسر. »

### Pourquoi Noorwan (accueil, au-dessus des quatre étapes)

Aucun chiffre.

- Accroche : « Un groupe qui relie le conseil, le logiciel et l'édition avec une même méthode : partir du besoin réel et livrer ce qui sert. »
- Né à Djibouti, ouvert sur le monde : « Noorwan est né à Djibouti et se construit avec une vocation internationale. »
- Trois univers qui se répondent : « Conseil, logiciel et édition se nourrissent : ce que nous apprenons dans un univers sert les deux autres. »
- Des outils pensés pour l'Afrique : « Nos solutions sont conçues pour le téléphone d'abord, en français, en anglais et en arabe. »

EN et AR dans `lang/en.php` et `lang/ar.php`.

### Liens Amazon

- Harmonie : ASIN `B0F91W6361` (fiche amazon.fr « Harmonie: Science et spiritualité : Aux frontières de la matière et de la conscience », auteur Noorwan), lien direct.
- Lumière, Le Mal, Le Bien, Être pour Avoir : **[À FOURNIR : ASIN]**, boutons vers la recherche « noorwan » en attendant. Des ASIN relevés sur un catalogue tiers (ThriftBooks) sont listés dans le retour à Maestro, non vérifiés sur Amazon ; aucune trace de « Le Bien » trouvée.

### Illustrations des produits

Une illustration SVG par carte dans `public/assets/img/` (moins de 3 ko chacune, sans texte ni logo) : Inteek, fiche candidat et carte d'entretien sur un téléphone ; Noorwan Édition, livre ouvert ; Reserva et Noor, compositions abstraites (plans superposés, source de lumière). Inteek et le livre sont en miroir en arabe. Pas de carte OnePay.

## État du site au 11/11/2026 (v4, branche `feat/v4-textes-visuels`, à relire avant fusion)

Brief v4 de Maestro du 11/11/2026. Seuls les changements par rapport à la v3 sont listés. Tous les textes ci-dessous sont **à valider** par Marwan ; arabe et anglais à relire. Aucun chiffre ajouté ; « vingt ans » était déjà en ligne.

### Accueil

Ordre : haut de page · Consulting (01) · Solutions (02) · Édition (03) · **De l'idée à l'action** (nouvelle section) · produits · {méta}Physique · Pourquoi Noorwan · contact.

- Haut de page (devise inchangée). Accroche, aussi description de la page pour les moteurs : « Nous conseillons les entreprises, nous concevons leurs logiciels et nous publions des livres. Toujours de la même façon : partir d'un besoin réel, livrer vite, améliorer ensuite. »
- Consulting, texte de l'univers : « Clarifier votre positionnement, choisir vos priorités et mener vos projets numériques jusqu'au résultat : stratégie, marketing digital, eCommerce, formation. »
- Consulting, introduction : « Vingt ans de digital, de marketing et d'eCommerce au service d'une question simple : quelle est la prochaine étape utile pour votre projet ? »
- Les cinq expertises (titres inchangés) :
  - Stratégie et structuration de projet : « Fixer l'objectif, choisir les priorités et découper le projet en étapes tenables. »
  - Marketing digital et présence en ligne : « Un positionnement clair, des contenus réguliers, des campagnes suivies. »
  - E-commerce et parcours client : « Une boutique en ligne simple à utiliser, du choix du produit au paiement. » (remplace « qui convertissent », promesse sans preuve)
  - Développement web et outils numériques : « Sites, applications et outils internes, construits pour être entretenus. »
  - Formation : « Des séances pratiques pour que vos équipes se servent elles-mêmes des outils, sur site ou à distance. »
- Solutions : titre « Des logiciels pour le travail de chaque jour » (aussi titre de la page Solutions) ; texte de l'univers « Des logiciels pour les tâches qui reviennent chaque jour : réservation, ressources humaines, intelligence artificielle. Sur téléphone d'abord, en trois langues. » ; introduction de la page Solutions « Des logiciels pensés pour le téléphone d'abord, en français, en anglais et en arabe. Certains sont en service, d'autres en préparation. »
- Édition : titre « Des livres, du manuscrit à Amazon » ; texte « De la relecture du manuscrit à la mise en ligne sur Amazon, nous accompagnons les auteurs. Et nous publions nos propres collections. »
- **De l'idée à l'action** (remplace les quatre étapes de la v1, sur fond clair, une illustration par étape) : « C'est notre méthode pour un conseil, un logiciel ou un livre. »
  1. Partir du terrain : « Nous regardons d'abord comment vous travaillez aujourd'hui et ce qui vous fait perdre du temps. Le besoin réel passe avant l'idée. »
  2. Construire vite : « Une première version simple, mise rapidement entre les mains des personnes qui s'en serviront. On apprend plus en l'utilisant qu'en la décrivant. »
  3. Faire tourner, puis améliorer : « Une fois en service, nous écoutons les retours, corrigeons et ajoutons ce qui manque, une étape après l'autre. »
- Pourquoi Noorwan : nouveau titre « Trois métiers, une même exigence » (le titre « De l'idée à l'action » passe à la méthode) ; accroche et trois points inchangés.
- Bandeau de contact (toutes les pages) : « Un conseil, une démonstration ou un livre à publier : dites-nous où vous en êtes, nous vous répondons. »

### Page Édition

- Introduction de la prestation : « Votre manuscrit est terminé ou encore en chantier : nous reprenons là où vous en êtes. »

### Illustrations (`public/assets/img/`)

Même trait que les illustrations de produits de la v3 : formes pleines, coins arrondis, palette de chaque univers, sans texte ni logo, moins de 4 ko chacune, en miroir en arabe.

- `hero.svg` : une lampe de bureau éclaire trois objets posés sur une table, un plan de route sur un chevalet (Consulting), un téléphone (Solutions), des livres (Édition). Remplace l'image sombre `hero.webp`, supprimée.
- `universe-consulting.svg` (carte déroulée, itinéraire en étapes, boussole, crayon), `universe-solutions.svg` (portable et téléphone, même interface, sur fond nuit), `universe-edition.svg` (feuilles du manuscrit et stylo, livre imprimé et liseuse).
- `step-field.svg` (boutique et bulle de parole), `step-build.svg` (écran assemblé bloc par bloc), `step-improve.svg` (téléphone en service dans une boucle de retours).
- `contact.svg` : enveloppe ouverte et bulle de réponse, dans le bandeau de contact et en tête de la page Contact.
