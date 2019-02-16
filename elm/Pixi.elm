module Pixi exposing (AnimatedSpriteData, BasicData, Entity(..), Id, TextData, TextString, TextStyle, animatedSprite, getBasicData, text)


type alias Id =
    String


type alias BasicData =
    { id : Id
    , x : Float
    , y : Float
    , scale : Maybe Float
    }


type alias TextString =
    String


type alias AnimatedSpriteData =
    { textures : List String
    , animationSpeed : Maybe Float
    }


type alias TextData =
    { textString : String
    , textStyle : TextStyle
    }


type Entity
    = Sprite BasicData
    | AnimatedSprite BasicData AnimatedSpriteData
    | Graphics BasicData
    | Text BasicData TextData


type alias TextStyle =
    { fontSize : Int
    , fill : String
    }


animatedSprite : BasicData -> AnimatedSpriteData -> Entity
animatedSprite { id, x, y, scale } { textures, animationSpeed } =
    AnimatedSprite
        { id = id
        , x = x
        , y = y
        , scale = scale
        }
        { textures = textures
        , animationSpeed = animationSpeed
        }


text : BasicData -> TextData -> Entity
text { id, x, y, scale } { textString, textStyle } =
    Text
        { id = id
        , x = x
        , y = y
        , scale = scale
        }
        { textString = textString
        , textStyle = textStyle
        }


getBasicData : Entity -> BasicData
getBasicData entity =
    case entity of
        AnimatedSprite basicData _ ->
            basicData

        Text basicData _ ->
            basicData

        _ ->
            Debug.todo "Handle more cases in getBasicData"



-- getEntity: Id -> Entity
-- getEntity id =
