module Pixi exposing (AnimationSpeed, BasicInformation, Entity(..), Id, Scale, TextString, TextStyle, Texture, Textures, X, Y, animatedSprite, animatedSpriteType, graphicsType, sprite, spriteType, textType)


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
    , scale : Float
    }


type alias TextString =
    String


type Entity
    = Sprite BasicInformation Texture
    | AnimatedSprite BasicInformation Textures AnimationSpeed
    | Graphics BasicInformation
    | Text BasicInformation TextString TextStyle


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


sprite : { id : String, x : Float, y : Float, scale : Maybe Float, texture : String } -> Entity
sprite { id, x, y, scale, texture } =
    let
        basicInformation =
            BasicInformation id x y (Maybe.withDefault 1 scale)
    in
    Sprite basicInformation texture


animatedSprite : { id : String, x : Float, y : Float, scale : Maybe Float, textures : List String, animationSpeed : Maybe Float } -> Entity
animatedSprite { id, x, y, scale, textures, animationSpeed } =
    let
        basicInformation =
            BasicInformation id x y (Maybe.withDefault 1 scale)
    in
    AnimatedSprite basicInformation textures (Maybe.withDefault 0.05 animationSpeed)



-- getById : String -> List Entity -> Entity
-- getById id =
--     List.filter (\e -> e.id == id) >> List.head >> Maybe.withDefault emptyEntity
-- emptyEntity =
--     Entity "incorrectId" 0 0 "NoPixiType" 1
