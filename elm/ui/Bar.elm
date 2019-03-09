module Bar exposing (view)

import Msg exposing (..)
import Pixi


view : String -> Float -> Float -> String -> Float -> Float -> Pixi.Entity Msg
view id x y color current max =
    Pixi.graphics
        [ Pixi.id id
        , Pixi.x x
        , Pixi.y y
        , Pixi.color color
        , Pixi.shape (Pixi.Rectangle (200 * (current / max)) 25)
        ]
        []
