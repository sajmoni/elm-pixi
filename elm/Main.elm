module Main exposing (init)

import Browser.Events
import Encode exposing (..)
import Json.Encode exposing (..)
import Juice exposing (..)
import Msg exposing (..)
import Pixi exposing (..)
import Platform
import Port
import Shared exposing (..)
import Time
import Title
import Town


type alias Model =
    { entities : List Entity
    , updates : Int
    , behaviors : List Behavior
    , interactions : List InteractionAlias
    , appState : AppState
    }


init : flags -> ( Model, Cmd msg )
init _ =
    let
        entities =
            Title.entities

        behaviors =
            Title.behaviors

        interactions =
            Title.interactions

        initialModel =
            { updates = 0
            , entities = entities
            , behaviors = behaviors
            , interactions = interactions
            , appState = Title
            }
    in
    ( initialModel, Port.init (encodeEntities initialModel.entities) )


updateEntities : Delta -> Int -> List Entity -> List Behavior -> List Entity
updateEntities delta updates entities behaviors =
    behaviors
        |> List.foldl (runUpdates delta updates) entities


runUpdates : Delta -> Int -> Behavior -> List Entity -> List Entity
runUpdates delta updates behavior entities =
    List.map (updateEntity delta updates behavior) entities


updateEntity : Delta -> Int -> Behavior -> Entity -> Entity
updateEntity delta updates behavior entity =
    case entity of
        AnimatedSprite basicData animatedSpriteData ->
            Pixi.animatedSprite (behavior delta updates basicData) (AnimatedSpriteData animatedSpriteData.textures animatedSpriteData.animationSpeed)

        Text basicData textData ->
            Pixi.text (behavior delta updates basicData) (TextData textData.textString textData.textStyle)

        _ ->
            Debug.todo "Blah!"


interactionOrNoop : String -> String -> InteractionAlias -> Msg
interactionOrNoop idToCheck eventToCheck { id, event, msg } =
    if eventToCheck == event && idToCheck == id then
        msg

    else
        Noop


isNoop : Msg -> Bool
isNoop msg =
    case msg of
        Noop ->
            True

        _ ->
            False


removeEntity : String -> Entity -> Bool
removeEntity id entity =
    let
        basicData =
            getBasicData entity
    in
    if basicData.id == id then
        False

    else
        True



-- Why is this even needed?? Must be a simpler way


callUpdate : (Msg -> Model -> ( Model, Cmd Msg )) -> Msg -> Model -> Model
callUpdate updateFn msg prevModel =
    let
        ( model, _ ) =
            updateFn msg prevModel
    in
    model


setTextColor : Id -> String -> Entity -> Entity
setTextColor id color entity =
    case entity of
        Text basicData textData ->
            let
                textStyle =
                    textData.textStyle
            in
            if id == basicData.id then
                Pixi.text basicData { textData | textStyle = { textStyle | fill = color } }

            else
                entity

        _ ->
            entity


processInteraction : String -> String -> List InteractionAlias -> List Msg
processInteraction id event interactions =
    interactions |> List.map (interactionOrNoop id event) |> List.filter (isNoop >> not)


initScene : AppState -> Model -> Model
initScene appState model =
    case appState of
        Town ->
            { model
                | entities = Town.entities
                , behaviors = Town.behaviors
                , interactions = Town.interactions
            }

        _ ->
            Debug.todo "initScene" appState


update : Msg -> Model -> ( Model, Cmd Msg )
update msg lastModel =
    let
        newModel =
            case msg of
                Interaction { id, event } ->
                    let
                        messages =
                            lastModel.interactions |> processInteraction id event
                    in
                    messages |> List.foldl (callUpdate update) lastModel

                RemoveEntity id ->
                    { lastModel | entities = List.filter (removeEntity id) lastModel.entities }

                AddEntity entity ->
                    { lastModel | entities = entity :: lastModel.entities }

                Noop ->
                    lastModel

                ChangeAppState appState ->
                    { lastModel
                        | appState = appState
                    }
                        |> initScene appState

                SetTextColor id color ->
                    { lastModel
                        | entities = List.map (setTextColor id color) lastModel.entities
                    }

                Tick delta ->
                    { lastModel
                        | updates = lastModel.updates + 1
                        , entities = updateEntities delta lastModel.updates lastModel.entities lastModel.behaviors
                    }
    in
    ( newModel
    , Port.update (encodeEntities newModel.entities)
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ Port.incoming Interaction, Browser.Events.onAnimationFrameDelta Tick ]


main : Program () Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
