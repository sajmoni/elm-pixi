module Town exposing (behaviors, entities, interactions)

import Msg exposing (..)
import Pixi
import Shared exposing (..)


entities : List Pixi.Entity
entities =
    [ Pixi.text
        { id = "townTitle", x = 280, y = 145, scale = Just 4 }
        { textString = "Town", textStyle = { fill = "white", fontSize = 72 } }
    ]



-- Behaviors


behaviors : List Behavior
behaviors =
    []



-- Interactions


interactions : List Interaction
interactions =
    []
