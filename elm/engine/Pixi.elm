module Pixi exposing (Attribute(..), Entity(..), Height, Shape(..), TextStyle(..), Width, alpha, animatedSprite, animationSpeed, color, container, fill, fontSize, graphics, id, on, scale, shape, sprite, text, textString, textStyle, texture, textures, x, y)

-- Pixi.Attribute
-- Pixi.TextStyle


type alias Width =
    Float


type alias Height =
    Float


type Shape
    = Rectangle Width Height
    | Circle


type Entity msg
    = Sprite (List (Attribute msg)) (List (Entity msg))
    | AnimatedSprite (List (Attribute msg)) (List (Entity msg))
    | Text (List (Attribute msg)) (List (Entity msg))
    | Graphics (List (Attribute msg)) (List (Entity msg))
    | Container (List (Attribute msg)) (List (Entity msg))
    | NotImplemented


type Attribute msg
    = Id String
    | Scale Float
    | X Float
    | Y Float
    | Alpha Float
    | TextString String
    | Texture String
    | Anchor Float
    | Color String
    | Shape Shape
    | On String msg
    | Textures (List String)
    | AnimationSpeed Float
    | TextStyle (List TextStyle)


id : String -> Attribute msg
id string =
    Id string


textString : String -> Attribute msg
textString string =
    TextString string


textStyle : List TextStyle -> Attribute msg
textStyle textStyles =
    TextStyle textStyles


alpha : Float -> Attribute msg
alpha a =
    Alpha a


on : String -> msg -> Attribute msg
on o msg =
    On o msg


texture : String -> Attribute msg
texture string =
    Texture string


textures : List String -> Attribute msg
textures t =
    Textures t


animationSpeed : Float -> Attribute msg
animationSpeed speed =
    AnimationSpeed speed


color : String -> Attribute msg
color string =
    Color string


shape : Shape -> Attribute msg
shape s =
    Shape s



-- TextStyle


type TextStyle
    = Fill String
    | FontSize Float


fill : String -> TextStyle
fill string =
    Fill string


fontSize : Float -> TextStyle
fontSize size =
    FontSize size



-- TextStyle end


scale : Float -> Attribute msg
scale float =
    Scale float


x : Float -> Attribute msg
x float =
    X float


y : Float -> Attribute msg
y float =
    Y float


text : List (Attribute msg) -> List (Entity msg) -> Entity msg
text attributes children =
    Text attributes children


sprite : List (Attribute msg) -> List (Entity msg) -> Entity msg
sprite attributes children =
    Sprite attributes children


animatedSprite : List (Attribute msg) -> List (Entity msg) -> Entity msg
animatedSprite attributes children =
    AnimatedSprite attributes children


graphics : List (Attribute msg) -> List (Entity msg) -> Entity msg
graphics attributes children =
    Graphics attributes children


container : List (Attribute msg) -> List (Entity msg) -> Entity msg
container attributes children =
    Container attributes children
