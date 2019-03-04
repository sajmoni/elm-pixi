module Encode exposing (encodeEntities)

import Json.Encode as E
import Msg exposing (..)
import Pixi exposing (..)
import Shared exposing (..)


encodeEntities : List (Entity Msg) -> E.Value
encodeEntities =
    E.list encodeEntity


isOn : Attribute Msg -> Bool
isOn attribute =
    case attribute of
        On _ _ ->
            True

        _ ->
            False


combineLists : ( List ( String, E.Value ), List ( String, E.Value ) ) -> List ( String, E.Value )
combineLists ( list1, list2 ) =
    List.append list1 list2


encodeEntity : Entity Msg -> E.Value
encodeEntity entity =
    case entity of
        Text attributes children ->
            E.object
                (( "type", E.string "Text" )
                    :: encode attributes
                )

        Container attributes children ->
            E.object
                (( "type", E.string "Container" )
                    :: encode attributes
                )

        AnimatedSprite attributes children ->
            E.object
                (( "type", E.string "AnimatedSprite" )
                    :: encode attributes
                )

        Sprite attributes children ->
            E.object
                (( "type", E.string "Sprite" )
                    :: encode attributes
                )

        Graphics attributes children ->
            E.object
                (( "type", E.string "Graphics" )
                    :: encode attributes
                )

        _ ->
            Debug.todo "encoding failed"


encode : List (Attribute Msg) -> List ( String, E.Value )
encode attributes =
    attributes
        |> List.partition isOn
        |> Tuple.mapBoth encodeOns (List.map encodeAttribute)
        |> combineLists


getEncodedMessage : String -> String -> Maybe String -> List ( String, E.Value )
getEncodedMessage event msg value =
    let
        encodedValue =
            case value of
                Just string ->
                    E.string string

                Nothing ->
                    E.null
    in
    [ ( "event", E.string event ), ( "msg", E.string msg ), ( "value", encodedValue ) ]


encodeOns : List (Attribute Msg) -> List ( String, E.Value )
encodeOns attributes =
    [ ( "on", E.list encodeOn attributes ) ]



-- E.list encodedAttributes


encodeOn : Attribute Msg -> E.Value
encodeOn attribute =
    case attribute of
        On event msg ->
            case msg of
                ChangeAppState appState ->
                    case appState of
                        Quest _ ->
                            E.object (getEncodedMessage event "ChangeAppState" (Just "Quest"))

                        Town ->
                            E.object (getEncodedMessage event "ChangeAppState" (Just "Town"))

                        Title ->
                            E.object (getEncodedMessage event "ChangeAppState" (Just "Title"))

                SetTextColor color ->
                    E.object (getEncodedMessage event "SetTextColor" (Just color))

                DealDamage ->
                    E.object (getEncodedMessage event "DealDamage" Nothing)

                GenerateNewQuest ->
                    E.object (getEncodedMessage event "GenerateNewQuest" Nothing)

                _ ->
                    Debug.todo "encode more messages"

        _ ->
            Debug.todo "This should never happen"


encodeTextStyle : TextStyle -> ( String, E.Value )
encodeTextStyle textStyle =
    case textStyle of
        Fill color ->
            ( "fill", E.string color )

        FontSize size ->
            ( "fontSize", E.float size )



-- _ ->
--     Debug.todo "add more textstyle"


encodeString : String -> E.Value
encodeString string =
    E.string string


encodeAttribute : Attribute Msg -> ( String, E.Value )
encodeAttribute attribute =
    case attribute of
        Id id ->
            ( "id", E.string id )

        Scale scale ->
            ( "scale", E.float scale )

        X x ->
            ( "x", E.float x )

        Y y ->
            ( "y", E.float y )

        TextString string ->
            ( "textString", E.string string )

        TextStyle textStyles ->
            ( "textStyle", E.object (List.map encodeTextStyle textStyles) )

        Texture string ->
            ( "texture", E.string string )

        Textures textures ->
            ( "textures", E.list encodeString textures )

        AnimationSpeed speed ->
            ( "animationSpeed", E.float speed )

        Color color ->
            ( "color", E.string color )

        Shape s ->
            ( "shape", encodeShape s )

        _ ->
            Debug.todo "encode attribute failed"


encodeShape : Shape -> E.Value
encodeShape shape =
    case shape of
        Rectangle width height ->
            E.object
                [ ( "width", E.float width )
                , ( "height", E.float height )
                , ( "type", E.string "Rectangle" )
                ]

        _ ->
            Debug.todo "handle more shapes when encoding"
