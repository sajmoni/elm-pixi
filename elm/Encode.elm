module Encode exposing (encodeEntities, encodeEntity)

import Json.Encode exposing (..)
import Pixi exposing (Entity(..))


encodeEntities : List Entity -> Value
encodeEntities =
    list encodeEntity


encodeEntity : Entity -> Value
encodeEntity entity =
    case entity of
        AnimatedSprite basicInformation textures animationSpeed ->
            object
                [ ( "id", string basicInformation.id )
                , ( "x", float basicInformation.x )
                , ( "y", float basicInformation.y )
                , ( "scale", float basicInformation.scale )
                , ( "textures", list string textures )
                , ( "animationSpeed", float animationSpeed )
                , ( "type", string "AnimatedSprite" )
                ]

        _ ->
            Debug.todo "No JSON encoding for other entity types"
