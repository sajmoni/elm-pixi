module Pixi exposing (AnimationSpeed, BasicInformation, Entity(..), Id, Scale, TextString, TextStyle, Texture, Textures, X, Y, animatedSprite, animatedSpriteType, graphicsType, spriteType, text, textType)


animatedSpriteType =
    "AnimatedSprite"


graphicsType =
    "Graphics"


spriteType =
    "Sprite"


textType =
    "Text"


type alias Id =
    String


type alias X =
    Float


type alias Y =
    Float


type alias Scale =
    Float


type alias Texture =
    String


type alias Textures =
    List String


type alias AnimationSpeed =
    Float


type alias BasicInformation =
    { id : String
    , x : Float
    , y : Float
    , scale : Maybe Float
    }


type alias TextString =
    String


type alias AnimatedSpriteData basicInformation =
    { basicInformation
        | textures : List String
        , animationSpeed : Maybe Float
    }


type alias TextData basicInformation =
    { basicInformation
        | textString : String
        , textStyle : TextStyle
    }


type Entity
    = Sprite BasicInformation Texture
    | AnimatedSprite (AnimatedSpriteData BasicInformation)
    | Graphics BasicInformation
    | Text (TextData BasicInformation)


type alias TextStyle =
    { fontSize : Int
    , fill : String
    }



-- type alias Entity =
--     { id : String
--     , x : Float
--     , y : Float
--     , pixiType : String
--     , scale : Float
--     }
-- type alias Text a =
--     { a
--         | text : String
--         , textStyle : TextStyle
--     }
-- type alias AnimatedSprite a =
--     { a
--         | textures : List String
--         , animationSpeed : Float
--     }
-- type alias Sprite a =
--     { a
--         | texture : String
--     }
-- sprite : { id : String, x : Float, y : Float, scale : Maybe Float, texture : String } -> Entity
-- sprite { id, x, y, scale, texture } =
--     let
--         basicInformation =
--             BasicInformation id x y (Maybe.withDefault 1 scale)
--     in
--     Sprite basicInformation texture


animatedSprite : AnimatedSpriteData BasicInformation -> Entity
animatedSprite { id, x, y, scale, textures, animationSpeed } =
    AnimatedSprite
        { id = id
        , x = x
        , y = y
        , scale = scale
        , textures = textures
        , animationSpeed = animationSpeed
        }


text : TextData BasicInformation -> Entity
text { id, x, y, scale, textString, textStyle } =
    Text
        { id = id
        , x = x
        , y = y
        , scale = scale
        , textString = textString
        , textStyle = textStyle
        }



-- getById : String -> List Entity -> Entity
-- getById id =
--     List.filter (\e -> e.id == id) >> List.head >> Maybe.withDefault emptyEntity
-- emptyEntity =
--     Entity "incorrectId" 0 0 "NoPixiType" 1
