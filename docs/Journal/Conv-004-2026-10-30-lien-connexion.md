# Conv-004 : lien « Connexion » vers le Compte Noorwan (30/10/2026)

Branche `feat/lien-connexion`, **non poussée, non fusionnée** : relecture de Marwan, puis `git merge --no-ff feat/lien-connexion` et push (déploiement automatique en production). Le site n'a pas de base d'identité : seul le lien est ajouté, rien d'autre ne change.

## Livré

Commit unique « Ajouter le lien Connexion vers le Compte Noorwan ».

| Élément | Contenu |
|---|---|
| Configuration | `app/bootstrap.php` : constantes `COMPTE_URL` (défaut `https://compte.noorwan.com`, barre finale retirée) et `COMPTE_LINK_ENABLED` (défaut `false`, vrai seulement si `.env` dit `true`), lues dans `.env`. `.env.example` : `COMPTE_URL=https://compte.noorwan.com`, `COMPTE_LINK_ENABLED=false`. Les constantes peuvent être définies avant l'amorçage (utilisé par les tests) |
| Adresse | `account_url()` (`app/i18n.php`) : `COMPTE_URL/?lang={langue courante}`, ou `null` quand le lien est désactivé. Les vues n'utilisent que cette fonction |
| Menu | `app/layout/header.php` : « Connexion » ajouté en dernier élément de `$navItems`, classe `nav-account`. Il apparaît donc dans le menu ordinateur, le menu mobile et le pied de page (qui reprend `$navItems`) |
| Style | `site.css` : ordinateur, gris (`--text-3`) et séparé du menu par un filet vertical ; mobile, plus petit (16 px, graisse normale, gris) ; pied de page, même style que les autres liens. Propriétés logiques, le filet passe à gauche en arabe |
| Page Solutions | Sous l'introduction : « Un seul compte pour tous les services Noorwan. » suivi du lien « Connexion → » (`.page-account`), soumis à la même constante |
| Chaînes | `nav.account` : Connexion, Sign in, الدخول. `solutions.account_text` : « Un seul compte pour tous les services Noorwan. », « One account for all Noorwan services. », « حساب واحد لجميع خدمات نوروان. » (arabe marqué « À relire ») |
| `docs/CONTENUS.md` | Lien « Connexion » dans « Commun » (menu et pied de page) et phrase de la page Solutions |

## Vérifications

- `tests/run.sh` sous MAMP : **226 contrôles au vert** (193 au départ). Nouvelle section « 2 undecies » : les pages sont rendues hors serveur par PHP en ligne de commande, constantes fixées avant l'amorçage, ce qui teste les deux états sans toucher au `.env` :
  - désactivé : aucun lien ni phrase sur l'accueil, Solutions et Édition (FR, EN, AR) ;
  - activé : « Connexion », « Sign in », « الدخول » en dernier élément du menu, du menu mobile et du pied de page, adresse `?lang=` dans la bonne langue ; phrase et lien sous l'introduction de la page Solutions ; 4 liens sur Solutions, 3 sur l'accueil (sans phrase) ; aucun tiret cadratin dans les pages rendues ;
  - `COMPTE_URL` modifiée : les liens suivent sans toucher aux vues ;
  - site servi : le lien suit `COMPTE_LINK_ENABLED` (masqué en local) ; `.env.example` le désactive.
- Chrome sans interface, piloté par son protocole de débogage (émulation réelle de la largeur ; l'option `--window-size` ne descend pas sous 500 px environ), lien activé le temps du contrôle puis `.env` remis à l'identique : accueil et Solutions à 390, 768 et 1440 px en FR, EN, AR, aucun défilement horizontal ; menu mobile ouvert vérifié en FR et AR.

## Mise en service (Marwan)

Après la mise en ligne de `compte.noorwan.com`, ajouter `COMPTE_LINK_ENABLED=true` au `.env` du VPS (et `COMPTE_URL` si l'adresse change). Aucun déploiement de code n'est nécessaire.

## Points à trancher

1. **Phrase de la page Solutions** : un point final ajouté (« … services Noorwan. Connexion → ») pour séparer la phrase du lien. Le brief l'écrit sans point.
2. **Arabe** : « الدخول » (imposé par le brief) et « حساب واحد لجميع خدمات نوروان. » sont à relire par un arabophone ; le nom est écrit « نوروان » comme dans le reste du site arabe.
3. **Position de la phrase** : placée entre l'introduction et le bouton « Demander une présentation », comme demandé (« sous l'introduction »). Elle pourrait aussi passer sous le bouton pour ne pas s'interposer entre le texte et l'appel principal.
4. **Lenteur locale de PHP en ligne de commande** : chaque appel à `php` prend environ 5 s ici (0,1 s de calcul), d'où une suite de tests de plusieurs minutes. Sans lien avec ce lot, à surveiller.
