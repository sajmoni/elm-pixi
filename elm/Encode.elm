module Encode exposing (encodeEntities, encodeEntity)

import Json.Encode exposing (..)
import Pixi exposing (..)


encodeEntities : List Entity -> Value
encodeEntities =
    list encodeEntity


encodeBasicData : BasicData -> List ( String, Value )
encodeBasicData basicData =
    [ ( "id", string basicData.id )
    , ( "x", float basicData.x )
    , ( "y", float basicData.y )
    , ( "scale", float (Maybe.withDefault 1 basicData.scale) )
    , ( "alpha", float (Maybe.withDefault 1 basicData.alpha) )
    ]


encodeShape : Shape -> List ( String, Value )
encodeShape shape =
    case shape of
        Rectangle width height ->
            [ ( "width", int width )
            , ( "height", int height )
            ]


encodeEntity : Entity -> Value
encodeEntity entity =
    case entity of
        Text basicData textData ->
            object
                (List.append
                    (encodeBasicData basicData)
                    [ ( "text", string textData.textString )
                    , ( "textStyle"
                      , object
                            [ ( "fill", string textData.textStyle.fill )
                            ]
                      )
                    , ( "type", string "Text" )
                    ]
                )

        AnimatedSprite basicData textData ->
            object
                (List.append
                    (encodeBasicData basicData)
                    [ ( "textures", list string textData.textures )
                    , ( "animationSpeed", float (Maybe.withDefault 0.05 textData.animationSpeed) )
                    , ( "type", string "AnimatedSprite" )
                    ]
                )

        Sprite basicData spriteData ->
            object
                (List.append
                    (encodeBasicData basicData)
                    [ ( "texture", string spriteData.texture )
                    , ( "type", string "Sprite" )
                    ]
                )

        Graphics basicData graphicsData ->
            object
                (encodeShape graphicsData.shape
                    ++ encodeBasicData basicData
                    ++ [ ( "color", string graphicsData.color )
                       , ( "type", string "Graphics" )
                       ]
                )

        _ ->
            Debug.todo "No JSON encoding for other entity types"
