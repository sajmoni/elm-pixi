module Main exposing (noop, suite)

import Behavior exposing (..)
import Test exposing (..)


noop : UpdateFunction gameState
noop delta currentUpdate gameState =
    ( gameState, Behavior.none )


suite : Test
suite =
    describe "The Behavior module"
        [ describe "foo"
            [ test "foo" <|
                \_ ->
                    let
                        currentUpdate =
                            1

                        gameState =
                            "State"

                        behavior =
                            Behavior.once "noop" noop 3 currentUpdate
                    in
                    Behavior.updateGameState 16.6 currentUpdate gameState [ behavior ]
            ]
        ]
