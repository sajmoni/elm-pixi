module Pixi exposing (AnimatedSpriteData, BasicData, Entity(..), GraphicsData, Height, Id, Shape(..), SpriteData, TextData, TextString, TextStyle, Width, animatedSprite, getBasicData, graphics, sprite, text)


type alias Id =
    String


type Shape
    = Rectangle Width Height


type alias BasicData =
    { id : Id
    , x : Float
    , y : Float
    , scale : Maybe Float
    , alpha : Maybe Float
    }


type alias Width =
    Int


type alias Height =
    Int


type alias GraphicsData =
    { color : String
    , shape : Shape
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
    | Graphics BasicData GraphicsData
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


graphics : BasicData -> GraphicsData -> Entity
graphics { id, x, y, scale, alpha } { color, shape } =
    Graphics
        { id = id
        , x = x
        , y = y
        , scale = scale
        , alpha = alpha
        }
        { color = color
        , shape = shape
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

        Graphics basicData _ ->
            basicData

        _ ->
            Debug.todo "Handle more cases in getBasicData"



-- getEntity: Id -> Entity
-- getEntity id =
