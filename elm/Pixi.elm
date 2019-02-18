module Pixi exposing (AnimatedSpriteData, BasicData, Entity(..), Id, SpriteData, TextData, TextString, TextStyle, animatedSprite, getBasicData, graphics, sprite, text)


type alias Id =
    String


type alias BasicData =
    { id : Id
    , x : Float
    , y : Float
    , scale : Maybe Float
    , alpha : Maybe Float
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


type alias SpriteData =
    { texture : String
    }


type Entity
    = Sprite BasicData SpriteData
    | AnimatedSprite BasicData AnimatedSpriteData
    | Graphics BasicData
    | Text BasicData TextData
    | NotImplemented


type alias TextStyle =
    { fontSize : Int
    , fill : String
    }


animatedSprite : BasicData -> AnimatedSpriteData -> Entity
animatedSprite { id, x, y, scale, alpha } { textures, animationSpeed } =
    AnimatedSprite
        { id = id
        , x = x
        , y = y
        , scale = scale
        , alpha = alpha
        }
        { textures = textures
        , animationSpeed = animationSpeed
        }


text : BasicData -> TextData -> Entity
text { id, x, y, scale, alpha } { textString, textStyle } =
    Text
        { id = id
        , x = x
        , y = y
        , scale = scale
        , alpha = alpha
        }
        { textString = textString
        , textStyle = textStyle
        }


sprite : BasicData -> SpriteData -> Entity
sprite { id, x, y, scale, alpha } { texture } =
    Sprite
        { id = id
        , x = x
        , y = y
        , scale = scale
        , alpha = alpha
        }
        { texture = texture
        }


graphics : BasicData -> Entity
graphics { id, x, y, scale, alpha } =
    Graphics
        { id = id
        , x = x
        , y = y
        , scale = scale
        , alpha = alpha
        }


getBasicData : Entity -> BasicData
getBasicData entity =
    case entity of
        AnimatedSprite basicData _ ->
            basicData

        Text basicData _ ->
            basicData

        Sprite basicData _ ->
            basicData

        Graphics basicData ->
            basicData

        _ ->
            Debug.todo "Handle more cases in getBasicData"



-- getEntity: Id -> Entity
-- getEntity id =
