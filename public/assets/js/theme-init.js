// Thème clair ou sombre (v9). Chargé dans <head> sans defer, avant la feuille de style : le thème choisi
// est posé avant le premier rendu, sans éclair blanc. Fichier du site : autorisé par la CSP (script-src 'self').
// À l'arrivée, le site suit l'appareil (feuille de style, @media prefers-color-scheme). Un choix différent de
// l'appareil est gardé six mois sur l'appareil dans le cookie nw_theme (« dark » ou « light », non chiffré, aucune
// donnée personnelle, socle du lanceur L6) et posé en data-theme sur <html> ; un choix qui redevient celui de
// l'appareil est oublié, et le site suit de nouveau l'appareil. Un ancien choix gardé dans localStorage (nw-theme,
// avant le lanceur) passe une fois dans le cookie, puis localStorage est vidé.
(function () {
    'use strict';

    var COOKIE = 'nw_theme';
    var MAX_AGE = 182 * 86400;
    var LEGACY_KEY = 'nw-theme';
    var root = document.documentElement;
    var device = window.matchMedia ? window.matchMedia('(prefers-color-scheme: dark)') : null;

    function valid(value) {
        return value === 'dark' || value === 'light' ? value : null;
    }

    function readCookie() {
        var match = document.cookie.match(/(?:^|;\s*)nw_theme=(dark|light)(?:;|$)/);
        return match ? match[1] : null;
    }

    function saveChoice(value) {
        var tail = '; Path=/; SameSite=Lax' + (window.location.protocol === 'https:' ? '; Secure' : '');
        document.cookie = COOKIE + '=' + (value ? value + '; Max-Age=' + MAX_AGE : '; Max-Age=0') + tail;
    }

    // Ancien choix de localStorage : repris une fois dans le cookie, puis effacé.
    function readChoice() {
        var value = readCookie();
        try {
            var legacy = valid(window.localStorage.getItem(LEGACY_KEY));
            if (legacy !== null) {
                window.localStorage.removeItem(LEGACY_KEY);
                if (value === null) {
                    value = legacy;
                    saveChoice(value);
                }
            }
        } catch (error) {
            // Stockage refusé (navigation privée) : rien à reprendre.
        }
        return value;
    }

    function deviceTheme() {
        return device && device.matches ? 'dark' : 'light';
    }

    var choice = readChoice();

    // Versions sombres des illustrations (<source>) et couleurs de la barre du navigateur (theme-color) :
    // media suit l'appareil, ou force la version du thème choisi.
    function setMedia(element) {
        var kind = element.getAttribute('data-theme-media');
        element.setAttribute('media', choice ? (choice === kind ? 'all' : 'not all') : '(prefers-color-scheme: ' + kind + ')');
    }

    function setAllMedia() {
        var elements = document.querySelectorAll('[data-theme-media]');
        for (var i = 0; i < elements.length; i++) {
            setMedia(elements[i]);
        }
    }

    // Boutons « Passer en sombre » et « Passer en clair » : l'icône annonce le thème vers lequel on bascule
    // (croissant de lune en clair, soleil en sombre), le libellé dit ce que fait le clic.
    function updateButtons() {
        var shown = choice || deviceTheme();
        var buttons = document.querySelectorAll('.theme-toggle');
        for (var i = 0; i < buttons.length; i++) {
            var label = buttons[i].getAttribute(shown === 'dark' ? 'data-label-light' : 'data-label-dark');
            buttons[i].setAttribute('data-shown', shown);
            buttons[i].setAttribute('aria-label', label);
            buttons[i].hidden = false;
        }
    }

    function apply(value) {
        choice = value === deviceTheme() ? null : value;
        saveChoice(choice);
        if (choice) {
            root.setAttribute('data-theme', choice);
        } else {
            root.removeAttribute('data-theme');
        }
        setAllMedia();
        updateButtons();
    }

    if (choice) {
        root.setAttribute('data-theme', choice);
        setAllMedia();
        // Les images arrivent pendant la lecture de la page : leur media est corrigé dès leur insertion,
        // avant que le navigateur ne choisisse la version à afficher.
        if (window.MutationObserver) {
            var observer = new MutationObserver(function (records) {
                for (var i = 0; i < records.length; i++) {
                    for (var j = 0; j < records[i].addedNodes.length; j++) {
                        var node = records[i].addedNodes[j];
                        if (node.nodeType === 1 && node.hasAttribute('data-theme-media')) {
                            setMedia(node);
                        }
                    }
                }
            });
            observer.observe(root, { childList: true, subtree: true });
            document.addEventListener('DOMContentLoaded', function () {
                observer.disconnect();
            });
        }
    }

    document.addEventListener('DOMContentLoaded', function () {
        setAllMedia();
        updateButtons();
        document.addEventListener('click', function (event) {
            var button = event.target.closest ? event.target.closest('.theme-toggle') : null;
            if (button) {
                apply((choice || deviceTheme()) === 'dark' ? 'light' : 'dark');
            }
        });
    });

    // L'appareil change de thème : sans choix, le site suit ; un choix devenu celui de l'appareil est oublié.
    if (device) {
        var onDeviceChange = function () {
            apply(choice || deviceTheme());
        };
        if (device.addEventListener) {
            device.addEventListener('change', onDeviceChange);
        } else if (device.addListener) {
            device.addListener(onDeviceChange);
        }
    }
})();
