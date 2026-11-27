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
        var all = panel.querySelectorAll('.panel a[href], .panel button:not([disabled]), .panel input:not([type="hidden"])');
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

// Choix de cookies commun (M-129). Sans JavaScript, les formulaires du bandeau et du volet « Choisir » vont à
// consent.php et la page revient avec le choix enregistré. Ici : envoi en arrière-plan ; un nouvel accord à la mesure
// charge Tag Manager selon le choix (publicité seulement si elle est acceptée) ; un accord retiré, ou un choix fait
// depuis la page Cookies (état affiché), recharge la page sans mesure.
(function () {
    'use strict';

    var panel = document.getElementById('consent-panel');
    var bootstrap = document.getElementById('gtm-bootstrap');
    if (!panel || !bootstrap || !window.fetch || !window.FormData) {
        return;
    }
    var banner = document.getElementById('consent');

    function loadTagManager(ads) {
        var state = ads ? 'granted' : 'denied';
        window.gtag('consent', 'update', { analytics_storage: 'granted', ad_storage: state, ad_user_data: state, ad_personalization: state });
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

    function wanted(form, submitter) {
        var choice = submitter && submitter.name === 'choice' ? submitter.value : (form.elements.choice ? form.elements.choice.value : 'none');
        if (choice === 'custom') {
            return { choice: choice, analytics: form.elements.analytics.checked, ads: form.elements.ads.checked };
        }
        return { choice: choice, analytics: choice === 'all', ads: choice === 'all' };
    }

    document.addEventListener('submit', function (event) {
        var form = event.target;
        if (!form.hasAttribute || !form.hasAttribute('data-consent-form')) {
            return;
        }
        event.preventDefault();
        var next = wanted(form, event.submitter);
        var data = new FormData(form);
        data.set('choice', next.choice);

        fetch(form.action, { method: 'POST', body: data, headers: { Accept: 'application/json' }, credentials: 'same-origin' })
            .then(function (response) {
                if (!response.ok) {
                    throw new Error('consent');
                }
                var hadAnalytics = panel.getAttribute('data-analytics') === '1';
                var hadAds = panel.getAttribute('data-ads') === '1';
                if (document.getElementById('consent-manage') || (hadAnalytics && !next.analytics) || (hadAds && !next.ads)) {
                    window.location.reload();
                    return;
                }
                panel.setAttribute('data-analytics', next.analytics ? '1' : '0');
                panel.setAttribute('data-ads', next.ads ? '1' : '0');
                var boxes = document.getElementById('consent-choice');
                boxes.elements.analytics.checked = next.analytics;
                boxes.elements.ads.checked = next.ads;
                if (next.analytics) {
                    loadTagManager(next.ads);
                }
                if (banner) {
                    banner.hidden = true;
                    // La barre d'installation (M-132) attend ce choix pour venir à son tour.
                    document.dispatchEvent(new CustomEvent('nw-consent-closed'));
                }
                if (panel.classList.contains('is-open')) {
                    panel.querySelector('[data-panel-close]').click();
                }
            })
            .catch(function () {
                // Envoi ordinaire : le bouton pressé n'est pas transmis par submit(), le choix passe par un champ caché.
                var field = document.createElement('input');
                field.type = 'hidden';
                field.name = 'choice';
                field.value = next.choice;
                form.appendChild(field);
                form.submit();
            });
    });
})();

// Lanceur des sites (M-124) : une icône de site qui ne se charge pas laisse place à sa pastille (couleur et lettre).
// L'écoute se fait en phase de capture (l'erreur d'une image ne remonte pas) ; une image déjà en erreur avant ce
// script est rattrapée par son état (complete sans largeur).
(function () {
    'use strict';

    function fail(img) {
        var holder = img.closest('[data-launcher-icon]');
        if (holder) {
            holder.classList.add('is-failed');
        }
    }

    document.addEventListener('error', function (event) {
        var target = event.target;
        if (target && target.tagName === 'IMG' && target.closest && target.closest('[data-launcher-icon]')) {
            fail(target);
        }
    }, true);

    var images = document.querySelectorAll('[data-launcher-icon] img');
    for (var i = 0; i < images.length; i++) {
        if (images[i].complete && images[i].naturalWidth === 0) {
            fail(images[i]);
        }
    }
})();

// Installer le site sans magasin (M-132, modèle Reserva). Service worker minimal (sw.js : page hors ligne seulement)
// et barre « Installer l'application Noorwan » (#install-bar, app/layout/install.php), jamais une fenêtre surgissante :
// - Android : seulement quand le navigateur propose l'installation (beforeinstallprompt, gardé par preventDefault) ;
//   ouverte d'elle-même sur un téléphone quand la page le demande (data-auto : accueil, ?via=qr, ?via=launcher) ;
// - iPhone et iPad : mode d'emploi « Partager, puis Sur l'écran d'accueil » ;
// - jamais en mode application ni dans l'application Android (agent NoorwanApp) ; jamais tant que le bandeau des
//   cookies attend un choix (elle vient juste après) ;
// - « Plus tard » : ferme la barre pour la page en cours seulement, sans cookie ni stockage du navigateur ; elle revient
//   à chaque visite là où elle s'ouvre d'elle-même (décision de Marwan du 27/11/2026).
// L'entrée « Installer l'application » du volet du menu ([data-install-open]) lance l'installation ou montre le mode
// d'emploi. Mesure : seulement l'étape app_installed, sans paramètre, après l'accord a1.
(function () {
    'use strict';

    var ua = window.navigator.userAgent || '';
    if (ua.indexOf('NoorwanApp') !== -1) {
        return;
    }

    if ('serviceWorker' in navigator) {
        window.addEventListener('load', function () {
            navigator.serviceWorker.register('sw.js', { scope: './' }).catch(function () {
                // Pas de service worker (navigation privée, http) : le site marche sans.
            });
        });
    }

    var bar = document.getElementById('install-bar');
    var entries = document.querySelectorAll('[data-install-entry]');
    var media = function (query) {
        return window.matchMedia ? window.matchMedia(query).matches : false;
    };
    var standalone = media('(display-mode: standalone)') || media('(display-mode: minimal-ui)') || window.navigator.standalone === true;
    var isIos = /iphone|ipad|ipod/i.test(ua) || (window.navigator.platform === 'MacIntel' && window.navigator.maxTouchPoints > 1);
    var isAndroidPhone = /android/i.test(ua) && /mobile/i.test(ua);
    var deferred = null;
    var shown = false;

    function mode() {
        if (standalone) {
            return null;
        }
        if (deferred) {
            return 'android';
        }
        return isIos ? 'ios' : null;
    }

    function refreshEntries() {
        var visible = mode() !== null;
        for (var i = 0; i < entries.length; i++) {
            entries[i].hidden = !visible;
        }
    }

    // Le choix des cookies attend : bandeau présent et pas encore fermé.
    function consentPending() {
        var consent = document.getElementById('consent');
        return !!consent && !consent.hidden;
    }

    function show() {
        var current = mode();
        if (!bar || !current || consentPending()) {
            return false;
        }
        bar.setAttribute('data-mode', current);
        bar.hidden = false;
        shown = true;
        return true;
    }

    function hide() {
        if (bar && shown) {
            bar.hidden = true;
            shown = false;
        }
    }

    // Ouverture d'elle-même : page qui le demande, téléphone Android ou iPhone.
    function auto() {
        if (!bar || shown || bar.getAttribute('data-auto') !== '1') {
            return;
        }
        var current = mode();
        if ((current === 'android' && isAndroidPhone) || current === 'ios') {
            show();
        }
    }

    // « Plus tard » : pour la page en cours seulement.
    function later() {
        hide();
    }

    // Ouvre la fenêtre d'installation du navigateur (une seule fois par événement).
    function promptInstall() {
        if (!deferred) {
            return;
        }
        hide();
        var prompt = deferred;
        deferred = null;
        prompt.prompt();
        var done = function () {
            refreshEntries();
        };
        if (prompt.userChoice && prompt.userChoice.then) {
            prompt.userChoice.then(done, done);
        } else {
            done();
        }
    }

    window.addEventListener('beforeinstallprompt', function (event) {
        event.preventDefault();
        if (standalone) {
            return;
        }
        deferred = event;
        refreshEntries();
        auto();
    });

    window.addEventListener('appinstalled', function () {
        deferred = null;
        standalone = true;
        hide();
        refreshEntries();
        if (/(?:^|;\s*)nw_consent=v1\.a1\.m[01](?:;|$)/.test(document.cookie) && window.dataLayer) {
            window.dataLayer.push({ event: 'app_installed' });
        }
    });

    if (bar) {
        bar.querySelector('[data-install-now]').addEventListener('click', promptInstall);
        bar.querySelector('[data-install-later]').addEventListener('click', later);
        document.addEventListener('nw-consent-closed', auto);
        // iPhone : aucun événement du navigateur, la barre vient après le chargement.
        window.addEventListener('load', auto);
    }

    document.addEventListener('click', function (event) {
        var trigger = event.target.closest ? event.target.closest('[data-install-open]') : null;
        if (!trigger) {
            return;
        }
        event.preventDefault();
        var close = document.querySelector('.panel-layer.is-open .panel-close');
        if (close) {
            close.click();
        }
        if (deferred) {
            promptInstall();
        } else if (mode() === 'ios') {
            show();
        }
    });

    refreshEntries();
})();
