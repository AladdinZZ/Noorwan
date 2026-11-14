# Conv-008, 14/11/2026 : v5, page « Noorwan Connect » et lien « Mon compte »

Branche `feat/v5-noorwan-connect`, partie de `origin/feat/v4-textes-visuels` (la v4, demande n° 3, n'était pas encore fusionnée dans `main`). Brief : `briefs/_brief_noorwan-site_v5-connect.md` (Maestro, 14/11/2026), maquette `briefs/maquettes-noorwan-connect/parcours.html`. Aucune poussée, aucune demande de fusion.

## Objectif

1. Une page « Noorwan Connect » en trois langues, dans le menu, qui présente le compte unique du groupe aux particuliers et aux professionnels, d'après la maquette, en version site.
2. « Mon compte » dans l'en-tête de toutes les pages, vers l'accueil du Compte Noorwan.

## Décisions

- **Adresse `/connect`** : `PAGES['connect'] = 'connect'`, réécrite vers `connect.php` dans `public/.htaccess` (comme `robots.txt` et `sitemap.xml`) et dans `tests/router.php`. `connect.php` reste servi ; l'adresse canonique et le plan du site donnent `/connect`.
- **« Mon compte » remplace « Connexion »** : c'était déjà un lien vers l'accueil du Compte (`account_url()`), seul le libellé change (Mon compte, My account, حسابي). Même réglage qu'avant : `COMPTE_LINK_ENABLED` (masqué par défaut) et `COMPTE_URL`. Une adresse vide masque aussi le lien (`account_url()`), mais `env()` remplace une valeur vide par l'adresse par défaut : en pratique, c'est `COMPTE_LINK_ENABLED` qui décide (voir points à trancher).
- **« Créer mon compte »** mène à la même adresse (l'écran d'entrée du Compte crée le compte d'un numéro inconnu) ; le bouton du haut, « Déjà un compte ? » et le bandeau final disparaissent avec le lien. Le reste de la page s'affiche toujours.
- **Rien de confidentiel** : la maquette illustre les parcours avec Reserva, des noms et un vrai numéro ; la page ne nomme aucun produit (« les sites du groupe »), aucune personne, aucun numéro. Partenaires : « Bientôt », sans date, lien « Être tenu informé » vers le formulaire (univers Solutions).
- **Faits vérifiés dans le dépôt du Compte** : fermeture du compte avec 30 jours pour changer d'avis puis effacement (Conv-017 du Compte), jeton sans téléphone (le numéro ne part qu'avec accord), invitations par numéro, appareils de confiance. La maquette parle aussi de rappels pendant les 30 jours : pas trouvés dans le code du Compte, donc pas écrits.
- **Illustrations** : six SVG dans le trait de la v4 (formes pleines, palette des univers, doré, sans texte). Elles portent des coches et n'ont pas de sens de lecture : **pas de miroir en arabe** (une coche retournée se lit mal), règle CSS dédiée.
- **Arabe** : « Noorwan Connect » et « Noorwan » isolés (`U+2066`, `U+2069`) entre guillemets, insécable entre les deux mots.

## Ce qui a été fait (commits)

1. `Ajouter les illustrations dessinées de Noorwan Connect` : `connect-hero|personal|pro|code|data|partner.svg` (1,4 à 2,9 ko).
2. `Ajouter la page Noorwan Connect à l'adresse /connect` : `public/connect.php`, chaînes `connect.*`, `meta.connect_*`, `nav.connect` (FR, EN, AR), menu et pied de page, réécriture, styles (`.connect-*`, `.badge-soon`), tests.
3. `Renommer « Connexion » en « Mon compte » dans l'en-tête` : libellés, commentaires, `.env.example`, `account_url()` (adresse vide), tests.
4. `Garder « Mon compte » sur une ligne dans les textes de Noorwan Connect`.
5. Ce journal et `docs/CONTENUS.md` (section v5, textes proposés par Maestro, à valider).

## Vérifications

- `tests/run.sh` vert (serveur intégré de PHP sur 127.0.0.1:8057 avec `tests/router.php`, MariaDB jetable dans `/tmp/noorwan-exec-v5/`, port 3351). Nouvelle section « 2 septdecies » : page servie à `/connect` et `connect.php`, réécriture présente, menu, canonique, titre, cinq sections, douze points, six illustrations, « Bientôt » sans date, aucun produit confidentiel ni numéro, boutons présents et absents selon le réglage, pied de page, règle sans miroir. Mises à jour : plan du site (8 pages, 24 adresses), libellé « Mon compte », page Connect ajoutée aux contrôles OnePay et Reserva, poids et absence de texte des six SVG, adresse vide.
- Captures (Playwright, Chromium) : page Connect en FR 390 et 1440, EN 768, AR 390 et 1440, en-tête à 834 px (la largeur la plus serrée du menu ordinateur) en trois langues, menu mobile ouvert FR et AR, accueil EN 390, page Connect avec le lien désactivé. Aucun débordement horizontal. Le site n'a pas de thème sombre.

## Ce qui reste

- Marwan : valider les textes (CONTENUS.md, section v5) ; arabe et anglais à relire.
- Mise en service : rien à faire de plus que pour « Connexion » (`COMPTE_LINK_ENABLED=true` sur le VPS quand le Compte est ouvert au public). La réécriture `/connect` exige `mod_rewrite` et `AllowOverride` sur le VPS, déjà nécessaires pour `robots.txt`.

## Pièges

- `tests/run.sh` réaffecte `DB_HOST` (hôte sans port) : si `DB_HOST` est exporté dans l'environnement, `bin/purge-contacts.php` perd le port. Les réglages locaux vont donc dans `.env`, pas dans l'environnement.
- Dans `lang/ar.php`, les échappements `\u{2066}` ne marchent qu'entre guillemets doubles.
- Les captures pleine page ne chargent pas les images `lazy` hors écran : passées en `eager` avant la capture (comme en v4).
