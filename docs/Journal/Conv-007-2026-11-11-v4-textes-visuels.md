# Conv-007, 11/11/2026 : v4, textes plus forts et illustrations dessinées

Branche `feat/v4-textes-visuels`, partie de `origin/feat/v3-textes-visuels` (la v3, demande n° 2, n'était pas encore fusionnée dans `main`). Brief : `briefs/_brief_noorwan-site_v4.md` (Maestro, 11/11/2026).

## Objectif

1. Relire les textes de l'accueil et des univers en trois langues, réécrire « De l'idée à l'action » avec la méthode réelle en trois étapes illustrées.
2. Remplacer les visuels géométriques ou génériques par des illustrations dessinées : héros, trois univers, méthode, contact.

## Direction visuelle : deux propositions sur le héros

Captures `heros-direction-a-*` et `heros-direction-b-*` chez Maestro (`retours/noorwan-site/captures-v4/`), FR et AR, 390 et 1440 px.

- **A, la lampe** : une lampe de bureau éclaire trois objets posés sur une table, un plan de route (Consulting), un téléphone (Solutions), des livres (Édition).
- **B, le chemin** : un chemin en pointillés part d'une étincelle, passe par trois pastilles rondes (boussole, téléphone, livre) et finit sur un drapeau.

Choix : **A**. Elle montre les trois univers comme des objets réels sous une même lumière, ce qui dit en une image « un groupe, trois métiers » ; elle s'écrit dans le trait des illustrations de produits de la v3 (formes pleines, coins arrondis, palette par univers). B ressemble à toutes les « frises de parcours » (icônes dans des cercles reliées par des pointillés) et ses objets, réduits à des pictogrammes, se lisent mal à 390 px. A a ensuite été recadrée (moins de mur, livres posés sur un livre couché, socle du téléphone) : `heros-a-retouche-*`, puis `heros-final-*`.

Le trait est le même partout : formes pleines, pas de contour noir sur les aplats (les premières étapes en avaient, retirés pour rester cohérent), noir `#1D1D1F` pour les appareils, palette de la v3 (bronze, bleu ardoise, bordeaux) et doré `#F5D58A` pour la lumière. Le site n'a pas de thème sombre ; l'illustration de Solutions est dessinée pour son écran noir.

## Ce qui a été fait (commits)

- Huit SVG dans `public/assets/img/` (de 1 à 4 ko, sans texte) : `hero`, `universe-consulting|solutions|edition`, `step-field|build|improve`, `contact`.
- Textes en FR, EN, AR (détail dans `docs/CONTENUS.md`, « État du site au 11/11/2026 (v4) ») : accroche, textes des univers, introduction et expertises du Consulting, titre de Solutions, titre et texte de l'Édition, méthode en trois étapes, titre propre pour « Pourquoi Noorwan », bandeau de contact, introduction de la prestation d'édition. Espaces insécables avant les deux-points et points d'interrogation français nouveaux.
- Mise en page : héros illustré (`hero.webp` supprimé), univers illustrés (les formes CSS disparaissent), nouvelle section `#methode` après les univers (classe `method-steps` ; la classe `steps` reste celle de la prestation de la page Édition), bandeau de contact et page Contact illustrés, classe commune `.illus` en miroir en arabe.
- Tests : poids (moins de 20 ko) et absence de texte des douze SVG, huit illustrations sur l'accueil, trois étapes, illustration de la page Contact, règle de miroir ; titre de la page Solutions mis à jour ; test de poids de `hero.webp` retiré.

## Vérifications

- `tests/run.sh` vert (serveur intégré de PHP sur 127.0.0.1:8047 avec `tests/router.php`, MariaDB jetable dans `/tmp/noorwan-exec-v4/`).
- Captures avant et après, accueil, Solutions, Édition, Contact, FR et AR, 390 et 1440 px, plus gros plans (méthode, univers, héros, bandeau, en-tête Contact) : `retours/noorwan-site/captures-v4/`. Aucun débordement horizontal.

## Ce qui reste

- Marwan : relire les textes (CONTENUS.md, section v4).
- Arabophone et anglophone : relire les nouveaux textes.
- Les illustrations des produits Reserva et Noor restent abstraites (choix de la v3 pour deux produits confidentiels) : à redessiner si Marwan le souhaite.

## Pièges

- `git rm` d'un fichier, puis `git add` d'autres fichiers et `git commit` : la suppression déjà indexée part dans le commit. Corrigé par `--amend` avant toute poussée.
- Les captures pleine page de Playwright ne chargent pas les images `loading="lazy"` hors écran : passer les images en `eager` avant la capture.
- Captures « avant » : prises sur un `git worktree` de la v3 servi sur un autre port, pour ne pas mélanger avec le travail en cours.
