// Gece bottom bar. Removes existing panels, then recreates the Gece one.
// Run with: qdbus-qt6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat layout.js)"
var plasma = getApiVersion(1);
panels().forEach(function (p) { p.remove(); });

var layout = {
    "panels": [
        {
            "alignment": "center",
            "applets": [
                {
                    "config": {
                        "/": {
                            "popupHeight": "493",
                            "popupWidth": "633"
                        },
                        "/General": {
                            "favoritesPortedToKAstats": "true",
                            "icon": "distributor-logo-fedora"
                        }
                    },
                    "plugin": "org.kde.plasma.kickoff"
                },
                {
                    "config": {
                        "/General": {
                            "displayedText": "None",
                            "showWindowIcons": "false"
                        }
                    },
                    "plugin": "org.kde.plasma.pager"
                },
                {
                    "config": {},
                    "plugin": "org.kde.plasma.panelspacer"
                },
                {
                    "config": {
                        "/General": {
                            "iconSpacing": "1",
                            "launchers": "applications:org.kde.dolphin.desktop,applications:kitty.desktop,applications:com.microsoft.VSCode.desktop,preferred://browser,applications:com.brave.Browser.flextop.brave-fmpnliohjhemenmnlpbfagaolkdacoja-Default.desktop,applications:com.brave.Browser.flextop.brave-gdfaincndogidkdcdkhapmbffkckdkhn-Default.desktop,applications:md.obsidian.Obsidian.desktop,applications:io.github.htulu07.Penguchat.desktop,applications:org.telegram.desktop.desktop,applications:com.spotify.Client.desktop,applications:steam.desktop",
                            "maxStripes": "1"
                        }
                    },
                    "plugin": "org.kde.plasma.icontasks"
                },
                {
                    "config": {},
                    "plugin": "org.kde.plasma.trash"
                },
                {
                    "config": {},
                    "plugin": "org.kde.plasma.panelspacer"
                },
                {
                    "config": {},
                    "plugin": "plasmusic-toolbar"
                },
                {
                    "config": {},
                    "plugin": "org.kde.plasma.systemtray"
                },
                {
                    "config": {
                        "/": {
                            "popupHeight": "487",
                            "popupWidth": "525"
                        }
                    },
                    "plugin": "org.gece.kontrol"
                },
                {
                    "config": {
                        "/": {
                            "popupHeight": "375",
                            "popupWidth": "525"
                        },
                        "/Appearance": {
                            "customDateFormat": "d MMM ddd",
                            "dateDisplayFormat": "BelowTime",
                            "dateFormat": "custom",
                            "showDate": "true",
                            "use24hFormat": "2"
                        }
                    },
                    "plugin": "org.kde.plasma.digitalclock"
                }
            ],
            "config": {
                "/": {
                    "formfactor": "2",
                    "immutability": "1",
                    "wallpaperplugin": "org.kde.image"
                }
            },
            "height": 2.875,
            "hiding": "normal",
            "lengthMode": "fill",
            "location": "bottom",
            "maximumLength": 120,
            "minimumLength": 120,
            "offset": 0,
            "opacity": "adaptive"
        }
    ],
    "serializationFormatVersion": "1"
};

plasma.loadSerializedLayout(layout);
