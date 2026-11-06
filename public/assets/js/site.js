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
    var desktop = window.matchMedia('(min-width: 834px)');
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

// Consentement à la mesure d'audience (M-59). Sans JavaScript, les boutons envoient le formulaire à consent.php
// et la page revient avec le choix enregistré. Ici : envoi en arrière-plan, puis chargement de Tag Manager
// sur « Accepter » ; « Refuser » après un accord recharge la page pour retirer Tag Manager.
(function () {
    'use strict';

    var banner = document.getElementById('consent');
    var bootstrap = document.getElementById('gtm-bootstrap');
    if (!banner || !bootstrap) {
        return;
    }

    function loadTagManager() {
        if (document.querySelector('script[src^="https://www.googletagmanager.com/gtm.js"]')) {
            return;
        }
        window.dataLayer.push({ 'gtm.start': new Date().getTime(), event: 'gtm.js' });
        var script = document.createElement('script');
        script.async = true;
        script.src = 'https://www.googletagmanager.com/gtm.js?id=' + encodeURIComponent(bootstrap.getAttribute('data-gtm-id'));
        script.setAttribute('nonce', bootstrap.nonce);
        document.head.appendChild(script);
    }

    function close() {
        banner.hidden = true;
    }

    document.addEventListener('submit', function (event) {
        var form = event.target;
        if (!form.classList || !form.classList.contains('consent-actions') || !window.fetch || !window.FormData) {
            return;
        }
        event.preventDefault();
        var data = new FormData(form);
        var choice = event.submitter ? event.submitter.value : 'denied';
        data.set('choice', choice);

        fetch(form.action, { method: 'POST', body: data, headers: { Accept: 'application/json' }, credentials: 'same-origin' })
            .then(function (response) {
                if (!response.ok) {
                    throw new Error('consent');
                }
                var previous = banner.getAttribute('data-state');
                banner.setAttribute('data-state', choice);
                // Page Cookies (état affiché) ou retrait d'un accord : la page se recharge sans Tag Manager.
                if (form.closest('#consent-manage') || (choice === 'denied' && previous === 'granted')) {
                    window.location.reload();
                    return;
                }
                if (choice === 'granted') {
                    window.gtag('consent', 'update', { analytics_storage: 'granted' });
                    loadTagManager();
                }
                close();
            })
            .catch(function () {
                form.submit();
            });
    });

    // « Gérer les cookies » rouvre le bandeau au lieu de quitter la page.
    document.addEventListener('click', function (event) {
        var link = event.target.closest('[data-consent-open]');
        if (!link) {
            return;
        }
        event.preventDefault();
        banner.hidden = false;
        var first = banner.querySelector('button');
        if (first) {
            first.focus();
        }
    });
})();
