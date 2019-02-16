module Encode exposing (encodeEntities, encodeEntity)

import Json.Encode exposing (..)
import Pixi exposing (..)


encodeEntities : List Entity -> Value
encodeEntities =
    list encodeEntity


encodeEntity : Entity -> Value
encodeEntity entity =
    case entity of
        Text basicInformation textData ->
            object
                [ ( "id", string basicInformation.id )
                , ( "x", float basicInformation.x )
                , ( "y", float basicInformation.y )
                , ( "scale", float (Maybe.withDefault 1 basicInformation.scale) )
                , ( "text", string textData.textString )
                , ( "textStyle"
                  , object
                        [ ( "fill", string textData.textStyle.fill )
                        ]
                  )
                , ( "type", string "Text" )
                ]

        AnimatedSprite basicInformation textData ->
            object
                [ ( "id", string basicInformation.id )
                , ( "x", float basicInformation.x )
                , ( "y", float basicInformation.y )
                , ( "scale", float (Maybe.withDefault 1 basicInformation.scale) )
                , ( "textures", list string textData.textures )
                , ( "animationSpeed", float (Maybe.withDefault 0.05 textData.animationSpeed) )
                , ( "type", string "AnimatedSprite" )
                ]

        _ ->
            Debug.todo "No JSON encoding for other entity types"
