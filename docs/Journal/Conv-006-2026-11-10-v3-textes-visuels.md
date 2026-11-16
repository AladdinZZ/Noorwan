# Conv-006, 7 au 10/11/2026 : v3, textes, Reserva confidentiel, illustrations

Branche `feat/v3-textes-visuels` (depuis `origin/main`, v2 fusionnée). Brief : `briefs/_brief_noorwan-site_v3.md` (Maestro, 7/11/2026). Séance interrompue par une limite d'utilisation, reprise le 10/11 sur une branche encore vide.

## Objectif

1. Reserva « Confidentiel » comme Noor.
2. Textes « À FOURNIR » : phrase d'auteur, ASIN des livres, « Pourquoi Noorwan ».
3. Illustrations SVG des cartes de produits.

## Ce qui a été fait (commits)

- Reserva confidentiel dans les trois langues ; tests : deux produits confidentiels, aucune description de Reserva (pages et `lang/`).
- Phrase d'auteur et « Pourquoi Noorwan » (accroche et trois points forts, `home.why_points`, style `.why-points`) ; plus aucun `[À FOURNIR]` sur l'accueil.
- Harmonie liée à sa fiche amazon.fr (ASIN `B0F91W6361`) ; les quatre autres livres restent à fournir.
- Espaces insécables avant les deux-points des nouveaux textes français.
- Illustrations SVG (`public/assets/img/reserva|inteek|noor|edition.svg`) en remplacement des dégradés CSS ; miroir en arabe pour Inteek et le livre ; tests de poids, d'absence de texte et de présence.
- `docs/CONTENUS.md` : section « État du site au 10/11/2026 (v3) ».

## Sources des ASIN

- Harmonie `B0F91W6361` : URL de fiche amazon.fr trouvée par recherche web, titre « Harmonie: Science et spiritualité : Aux frontières de la matière et de la conscience », auteur Noorwan. Les pages Amazon ne peuvent pas être ouvertes depuis la session (domaine hors liste d'accès) : vérifiée par le titre et l'auteur de la fiche, pas par la page elle-même.
- Candidats non vérifiés sur Amazon, relevés sur la page auteur ThriftBooks (Noorwan) : Lumière `B0FXTPRW4J`, Le Mal (titre long « Le Mal et les 7 degrés de l'Ombre ») `B0FXTYGNK4`, Être pour Avoir `B0FVVMWN52` ; Harmonie y figure aussi sous `B0FB6P863X` (autre édition, sans doute). Laissés « À FOURNIR ».
- Le Bien : introuvable.

## Sources de la phrase d'auteur

Présentations d'Harmony (ISBN 979-8-1813938-6-8) et de Light (979-8-1815628-5-1) sur des fiches de libraires suisses (vonmatt.ch, buk-wetzikon.ch), reprises des quatrièmes de couverture.

## Vérifications

- `tests/run.sh` vert sur le serveur intégré de PHP et une base MariaDB locale.
- Captures 390 et 1440 px, FR et AR (accueil, Solutions, Édition, cartes de produits, « Pourquoi Noorwan », trilogie) chez Maestro, `retours/noorwan-site/captures-v3/`. Aucun débordement horizontal.

## Ce qui reste

- Marwan : relire les textes, confirmer les ASIN candidats, dire si « Le Bien » est en vente.
- Arabophone : relire la phrase d'auteur et « Pourquoi Noorwan ».

## Pièges

- Playwright : `addStyleTag` refusé par la CSP (`style-src 'self'`), passer par `element.style`.
