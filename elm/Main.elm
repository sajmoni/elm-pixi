module Main exposing (init)

import Browser
import Browser.Dom exposing (getViewport)
import Browser.Events
import Color
import Game.TwoD as Game
import Game.TwoD.Camera as Camera exposing (Camera)
import Game.TwoD.Render as Render exposing (Renderable)
import Html exposing (Html, div)
import Html.Attributes as Attr
import Keyboard
import Keyboard.Arrows
import Task
import Time



-- MODEL


type alias Entity =
    { id : String, x : Float, y : Float }


type alias Model =
    { entities : List Entity
    , keys : List Keyboard.Key
    , time : Float
    , screen : ( Int, Int )
    , camera : Camera
    }


type alias Delta =
    Float



-- MSG


type Msg
    = ScreenSize Int Int
    | Tick Delta
    | Keys Keyboard.Msg



-- APP


init : () -> ( Model, Cmd Msg )
init _ =
    let
        initialModel =
            { entities =
                [ Entity "square1" 50 50
                , Entity "square2" 150 150
                , Entity "square3" 250 250
                , Entity "square4" 0 0
                ]
            , keys = []
            , time = 0
            , screen = ( 1000, 1000 )
            , camera = Camera.fixedWidth 1000 ( 0, 0 )
            }
    in
    ( initialModel, Task.perform (\{ viewport } -> ScreenSize (round viewport.width) (round viewport.height)) getViewport )


updateEntity : Delta -> List Keyboard.Key -> Entity -> Entity
updateEntity delta keys entity =
    let
        arrows =
            Keyboard.Arrows.arrows keys
    in
    if arrows.x > 0 then
        resetEntity entity

    else
        { entity | x = entity.x + delta / 100 }


resetEntity : Entity -> Entity
resetEntity entity =
    { entity | x = 50 }


update : Msg -> Model -> ( Model, Cmd msg )
update msg lastModel =
    let
        _ =
            Debug.log "lastModel" lastModel
    in
    case msg of
        ScreenSize width height ->
            ( { lastModel | screen = ( width, height ) }
            , Cmd.none
            )

        Tick delta ->
            ( { lastModel
                | entities = List.map (updateEntity delta lastModel.keys) lastModel.entities
                , time = lastModel.time + delta
              }
            , Cmd.none
            )

        Keys keyMsg ->
            let
                keys =
                    Keyboard.update keyMsg lastModel.keys
            in
            ( { lastModel | keys = keys }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ Browser.Events.onAnimationFrameDelta Tick ]



--


render : List Entity -> List Renderable
render entities =
    List.map (\e -> Render.shape Render.rectangle { size = ( 200, 200 ), color = Color.white, position = ( e.x, e.y ) }) entities


view : Model -> Html msg
view ({ time, screen } as model) =
    div [ Attr.style "width" "100%", Attr.style "height" "1000px" ]
        [ Game.render
            { camera = model.camera
            , time = time
            , size = screen
            }
            (render model.entities)
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
