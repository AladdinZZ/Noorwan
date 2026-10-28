// Menu mobile. Sans JavaScript, le bouton reste masqué et la navigation mobile s'affiche telle quelle.
(function () {
    'use strict';

    var button = document.querySelector('.menu-toggle');
    var menu = button ? document.getElementById(button.getAttribute('aria-controls')) : null;
    if (!button || !menu) {
        return;
    }

    function setOpen(open) {
        button.setAttribute('aria-expanded', open ? 'true' : 'false');
        menu.hidden = !open;
    }

    setOpen(false);
    button.hidden = false;

    button.addEventListener('click', function () {
        setOpen(button.getAttribute('aria-expanded') !== 'true');
    });

    // Un lien choisi ferme le menu (les liens sont surtout des ancres de la même page).
    menu.addEventListener('click', function (event) {
        if (event.target.closest('a')) {
            setOpen(false);
        }
    });

    // Échap ferme le menu et rend le focus au bouton.
    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape' && button.getAttribute('aria-expanded') === 'true') {
            setOpen(false);
            button.focus();
        }
    });

    // Passage en largeur bureau : le menu mobile se referme.
    var desktop = window.matchMedia('(min-width: 881px)');
    var onChange = function (event) {
        if (event.matches) {
            setOpen(false);
        }
    };
    if (desktop.addEventListener) {
        desktop.addEventListener('change', onChange);
    }
})();

// Menu des langues. Sans JavaScript, <details> s'ouvre et se ferme seul (clic, Entrée, Espace) ;
// ici s'ajoutent la fermeture par Échap, par un clic extérieur et quand le focus quitte le menu.
(function () {
    'use strict';

    var menu = document.querySelector('.lang-menu');
    if (!menu) {
        return;
    }
    var summary = menu.querySelector('summary');

    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape' && menu.open) {
            menu.open = false;
            summary.focus();
        }
    });

    document.addEventListener('click', function (event) {
        if (menu.open && !menu.contains(event.target)) {
            menu.open = false;
        }
    });

    // Tabulation au-delà de la dernière langue : le menu se referme.
    document.addEventListener('focusin', function (event) {
        if (menu.open && !menu.contains(event.target)) {
            menu.open = false;
        }
    });
})();

// Après un envoi, le message de succès ou d'erreur reçoit le focus pour être annoncé.
(function () {
    'use strict';

    var alert = document.querySelector('[data-autofocus]');
    if (alert) {
        alert.focus();
    }
})();
