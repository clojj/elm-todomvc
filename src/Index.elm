module Index exposing (htmlToReinject, index)

import Html.String exposing (..)
import Html.String.Attributes exposing (..)
import Html.String.Extra exposing (..)
import Main
import Starter.ConfMeta
import Starter.FileNames
import Starter.Flags
import Starter.Icon
import Starter.SnippetCss
import Starter.SnippetHtml
import Starter.SnippetJavascript


index : Starter.Flags.Flags -> Html msg
index flags =
    let
        relative =
            Starter.Flags.toRelative flags

        fileNames =
            Starter.FileNames.fileNames flags.version flags.commit
    in
    html
        [ lang "en" ]
        [ head []
            ([]
                ++ [ meta [ charset "utf-8" ] []
                   , title_ [] [ text flags.nameLong ]
                   , meta [ name "author", content flags.author ] []
                   , meta [ name "description", content flags.description ] []
                   , meta [ name "viewport", content "width=device-width, initial-scale=1, shrink-to-fit=no" ] []
                   , meta [ httpEquiv "x-ua-compatible", content "ie=edge" ] []
                   , link [ rel "icon", href (Starter.Icon.iconFileName relative 64) ] []
                   , link [ rel "apple-touch-icon", href (Starter.Icon.iconFileName relative 152) ] []
                   , link [ rel "stylesheet", href "/base.css" ] []
                   , link [ rel "stylesheet", href "/index.css" ] []
                   , link [ rel "stylesheet", href "/a11y.css" ] []
                   ]
                ++ Starter.SnippetHtml.messagesStyle
                ++ Starter.SnippetHtml.pwa
                    { commit = flags.commit
                    , relative = relative
                    , themeColor = Starter.Flags.toThemeColor flags
                    , version = flags.version
                    }
                ++ Starter.SnippetHtml.previewCards
                    { commit = flags.commit
                    , flags = flags
                    , mainConf = Main.conf
                    , version = flags.version
                    }
            )
        , body []
            ([]
                -- Friendly message in case Javascript is disabled
                ++ (if flags.env == "dev" then
                        Starter.SnippetHtml.messageYouNeedToEnableJavascript

                    else
                        Starter.SnippetHtml.messageEnableJavascriptForBetterExperience
                   )
                -- "Loading..." message
                ++ Starter.SnippetHtml.messageLoading
                -- The DOM node that Elm will take over
                ++ [ div [ id "elm" ] [] ]
                -- Activating the "Loading..." message
                ++ Starter.SnippetHtml.messageLoadingOn
                -- Loading Elm code
                ++ [ script [ src (relative ++ fileNames.outputCompiledJsProd) ] [] ]
                -- Elm finished to load, de-activating the "Loading..." message
                ++ Starter.SnippetHtml.messageLoadingOff
                -- Loading utility for pretty console formatting
                ++ Starter.SnippetHtml.prettyConsoleFormatting relative flags.env
                -- Signature "Made with ??? and Elm"
                ++ [ script [] [ textUnescaped Starter.SnippetJavascript.signature ] ]
                -- Paasing metadata to Elm, initializing "window.ElmStarter"
                ++ [ script [] [ textUnescaped <| Starter.SnippetJavascript.metaInfo flags ] ]
                -- Let's start Elm!
                ++ [ Html.String.Extra.script []
                        [ Html.String.textUnescaped
                            """
                            var storedState = localStorage.getItem('elm-todo-save');
                            var startingState = storedState ? JSON.parse(storedState) : null;
                            var node = document.getElementById('elm');
                            window.ElmApp = Elm.Main.init(
                                { node: node
                                , flags: startingState
                                }
                            );
                            // Ports
                            ElmApp.ports.setStorage.subscribe(function(state) {
                                localStorage.setItem('elm-todo-save', JSON.stringify(state));
                            });"""
                        ]
                   ]
                -- Register the Service Worker, we are a PWA!
                ++ [ script [] [ textUnescaped (Starter.SnippetJavascript.registerServiceWorker relative) ] ]
            )
        ]


htmlToReinject : a -> List b
htmlToReinject _ =
    []
