module Encode exposing (encodeEntities, encodeEntity)

import Json.Encode exposing (..)
import Pixi exposing (Entity(..))


encodeEntities : List Entity -> Value
encodeEntities =
    list encodeEntity


encodeEntity : Entity -> Value
encodeEntity entity =
    case entity of
        Text data ->
            object
                [ ( "id", string data.id )
                , ( "x", float data.x )
                , ( "y", float data.y )
                , ( "scale", float (Maybe.withDefault 1 data.scale) )
                , ( "text", string data.textString )

                -- , ( "textStyle", float (Maybe.withDefault 0.05 data.animationSpeed) )
                , ( "type", string "Text" )
                ]

        AnimatedSprite data ->
            object
                [ ( "id", string data.id )
                , ( "x", float data.x )
                , ( "y", float data.y )
                , ( "scale", float (Maybe.withDefault 1 data.scale) )
                , ( "textures", list string data.textures )
                , ( "animationSpeed", float (Maybe.withDefault 0.05 data.animationSpeed) )
                , ( "type", string "AnimatedSprite" )
                ]

        _ ->
            Debug.todo "No JSON encoding for other entity types"
