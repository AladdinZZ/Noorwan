# Conv-011 : v7, onglet actif, titre moins fermé, photo de contact (17/11/2026)

## Objectif

Brief v7 de Maestro (daté du 18/11/2026, d'après Marwan) : onglet actif dans le menu, remplacer « Trois métiers, une même exigence », photo de réunion pour « Parlons de votre projet ». Branche `feat/v7-finitions` depuis `origin/main` (v6 fusionnée), sans poussée.

## Décisions

- **Onglet actif** : `aria-current="page"` posé dans `app/layout/header.php` d'après `current_page()`, dans les deux menus. Ordinateur : graisse 600 et trait bleu sous le mot. Téléphone : graisse 700 et trait bleu de 4 px du côté du début de lecture (inversé en arabe). L'accueil n'a pas d'onglet actif.
- **Titre** : « Une même exigence, quel que soit le projet » (brief), EN « One standard, whatever the project », AR « معيار واحد، أيًّا كان المشروع ».
- **Choix de l'exécutant, à valider** : le point « Trois univers qui se répondent » devient « Des expertises qui se répondent », et sa phrase ne compte plus (« dans un domaine sert les autres »). Les phrases qui nomment conseil, logiciel et édition sans les compter sont laissées (liste dans CONTENUS.md) : les réécrire aurait demandé d'inventer du texte.
- **Photo** : l'original (1600 px, carré, 149 Ko) est recadré en 3:2 (les trois personnes et la table) et servi en WebP 600 px (19 Ko) et 1200 px (48 Ko) par `srcset`. Un seul gabarit, `app/layout/contact-photo.php`, pour la page Contact (chargement immédiat) et le bandeau (chargement à la demande). Classe `.photo`, jamais en miroir en arabe (les illustrations dessinées le sont). `contact.svg` supprimé (pas de code mort). Coins arrondis de 20 px, largeur 520 px au plus.

## Ce qui a été fait (commits)

1. `Mettre en avant l'onglet de la page affichée dans le menu`
2. `Remplacer « Trois métiers, une même exigence » et retirer « Trois univers »`
3. `Remplacer l'illustration de contact par la photo de réunion`
4. `Mettre les tests à jour pour la v7`
5. `Consigner l'état v7 dans CONTENUS.md et le journal de séance`

## Vérifications

- `tests/run.sh` vert, 635 contrôles : serveur intégré de PHP sur 127.0.0.1:8000 avec `tests/router.php`, MariaDB jetable (port 3307, utilisateurs et droits de la CI), `.env` temporaire retiré à la fin. Nouveaux contrôles : un seul onglet actif par menu et le bon, aucun sur l'accueil, nouveau titre dans les trois langues, plus de « trois métiers » ni « trois univers » sur l'accueil et Consulting, photo avec texte alternatif traduit, poids des deux fichiers sous 60 Ko, pas de miroir.
- Captures 390 et 1440 px (Chrome sans tête) : accueil FR, EN, AR ; Contact FR et AR ; Consulting FR ; Solutions EN ; menu du téléphone ouvert. Aucun débordement horizontal.

## Ce qui reste

- Marwan : valider les deux phrases du point 2 de « Pourquoi Noorwan », dire si les phrases qui nomment « conseil, logiciel et édition » doivent aussi changer ; arabe à relire.
- Fusion par Marwan ; aucune migration, aucun réglage nouveau sur le VPS.

## Pièges

- MariaDB jetable : les utilisateurs anonymes créés par `mariadb-install-db` prennent le pas sur `'noorwan_site'@'%'` en connexion locale (erreur 1045). Les supprimer (`DELETE FROM mysql.global_priv WHERE User=''; FLUSH PRIVILEGES;`).
- `lang/fr.php` contient des espaces insécables avant les deux-points : un remplacement de phrase entière copiée depuis un terminal peut ne pas correspondre, remplacer par morceaux.
- Le test du menu de `/connect` cherchait le lien sans attribut : l'onglet actif y ajoute `aria-current="page"`.
