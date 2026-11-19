// Thème clair ou sombre (v9). Chargé dans <head> sans defer, avant la feuille de style : le thème choisi
// est posé avant le premier rendu, sans éclair blanc. Fichier du site : autorisé par la CSP (script-src 'self').
// À l'arrivée, le site suit l'appareil (feuille de style, @media prefers-color-scheme). Un choix différent de
// l'appareil est gardé dans localStorage (aucun cookie) et posé en data-theme sur <html> ; un choix qui
// redevient celui de l'appareil est oublié, et le site suit de nouveau l'appareil.
(function () {
    'use strict';

    var KEY = 'nw-theme';
    var root = document.documentElement;
    var device = window.matchMedia ? window.matchMedia('(prefers-color-scheme: dark)') : null;

    function readChoice() {
        try {
            var value = window.localStorage.getItem(KEY);
            return value === 'dark' || value === 'light' ? value : null;
        } catch (error) {
            return null;
        }
    }

    function saveChoice(value) {
        try {
            if (value) {
                window.localStorage.setItem(KEY, value);
            } else {
                window.localStorage.removeItem(KEY);
            }
        } catch (error) {
            // Stockage refusé (navigation privée) : le choix vaut pour la page seulement.
        }
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

    // Boutons « Passer en sombre » et « Passer en clair » : l'icône montre le thème affiché
    // (soleil en clair, croissant de lune en sombre), le libellé dit ce que fait le clic.
    function updateButtons() {
        var shown = choice || deviceTheme();
        var buttons = document.querySelectorAll('.theme-toggle');
        for (var i = 0; i < buttons.length; i++) {
            var label = buttons[i].getAttribute(shown === 'dark' ? 'data-label-light' : 'data-label-dark');
            buttons[i].setAttribute('data-shown', shown);
            buttons[i].setAttribute('aria-label', label);
            var text = buttons[i].querySelector('.theme-toggle-text');
            if (text) {
                text.textContent = label;
            }
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

    // Choix fait dans un autre onglet du site.
    window.addEventListener('storage', function (event) {
        if (event.key === KEY) {
            apply(readChoice() || deviceTheme());
        }
    });
})();
