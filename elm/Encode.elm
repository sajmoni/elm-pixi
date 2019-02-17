module Encode exposing (encodeEntities, encodeEntity)

import Json.Encode exposing (..)
import Pixi exposing (..)


encodeEntities : List Entity -> Value
encodeEntities =
    list encodeEntity


encodeEntity : Entity -> Value
encodeEntity entity =
    case entity of
        Text basicData textData ->
            object
                [ ( "id", string basicData.id )
                , ( "x", float basicData.x )
                , ( "y", float basicData.y )
                , ( "scale", float (Maybe.withDefault 1 basicData.scale) )
                , ( "text", string textData.textString )
                , ( "textStyle"
                  , object
                        [ ( "fill", string textData.textStyle.fill )
                        ]
                  )
                , ( "type", string "Text" )
                ]

        AnimatedSprite basicData textData ->
            object
                [ ( "id", string basicData.id )
                , ( "x", float basicData.x )
                , ( "y", float basicData.y )
                , ( "scale", float (Maybe.withDefault 1 basicData.scale) )
                , ( "textures", list string textData.textures )
                , ( "animationSpeed", float (Maybe.withDefault 0.05 textData.animationSpeed) )
                , ( "type", string "AnimatedSprite" )
                ]

        Sprite basicData spriteData ->
            object
                [ ( "id", string basicData.id )
                , ( "x", float basicData.x )
                , ( "y", float basicData.y )
                , ( "scale", float (Maybe.withDefault 1 basicData.scale) )
                , ( "texture", string spriteData.texture )
                , ( "type", string "Sprite" )
                ]

        _ ->
            Debug.todo "No JSON encoding for other entity types"
