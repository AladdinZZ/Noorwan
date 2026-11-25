// Anciennes ancres de l'accueil (#consulting, #edition...) : l'élément visé porte data-hash-redirect,
// l'adresse de la page qui a pris sa place (v6). Sans JavaScript, l'ancre reste sur l'accueil.
(function () {
    'use strict';

    function follow() {
        var id = window.location.hash.slice(1);
        var target = id ? document.getElementById(decodeURIComponent(id)) : null;
        if (target && target.hasAttribute('data-hash-redirect')) {
            window.location.replace(target.getAttribute('data-hash-redirect'));
        }
    }

    follow();
    window.addEventListener('hashchange', follow);
})();

// Volets de la charte commune (M-118) : menu en début de ligne, connexion en fin de ligne, jamais de fenêtre surgissante.
// Sans JavaScript, chaque volet s'ouvre par son ancre (:target) et se ferme par « # ». Ici : ouverture sans changer
// l'adresse visible, une entrée d'historique pour que le retour arrière ferme, fermeture par la croix, le voile et Échap,
// focus gardé dans le volet puis rendu au bouton, page figée derrière.
(function () {
    'use strict';

    var panels = document.querySelectorAll('[data-panel]');
    if (!panels.length || !window.history || !window.history.pushState) {
        return;
    }
    var root = document.documentElement;
    // Les volets passent aux mains du script : l'ancre (:target) ne les ouvre plus (feuille de style).
    root.classList.add('js-panels');
    var current = null;
    var opener = null;

    function openers(panel) {
        return document.querySelectorAll('[data-panel-open][aria-controls="' + panel.id + '"]');
    }

    function setExpanded(panel, value) {
        var buttons = openers(panel);
        for (var i = 0; i < buttons.length; i++) {
            buttons[i].setAttribute('aria-expanded', value ? 'true' : 'false');
        }
    }

    // Éléments visibles seulement : la croix du lanceur est masquée dès 640 px.
    function focusables(panel) {
        var all = panel.querySelectorAll('.panel a[href], .panel button:not([disabled])');
        var shown = [];
        for (var i = 0; i < all.length; i++) {
            if (all[i].getClientRects().length) {
                shown.push(all[i]);
            }
        }
        return shown;
    }

    // Lanceur des sites dès 640 px : le panneau s'aligne sur le bord de fin du bouton « grille » (le bord droit, le
    // bord gauche en arabe), comme sur Connect ; sans script, il garde la marge de la feuille de style.
    function placeLauncher(panel, from) {
        if (!panel.classList.contains('panel-launcher') || !from) {
            return;
        }
        var rect = from.getBoundingClientRect();
        var rtl = root.getAttribute('dir') === 'rtl';
        var end = rtl ? rect.left : root.clientWidth - rect.right;
        panel.style.setProperty('--launcher-end', Math.max(0, Math.round(end)) + 'px');
    }

    function show(panel, from) {
        if (current && current !== panel) {
            hide(false);
        }
        var lang = document.querySelector('.lang-menu[open]');
        if (lang) {
            lang.open = false;
        }
        current = panel;
        opener = from || null;
        panel.classList.add('is-open');
        root.classList.add('has-panel');
        setExpanded(panel, true);
        placeLauncher(panel, opener);
        // Focus sur la croix, ou sur le premier élément quand elle est masquée (lanceur dès 640 px).
        var close = panel.querySelector('.panel-close');
        var items = close && close.getClientRects().length ? [close] : focusables(panel);
        if (items.length) {
            items[0].focus();
        }
    }

    function hide(restoreFocus) {
        if (!current) {
            return;
        }
        current.classList.remove('is-open');
        setExpanded(current, false);
        root.classList.remove('has-panel');
        current = null;
        if (restoreFocus !== false && opener) {
            opener.focus();
        }
        opener = null;
    }

    // Fermer par l'historique quand le volet y a laissé une entrée : le retour arrière et la croix font la même chose.
    function close() {
        if (window.history.state && window.history.state.nwPanel) {
            window.history.back();
        } else {
            hide();
        }
    }

    document.addEventListener('click', function (event) {
        var trigger = event.target.closest('[data-panel-open]');
        if (trigger) {
            var panel = document.getElementById(trigger.getAttribute('aria-controls'));
            if (panel) {
                event.preventDefault();
                if (current === panel) {
                    close();
                    return;
                }
                var replace = window.history.state && window.history.state.nwPanel;
                window.history[replace ? 'replaceState' : 'pushState']({ nwPanel: panel.id }, '');
                show(panel, trigger);
            }
            return;
        }
        if (current && event.target.closest('[data-panel-close]')) {
            event.preventDefault();
            close();
            return;
        }
        // Un lien vers une ancre de la page ferme le volet avant d'y mener.
        var link = current ? event.target.closest('.panel a[href^="#"]:not([data-panel-close])') : null;
        if (link) {
            hide(false);
        }
    });

    window.addEventListener('popstate', function (event) {
        var id = event.state && event.state.nwPanel;
        var panel = id ? document.getElementById(id) : null;
        if (panel) {
            show(panel, openers(panel)[0]);
        } else {
            hide();
        }
    });

    document.addEventListener('keydown', function (event) {
        if (!current) {
            return;
        }
        if (event.key === 'Escape') {
            event.preventDefault();
            close();
            return;
        }
        if (event.key === 'Tab') {
            var items = focusables(current);
            if (!items.length) {
                return;
            }
            var first = items[0];
            var last = items[items.length - 1];
            if (event.shiftKey && document.activeElement === first) {
                event.preventDefault();
                last.focus();
            } else if (!event.shiftKey && document.activeElement === last) {
                event.preventDefault();
                first.focus();
            } else if (!current.contains(document.activeElement)) {
                event.preventDefault();
                first.focus();
            }
        }
    });

    window.addEventListener('resize', function () {
        if (current) {
            placeLauncher(current, opener || openers(current)[0]);
        }
    });

    // Le volet du menu n'existe pas en grand écran (liens dans la barre) : il se referme en passant à 900 px.
    var wide = window.matchMedia('(min-width: 900px)');
    var onWide = function (event) {
        if (event.matches && current && current.id === 'menu-panel') {
            close();
        }
    };
    if (wide.addEventListener) {
        wide.addEventListener('change', onWide);
    }

    // Arrivée sur une adresse avec l'ancre d'un volet (lien partagé, page rechargée) : le volet s'ouvre de la même façon.
    var hash = window.location.hash.slice(1);
    var target = hash ? document.getElementById(hash) : null;
    if (target && target.hasAttribute('data-panel')) {
        window.history.replaceState(null, '', window.location.pathname + window.location.search);
        window.history.pushState({ nwPanel: target.id }, '');
        show(target, openers(target)[0]);
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
