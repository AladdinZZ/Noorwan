# noorwan.com : contenus de la refonte

> Document de travail du chantier « refonte de noorwan.com » (ROADMAP, 21/10/2026). Les contenus sont validés ici, page par page, avant tout code. Base existante : version de travail `noorwan.com/test/` (lot SITE-DEV V2). Le contenu actuel de `noorwan.com` (site d'auteur) rejoint la page Édition.

## État de validation

| Page | État |
|---|---|
| Accueil | **v2 en ligne. v3 (textes fournis, Reserva confidentiel, illustrations) sur la branche `feat/v3-textes-visuels` ; v4 (textes resserrés, méthode en trois étapes, illustrations dessinées) sur `feat/v4-textes-visuels`, à relire par Marwan avant fusion.** Voir « État du site au 11/11/2026 (v4) ». |
| Consulting | **Page propre depuis la v6 (branche `feat/v6-navigation`)** à l'adresse `/consulting` : expertises, puis « Accompagnement et édition ». Voir « État du site au 17/11/2026 (v6) ». |
| Solutions | **En ligne, textes à valider** (lot v1.1, 27/10/2026) : `solutions.php`. Reserva, Immobilier, Shopping et page Développeurs hors site. |
| Édition | **En ligne, hors du menu depuis la v6** (pied de page et plan du site seulement ; présentée dans la page Consulting). Prestation (4 étapes **à valider**) et catalogue ; annonce Ikra.M **à valider** (27/10/2026). |
| À propos | À rédiger (hors menu). |
| Connect (ex-Noorwan Connect) | Renommé « Connect » dans les textes affichés le 24/11/2026 (M-116, branche `feat/charte-commune`). Produit de l'univers Solutions depuis le 20/11/2026 : hors de la barre, ligne dans Solutions, page `/connect` (pied de page, plan du site), présenté aussi dans le volet de connexion. Textes **proposés par Maestro, à valider** par Marwan. Voir « État du site au 24/11/2026 (charte commune) ». |
| Contact | En ligne. Photo de réunion depuis la v7 (branche `feat/v7-finitions`). Voir « État du site au 17/11/2026 (v7) ». |
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

## État du site au 17/11/2026 (v6, branche `feat/v6-navigation`, à relire avant fusion)

Brief v6 de Maestro du 17/11/2026, d'après huit constats de Marwan. Seuls les changements par rapport à la v5 bis sont listés. Choix de Maestro : une page par onglet, l'accueil résume chaque onglet. Nouveaux textes **à valider** par Marwan ; arabe à relire par un arabophone.

### Commun

- **Menu** : Consulting (`/consulting`), Solutions, Noorwan Connect, Contact. Chaque onglet a sa page ; l'Édition n'est plus un onglet.
- **Pied de page** : inchangé, sauf « Découvrir nos expertises » qui mène à `/consulting#expertises`. La colonne Édition (Voir le catalogue, Publier votre livre) garde la page Édition accessible ; elle reste aussi dans le plan du site.
- **Écosystème Noorwan** : le Compte Noorwan n'y figure plus (on le rajoutera plus tard) ; `ECOSYSTEM_ACCOUNT_URL` est retirée de `.env.example` et ignorée si elle traîne dans un `.env`. Restent Noorwan (sans lien), Reserva et Inteek (masqués sans adresse).
- **Fond blanc cassé** : fond de page `#F6F5F1`, sections grises `#EEEDE8`, gris des textes secondaires `#66666B` (au lieu de `#6E6E73`) pour garder le contraste AA (5,2:1 sur le fond, 4,9:1 sur le gris ; liens 5,1:1 et 4,8:1, contrôlé par `tests/run.sh`). Formulaire, menus et pastilles restent blancs. Le site n'a pas de thème sombre : rendu identique quel que soit le réglage du téléphone.

### Accueil

Ordre : haut de page · 01 Consulting · 02 Solutions · 03 Noorwan Connect · De l'idée à l'action · Pourquoi Noorwan · contact.

- Haut de page : plus de petit titre « Consulting, Solutions, Édition » au-dessus de « Une vision claire. Des étapes concrètes. » ; « Découvrir nos expertises » mène à `/consulting`.
- Chaque onglet en un écran, textes existants, lien « En savoir plus » vers sa page :
  - 01 Consulting : « Clarifier avant d'accélérer. » et le texte de l'univers Consulting.
  - 02 Solutions : « Des logiciels pour le travail de chaque jour » et le texte de l'univers Solutions.
  - 03 Noorwan Connect : titre et introduction de la page `/connect` (« Un seul compte pour tous les services Noorwan » ; « Un compte par personne, avec votre numéro de téléphone. Il vous ouvre les sites du groupe, pour vous comme pour votre entreprise. »), illustration de la page.
- Quittent l'accueil : les cinq expertises (page Consulting), la grille des produits (page Solutions), l'écran Édition et l'étagère {méta}Physique (page Consulting).
- Anciennes ancres : `#consulting` mène à `/consulting`, `#edition-univers` et `#edition` à `/consulting#accompagnement` (avec JavaScript ; sans, elles restent sur le résumé du Consulting).

### Page Consulting (`/consulting`, nouvelle)

- Haut de page : « Noorwan Consulting » (EN identique, AR « نوروان للاستشارات ») ; « Clarifier avant d'accélérer. » ; « Vingt ans de digital, de marketing et d'eCommerce au service d'une question simple : quelle est la prochaine étape utile pour votre projet ? » ; bouton « Parlons de votre projet » (univers Consulting) ; illustration du Consulting.
- « Nos expertises » (EN « Our expertise », AR « خبراتنا ») : les cinq expertises de la v4, puis « Une étape utile livrée vaut mieux qu'un grand plan sur le papier. »
- « Accompagnement et édition » (EN « Support and publishing », AR « المرافقة والنشر ») : « Des livres, du manuscrit à Amazon » ; texte de l'univers Édition ; **[À FOURNIR : accompagnement à l'écriture, ce que comprend la prestation]** ; couvertures d'Harmonie et Lumière, Vibration « À paraître » ; « {méta}Physique : » suivi de la phrase d'auteur ; « Chemins de l'Âme : Le Mal, Le Bien, Être pour Avoir » ; liens « En savoir plus » (page Édition) et « Publier votre livre » (formulaire, univers Édition).
- Bandeau de contact, univers Consulting.

### Page Solutions

- Ordre : en-tête · Notre façon de faire · **Inteek** en détail (une seule fois, avec l'illustration de son ancienne carte) · cartes Reserva et Noor · Bientôt · contact.
- Plus de carte Inteek (doublon) ni de carte Noorwan Édition (l'Édition est présentée dans Consulting) ; l'illustration du livre (`edition.svg`) est retirée.
- Reserva : catégorie **« eBusiness »** (au lieu de « Réservation » ; même mot en EN et AR), toujours « Confidentiel ».

### Page Noorwan Connect

- Bandeau final : **« Créez votre compte Noorwan Connect »** (EN « Create your Noorwan Connect account », AR « أنشئ حسابك على Noorwan Connect »).

## État du site au 16/11/2026 (v5 bis, même branche `feat/v5-noorwan-connect`, à relire avant fusion)

Brief v5 bis de Maestro du 16/11/2026, d'après Marwan : le site institutionnel ne gère pas de compte. Noorwan Connect est le moyen d'entrer dans l'écosystème ; il est présenté sur sa page `/connect`, et c'est depuis cette page seulement qu'on crée son compte ou qu'on y entre. Cette section remplace, pour ce qui suit, celle du 14/11/2026.

### Commun

- **Plus de « Mon compte »** : ni pastille dans l'en-tête, ni lien dans le menu mobile, ni lien dans le pied de page, que le Compte soit en service ou non. Menu : Consulting, Solutions, Édition, Noorwan Connect, Contact. Pied de page, colonne Noorwan : Noorwan Connect, Contact.
- La clé `nav.account` (Mon compte, My account, حسابي) est retirée des trois langues, ainsi que les styles de la pastille.
- Le bloc « Écosystème Noorwan » (D63) n'est pas touché : il peut nommer le Compte Noorwan si `ECOSYSTEM_ACCOUNT_URL` est renseignée (vide par défaut).

### Page Solutions

- Sous l'introduction, toujours affichée : « Un seul compte pour tous les services Noorwan. **Découvrir Noorwan Connect** → », lien vers `/connect` (EN : « One account for all Noorwan services. Discover Noorwan Connect » ; AR : « حساب واحد لجميع خدمات نوروان. اكتشف Noorwan Connect »). Plus de lien vers le Compte.

### Page Noorwan Connect (`/connect`)

- Haut de page : bouton « Créer mon compte » puis lien « **J'ai déjà un compte** » (I already have an account, لديّ حساب بالفعل), qui remplace « Déjà un compte ? Mon compte ». Les deux mènent à l'accueil du Compte Noorwan et restent masqués, avec le bandeau final, tant que `COMPTE_LINK_ENABLED` ne vaut pas `true`.
- Vos données, points 2 et 3 : « Vos informations, vos appareils connectés et les services que vous utilisez se consultent dans **votre compte Noorwan Connect**. » ; « Depuis **votre compte Noorwan Connect**, quand vous le souhaitez. Vous avez 30 jours pour changer d'avis ; ensuite, vos données personnelles sont effacées. » (EN : « your Noorwan Connect account » ; AR : « حسابك على Noorwan Connect »).
- Inchangé, à trancher par Marwan : le bandeau final garde « Créez votre Compte Noorwan ».

### Page Édition (rappel du 15/11/2026)

- Les livres sans identifiant Amazon mènent à la page auteur de Noorwan sur amazon.fr (choix de Marwan du 15/11/2026) ; plus aucun texte à fournir sur la page Édition (le « [À FOURNIR : ASIN] » a disparu). Harmonie garde son lien direct.

## État du site au 14/11/2026 (v5, branche `feat/v5-noorwan-connect`, à relire avant fusion)

Brief v5 de Maestro du 14/11/2026, d'après la maquette « parcours » de Noorwan Connect. Branche partie de la v4 (pas encore fusionnée). Tous les textes ci-dessous sont **proposés par Maestro, à valider** par Marwan ; anglais et arabe dans `lang/en.php` et `lang/ar.php`, arabe à relire par un arabophone. Aucun produit nommé sur la page (Reserva reste confidentiel), aucun numéro ni nom de personne réels, aucune date pour les partenaires.

### Commun

- Menu : Consulting, Solutions, Édition, **Noorwan Connect**, Contact. Pied de page, colonne Noorwan : Noorwan Connect, Contact, Mon compte (retiré le 16/11/2026, v5 bis).
- « Connexion » devient **« Mon compte »** (My account, حسابي) : pastille de l'en-tête de toutes les pages, dernier lien du menu mobile, colonne Noorwan du pied de page, phrase de la page Solutions. Mène à l'accueil du Compte Noorwan ; masqué tant que `COMPTE_LINK_ENABLED` ne vaut pas `true` (ou si `COMPTE_URL` est vide).

### Page Noorwan Connect (`/connect`)

- Haut de page : « Noorwan Connect » ; titre « Un seul compte pour tous les services Noorwan » ; « Un compte par personne, avec votre numéro de téléphone. Il vous ouvre les sites du groupe, pour vous comme pour votre entreprise. » ; bouton « Créer mon compte » ; « Déjà un compte ? Mon compte » ; illustration.
- Pour les particuliers : « Entrez partout avec le même compte » ; « Prendre un rendez-vous, suivre une demande : sur chaque site du groupe, « Continuer avec Noorwan Connect » vous fait entrer sans créer de nouveau compte. »
  1. Un geste pour entrer : « Déjà connecté sur votre téléphone ? Vous entrez dans un autre site du groupe sans ressaisir de code. »
  2. Vos informations à un seul endroit : « Votre nom, votre numéro et votre langue se changent une fois, dans votre compte, pour tous les sites. »
  3. Un numéro, un compte : « Le même numéro ne peut pas ouvrir deux comptes : votre compte reste le vôtre. »
- Pour les professionnels : « Gérez votre entreprise avec la même entrée » ; « Vous représentez une entreprise, une association ou une administration ? Ajoutez un compte professionnel à votre compte. Un particulier n'en a pas besoin. »
  1. Le compte professionnel : « Il porte votre entreprise et vos droits dans chaque service : propriétaire ou administrateur. »
  2. Les établissements : « Chaque lieu de votre entreprise a sa place : une boutique, une agence, un cabinet. »
  3. L'équipe : « Invitez vos collaborateurs par leur numéro. Chacun entre avec son propre compte et le rôle que vous lui donnez. »
  - Encadré : « En entrant dans un service, vous choisissez à quel titre : pour vous, ou pour l'une de vos entreprises. »
- Sans mot de passe (fond noir) : « Votre numéro suffit » ; « Pas de mot de passe à retenir. Vous recevez un code sur votre téléphone, vous le saisissez, et vous êtes entré. »
  1. Votre numéro : « Choisissez votre pays, puis saisissez votre numéro de téléphone. »
  2. Le code : « Saisissez le code reçu par SMS. Il ne sert qu'une fois. »
  3. C'est fait : « Sur un appareil de confiance, votre session reste ouverte : la fois suivante, un geste suffit. »
- Vos données : « Vos données restent à vous » ; « Votre compte ne sert qu'à vous faire entrer. Vous voyez ce que chaque site reçoit, et vous pouvez tout arrêter. »
  1. Ce que les sites reçoivent : « Un site du groupe reçoit votre nom. Votre numéro, seulement si vous l'acceptez. »
  2. Vous gardez la main : « Vos informations, vos appareils connectés et les services que vous utilisez se consultent dans « Mon compte ». »
  3. Supprimer votre compte : « Depuis « Mon compte », quand vous le souhaitez. Vous avez 30 jours pour changer d'avis ; ensuite, vos données personnelles sont effacées. » (délai de 30 jours du Compte Noorwan, Conv-017 du Compte)
- Pour les entreprises partenaires, pastille « Bientôt » (sans date) : « Une entreprise hors du groupe pourra proposer « Se connecter avec Noorwan » sur son site. Ses clients entreront avec leur numéro, sans nouveau compte, et autoriseront une seule fois ce site à connaître leur nom. » ; lien « Être tenu informé » vers le formulaire (univers Solutions).
- Bandeau final (seulement quand le Compte est en service) : « Créez votre Compte Noorwan » ; « Votre numéro de téléphone suffit. » ; « Créer mon compte ».
- Six illustrations dessinées (`public/assets/img/connect-*.svg`, moins de 3 ko, sans texte), sans miroir en arabe : le compte relié aux services et à une place de partenaire en pointillés, un agenda sur téléphone, une entreprise et ses établissements avec son équipe, le code en six cases et une clé, un bouclier avec deux réglages et un calendrier, le site d'un partenaire avec un bouton marqué du point bleu.

## État du site au 17/11/2026 (v7, branche `feat/v7-finitions`, à relire avant fusion)

Brief v7 de Maestro (daté du 18/11/2026), d'après Marwan. Seuls les changements par rapport à la v6 sont listés. Textes **à valider** par Marwan ; arabe à relire par un arabophone.

### Commun

- **Onglet actif** : dans le menu (ordinateur et téléphone), l'onglet de la page affichée porte `aria-current="page"`. Ordinateur : texte plus gras, souligné d'un trait bleu. Téléphone : texte plus gras, trait bleu du côté où commence la lecture (à gauche, à droite en arabe). L'accueil n'a pas d'onglet actif (il n'est pas dans le menu).
- **Photo de contact** : la réunion de trois personnes (validée par Marwan) remplace l'illustration dessinée en tête de la page Contact et dans le bandeau « Un projet en tête ? » de chaque page. WebP recadré en 3:2, 600 px (19 Ko) et 1200 px (48 Ko), le navigateur choisit ; chargée à la demande dans le bandeau. Jamais en miroir en arabe. Texte alternatif : FR « Trois personnes en réunion autour d'une table, un ordinateur portable ouvert devant elles. » ; EN « Three people in a meeting around a table, with an open laptop in front of them. » ; AR « ثلاثة أشخاص في اجتماع حول طاولة، وأمامهم حاسوب محمول مفتوح. ».

### Accueil, « Pourquoi Noorwan »

Le groupe n'est plus présenté comme « trois métiers » ou « trois univers » (les expertises débordent).

| Avant | Après |
|---|---|
| Titre : « Trois métiers, une même exigence » (EN « Three trades, one standard », AR « ثلاث مهن، ومعيار واحد ») | « Une même exigence, quel que soit le projet » (EN « One standard, whatever the project », AR « معيار واحد، أيًّا كان المشروع ») |
| Point 2, titre : « Trois univers qui se répondent » (EN « Three areas that support each other », AR « ثلاثة مجالات يكمل بعضها بعضًا ») | « Des expertises qui se répondent » (EN « Areas of expertise that support each other », AR « خبرات يكمل بعضها بعضًا ») |
| Point 2, texte : « Conseil, logiciel et édition se nourrissent : ce que nous apprenons dans un univers sert les deux autres. » (EN « ... serves the other two. », AR « ... يخدم المجالين الآخرين. ») | « Conseil, logiciel et édition se nourrissent : ce que nous apprenons dans un domaine sert les autres. » (EN « ... serves the others. », AR « ... يخدم المجالات الأخرى. ») |

Le titre vient du brief ; les deux phrases du point 2 sont une proposition de l'exécutant, **à valider**.

Laissées telles quelles, car elles nomment des activités sans les compter (à trancher par Marwan) : l'introduction de l'accueil (« Nous conseillons les entreprises, nous concevons leurs logiciels et nous publions des livres. ... »), le texte de « Pourquoi Noorwan » (« Un groupe qui relie le conseil, le logiciel et l'édition avec une même méthode ... »), « C'est notre méthode pour un conseil, un logiciel ou un livre. » et le titre de l'onglet du navigateur « Noorwan : conseil, solutions et édition ». « En trois langues » et la méthode en trois étapes ne sont pas concernées.

### Page Consulting

Relue : aucune formule « trois métiers » ou « trois univers ». Rien de changé.

## État du site au 18/11/2026 (v8, branche `feat/v8-savoir-faire`, à relire avant fusion)

Brief v8 de Maestro (18/11/2026), réponses de Marwan du jour. Seuls les changements par rapport à la v7 sont listés. Arabe à relire par un arabophone.

### Accueil

| Où | Avant (v7) | Après (v8) |
|---|---|---|
| « Pourquoi Noorwan », point 2, titre | « Des expertises qui se répondent » (EN « Areas of expertise that support each other », AR « خبرات يكمل بعضها بعضًا ») | « Nos savoir-faire » (EN « What we do best », AR « خبراتنا »), décision de Marwan |
| Introduction (et description pour les moteurs de recherche) | « Nous conseillons les entreprises, nous concevons leurs logiciels et nous publions des livres. Toujours de la même façon : partir d'un besoin réel, livrer vite, améliorer ensuite. » | « Partir d'un besoin réel, livrer vite, améliorer ensuite. » (EN « Start from a real need, deliver fast, improve afterwards. », AR « ننطلق من حاجة حقيقية، ونُنجز بسرعة، ثم نحسّن. ») |
| « Pourquoi Noorwan », texte | « Un groupe qui relie le conseil, le logiciel et l'édition avec une même méthode : partir du besoin réel et livrer ce qui sert. » | « Partir du besoin réel et livrer ce qui sert. » (EN « Start from the real need and deliver what helps. », AR « الانطلاق من الحاجة الحقيقية وتقديم ما ينفع. ») |
| « Pourquoi Noorwan », point 2, texte | « Conseil, logiciel et édition se nourrissent : ce que nous apprenons dans un domaine sert les autres. » | « Ce que nous apprenons dans un domaine sert les autres. » (EN « What we learn in one area serves the others. », AR « ما نتعلمه في مجال يخدم المجالات الأخرى. ») |
| « De l'idée à l'action », introduction | « C'est notre méthode pour un conseil, un logiciel ou un livre. » | Retirée (le titre est suivi directement des trois étapes) |

Les quatre phrases qui nommaient conseil, logiciel et édition sont retirées sans rien écrire à leur place (décision de Marwan) : seule la partie qui les nommait est supprimée, le reste de la phrase est gardé tel quel, majuscule initiale comprise. Le titre de l'onglet du navigateur, « Noorwan : conseil, solutions et édition », n'est pas une de ces phrases : inchangé.

### Bandeau « Un projet en tête ? » et page Contact

Sur téléphone, le titre passe avant la photo, la photo ensuite ; à partir de 768 px, la photo reste au-dessus du titre, comme en v7.

### Page Consulting, « Accompagnement et édition »

Le texte à fournir sur l'accompagnement à l'écriture est remplacé par le texte validé par Marwan, et n'est plus surligné :

- FR : « Vous avez un livre en tête, ou un manuscrit en cours. Nous vous aidons à le mener au bout : clarifier l'idée et le plan, relire chapitre après chapitre, corriger, puis préparer la mise en page et la publication. Vous restez l'auteur ; nous tenons le cap et le calendrier avec vous. »
- EN : « You have a book in mind, or a manuscript under way. We help you see it through: clarifying the idea and the outline, reading it chapter after chapter, correcting, then preparing the layout and the publication. You remain the author; we keep it on course and on schedule with you. »
- AR (littéraire, à relire) : « في ذهنك كتاب، أو بين يديك مخطوط قيد الكتابة. نعينك على المضيّ به حتى غايته: نوضّح الفكرة ونرسم الخطة، ونراجع النص فصلًا بعد فصل، ونصحّح، ثم نُعِدّ الإخراج والنشر. تبقى أنت المؤلِّف؛ ونحن نُمسك معك بالدفّة ونرعى المواعيد. »

Il ne reste plus aucun texte « À FOURNIR » sur le site.

## État du site au 19/11/2026 (v9, branche `feat/theme-sombre`, à relire avant fusion)

Brief « thème sombre » de Maestro (19/11/2026), demande de Marwan. Aucun texte de page ne change ; la phrase de la v6 « Le site n'a pas de thème sombre » ne vaut plus.

- **Thème sombre sur tout le site**, couleurs de la charte (page 4) : page `#000000`, brume `#111113`, papier `#1C1C1E`, traits `#2A2A2C` et `#3A3A3C`, encre `#F5F5F7`, texte `#A1A1A6`, discret `#8E8E93`, lien `#2997FF` ; univers en sombre : Consulting fond `#2A2418` texte `#D9C49A`, Solutions `#1A2230` et `#A9BCD6`, Édition `#2C1C20` et `#D9A5AE` ; erreur `#FF6B60`, réussite `#4CD47A`. Bleu action, or et sections déjà noires inchangés. Point du logotype en `#2997FF`. Contrastes AA notés dans `site.css` et contrôlés par `tests/run.sh`.
- **Illustrations** : chaque dessin a sa version sombre (`<nom>-dark.svg`, produite par `bin/illustrations-dark.php` à partir du dessin clair, couleurs seulement). Les deux dessins faits pour le fond noir (Noor, « sans mot de passe ») sont repris tels quels.
- **Bascule** : bouton rond (soleil en clair, croissant de lune en sombre) à côté du choix de langue, et ligne « Passer en sombre » / « Passer en clair » dans le menu sur téléphone (EN « Switch to dark » / « Switch to light », AR « التبديل إلى الوضع الداكن » / « التبديل إلى الوضع الفاتح », à relire). À l'arrivée, le site suit l'appareil. Un choix différent de l'appareil est gardé dans le navigateur (`localStorage`, clé `nw-theme`, aucun cookie) ; un choix qui redevient celui de l'appareil est oublié, y compris quand l'appareil change de lui-même.

## État du site au 19/11/2026 (expertises illustrées, branche `feat/expertises-illustrees`, à relire avant fusion)

Brief « Nos expertises illustrées » de Maestro (19/11/2026) : variante 1 de la planche, validée par Marwan. Aucun texte ne change.

- **Page Consulting, « Nos expertises »** : une carte blanche par expertise (coins de 24 px), un pictogramme en tête dans une pastille de 64 px aux couleurs du Consulting (trait `#A8915F`, accent `#6F5B2E`, pastille `#F3EEE3` ; en sombre `#CDB98A`, `#E6D3A3`, `#2A2A2C`) : cible et flèche, haut-parleur, chariot, écran et chevrons de code, tableau avec courbe et deux personnes. Sixième carte sombre : « Clarifier avant d'accélérer. » et « Une étape utile livrée vaut mieux qu'un grand plan sur le papier. » (la phrase n'est plus sous la liste). Une colonne sur téléphone, deux dès 768 px, trois dès 1024 px. Pictogrammes jamais retournés en arabe.
- **Accueil** : inchangé, il ne porte toujours pas les expertises (décision de la v6).

## État du site au 20/11/2026 (Noorwan Connect dans Solutions, photos sans texte, branche `feat/connect-et-visuels`, à relire avant fusion)

Brief « Noorwan Connect dans Solutions, visuels sans texte » de Maestro (20/11/2026), d'après deux décisions de Marwan. Aucun texte nouveau inventé.

- **Menu** : Consulting, Solutions, Contact (en-tête et menu du téléphone). Noorwan Connect quitte le menu ; il reste dans le pied de page (colonne Noorwan) et le plan du site. Écosystème Noorwan inchangé (D63). Sur la page `/connect`, aucun onglet n'est marqué actif.
- **Page Solutions, grille des produits** : Reserva, **Noorwan Connect**, Noor, puis « Bientôt ». Carte Noorwan Connect au même gabarit, claire (produit en service) : nom « Noorwan Connect » en lettres latines dans les trois langues ; texte repris de l'introduction de `/connect` (« Un compte par personne, avec votre numéro de téléphone. Il vous ouvre les sites du groupe, pour vous comme pour votre entreprise. ») ; lien « En savoir plus » vers `/connect` ; illustration du haut de sa page. **[À FOURNIR : catégorie de Noorwan Connect]** (comme « eBusiness » pour Reserva). Une colonne sur téléphone, deux dès 834 px avec la troisième carte seule sur toute la largeur, trois dès 1024 px. La phrase « Un seul compte pour tous les services Noorwan. Découvrir Noorwan Connect » reste sous l'introduction de la page.
- **Accueil** : il n'a pas de liste des produits (v6), il ne change pas ; son résumé « 03 Noorwan Connect » reste.
- **Images sans texte** : le texte n'est jamais dans une image ; il est posé en HTML par-dessus, sélectionnable et traduit.
- **Photos d'en-tête des pages Consulting, Solutions et Édition** (emplacements prêts, images à déposer par Marwan) : `public/assets/img/<page>-hero-1440.webp` et `<page>-hero-780.webp` (`consulting`, `solutions`, `edition`), servies avec `srcset` ; titre, introduction et boutons par-dessus, sur un voile sombre, en blanc dans les deux thèmes ; jamais en miroir en arabe. Tant qu'une des deux largeurs manque, l'en-tête garde son rendu (Consulting : son illustration). Textes alternatifs **[À FOURNIR : description de la photo d'en-tête de la page Consulting / Solutions / Édition]**, à écrire dans les trois langues quand l'image arrive.


## État du site au 20/11/2026 (page Solutions, un produit par ligne, branche `feat/solutions-une-ligne`, à relire avant fusion)

Brief « Page Solutions, un produit par ligne ; catégorie de Noorwan Connect » de Maestro (20/11/2026), d'après deux décisions de Marwan. Aucun texte nouveau inventé. Remplace, pour ce qui suit, la grille des produits décrite dans la section précédente.

- **Catégorie de Noorwan Connect** : « Numérique » (EN « Digital », AR « رقمي »). Plus de marqueur [À FOURNIR] pour elle.
- **Page Solutions, disposition A** : après « Notre façon de faire », les quatre produits l'un sous l'autre, une ligne chacun, même gabarit et même poids : **Inteek** (Ressources humaines), **Reserva** (eBusiness, « Confidentiel »), **Noorwan Connect** (Numérique), **Noor** (Intelligence artificielle, « Confidentiel »). Puis « Bientôt : Immobilier, Shopping ». Plus de grille de cartes.
  - Chaque ligne : catégorie, nom, texte, lien, illustration. Inteek garde son contenu détaillé (introduction, « Vous commencez par les modules… », les cinq modules), sans lien (pas de page à lui). Reserva et Noor : pastille « Confidentiel », « Présentation sur rendez-vous. », lien « Demander une présentation » (formulaire, univers Solutions). Noorwan Connect : introduction de `/connect`, lien « En savoir plus » vers `/connect`.
  - Téléphone : illustration au-dessus du texte, centrés. Ordinateur (834 px et plus) : deux colonnes, illustration à gauche puis à droite en alternance (à droite puis à gauche en arabe). Grand espace et filet fin entre les lignes.
  - Illustrations : celles des anciennes cartes ; Inteek en miroir en arabe, les autres jamais.
- **Inchangés** (pas de décision de Marwan) : la phrase « Un seul compte pour tous les services Noorwan. Découvrir Noorwan Connect » sous l'introduction de Solutions, et le résumé « 03 Noorwan Connect » de l'accueil.


## État du site au 21/11/2026 (en-tête en photo de Contact, texte alternatif de Solutions, branche `feat/visuels-solutions-contact`, à relire avant fusion)

Brief « En-têtes en photo pour Solutions et Contact » de Maestro (21/11/2026), d'après la demande de Marwan.

- **Page Contact** : en-tête en photo comme Consulting. La photo de réunion (trois personnes autour d'une table) passe en fond, sous le même voile sombre ; « Contact », « Parlons de votre projet », l'introduction et l'adresse contact@noorwan.com restent en HTML par-dessus, en blanc dans les deux thèmes. Elle n'apparaît plus dans le corps de l'en-tête (pas deux fois la même photo) ; elle reste dans le bandeau « Un projet en tête ? » des autres pages. Fichiers `contact-hero-780.webp` (780 x 800, recadrée au centre) et `contact-hero-1200.webp` : l'original n'a que 1200 px, la grande largeur reste 1200, sans agrandissement. Texte alternatif inchangé (celui de la photo de contact).
- **Page Solutions** : texte alternatif de la future photo d'en-tête, écrit avant l'image : FR « Illustration : deux personnes assemblent des écrans d'application et des modules reliés entre eux. » ; EN « Illustration: two people assemble app screens and connected modules. » ; AR « رسم توضيحي: شخصان يجمّعان شاشات تطبيقات ووحدات مترابطة. ». L'en-tête ne change pas tant que `solutions-hero-780.webp` et `-1440.webp` ne sont pas déposés.
- **Reste à fournir** : le texte alternatif de la photo d'en-tête d'Édition (trois langues).

## État du site au 24/11/2026 (charte commune, branche `feat/charte-commune`, à relire avant fusion)

Brief « noorwan.com : charte commune » de Maestro (24/11/2026), d'après Marwan (« ok va y met tout en place au complet ») ; décisions M-116, M-118, M-119, M-120. Couleurs, univers, typographie et logo officiel de noorwan.com inchangés. Aucun texte de contenu nouveau : seulement les libellés d'interface ci-dessous (FR, EN, AR ; arabe à relire).

- **Connect (M-116)** : « Noorwan Connect » devient « Connect » partout où il est affiché (titre et description de la page `/connect`, petit titre, ligne de Solutions, « Découvrir Connect », « votre compte Connect », « Créez votre compte Connect », pied de page). Le bouton s'appelle « Continuer avec Noorwan » (EN « Continue with Noorwan », AR « المتابعة باستخدام Noorwan », libellés du Compte), y compris dans le texte « Pour les particuliers » de `/connect`.
- **En-tête fixe** (toutes les pages) : bouton Menu, logo, liens Consulting, Solutions, Contact dès 900 px (le bouton Menu disparaît alors), langue (« FR » et flèche, menu déroulant Français, English, العربية, langue active cochée), thème, **« Connexion »** (EN « Sign in », AR « الدخول », libellé de la v1.1).
- **Volet du menu** (début de ligne, à droite en arabe ; plein écran au téléphone) : logo, **Accueil** (EN « Home », AR « الرئيسية »), Consulting, Solutions, Édition, Contact ; puis « Écosystème Noorwan » avec les autres sites ; en bas, « Continuer avec Noorwan » quand le Compte est en service. Croix **« Fermer »** (EN « Close », AR « إغلاق »), titre caché « Menu du site » (EN « Site menu », AR « قائمة الموقع »).
- **Volet de connexion** (fin de ligne) : titre « Connexion », logotype « noorwan. » puis « Connect » en bleu, titre et introduction de `/connect` (« Un seul compte pour tous les services Noorwan » ; « Un compte par personne… »), bouton « Continuer avec Noorwan » vers le Compte seulement si `COMPTE_LINK_ENABLED` vaut `true`, puis « En savoir plus » vers `/connect`. Le site ne gère toujours aucun compte (v5 bis) : seuls ce bouton, celui du volet du menu et ceux de `/connect` mènent au Compte.
- **Pied de page commun** : logo et « Des idées pour des solutions concrètes. », quatre colonnes inchangées (deux par ligne au téléphone), ligne « Écosystème Noorwan » avec les autres sites seulement (Connect, Reserva, Inteek selon les adresses `ECOSYSTEM_*_URL` ; noorwan.com n'y est plus nommé), puis « © 2026 Noorwan », Mentions légales, Confidentialité, Cookies et « Gérer les cookies » (quand la mesure d'audience est réglée). Pas de « Powered by Noorwan » : noorwan.com n'est pas un produit.
- **Composants** : champs du formulaire à coins de 3 px et bord plus marqué, formulaire en carte de 28 px, focus clavier de 2 px. Bandeau de consentement et indexation inchangés.

