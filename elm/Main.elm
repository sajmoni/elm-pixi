module Main exposing (init)

-- import Behavior exposing (Behavior)

import Browser.Events
import Encode exposing (..)
import Json.Encode exposing (..)
import Juice
import Pixi exposing (Entity(..))
import Platform
import Port
import Shared exposing (Delta)
import Time


type alias Behavior =
    Delta -> Int -> Entity -> Entity


type alias Model =
    { entities : List Entity
    , updates : Int
    , behaviors : List Behavior
    }


type Msg
    = UpdateSquare String
    | Tick Delta


initialSceneEntities : List Entity
initialSceneEntities =
    [ Pixi.animatedSprite { id = "test1", x = 45, y = 45, scale = Just 3, textures = [ "monster_01", "monster_02" ], animationSpeed = Just 0.01 }
    , Pixi.text { id = "text1", x = 145, y = 145, scale = Just 3, textString = "ElmQuest", textStyle = { fill = "white", fontSize = 42 } }
    ]


init : flags -> ( Model, Cmd msg )
init _ =
    let
        entities =
            initialSceneEntities

        behaviors =
            [ moveRight
            , updateScale
            ]

        initialModel =
            { updates = 0
            , entities = entities
            , behaviors = behaviors
            }
    in
    ( initialModel, Port.init (encodeEntities initialModel.entities) )



-- findEntityById : String -> List Entities -> Entity
-- findEntityById id entities =
--     entities |> List.filter (\e -> )
-- moveRight : (Int -> Float) -> Int -> Delta -> Entity -> Entity
-- moveRight getX updates delta entity =
--     case entity of
--         AnimatedSprite bi textures animationSpeed ->
--             AnimatedSprite { bi | x = bi.x + 1 } textures animationSpeed
--         _ ->
--             Debug.todo "Handle this"
-- { entity | x = entity.x + getX updates * delta / 15 }
-- resetEntity : Entity -> Entity
-- resetEntity entity =
--     { entity | x = 50 }
-- isGraphicsEntity : Entity -> Bool
-- isGraphicsEntity entity =
--     entity.pixiType == Pixi.graphicsType
-- run : Int -> Float -> List Entity -> Behavior -> Entity
-- run updates delta entities behavior =
--     behavior.onUpdate behavior.transformation updates delta (getById behavior.entityId entities)
-- updateEntities : List Entity -> List Behavior -> List Entity
-- updateEntities entities behaviors =
--     behaviors |> List.map (run lastModel.updates delta lastModel.entities)
-- updateEntity entityToUse entityToCheck =
--     case entityToUse of
--         AnimatedSprite bi _ _ ->
-- runner : Behavior -> List Entity -> List Entity
-- runner { onUpdate, transformation, entity, id } entities =
--     let
--         _ =
--             Debug.log "behavior" behavior
--     in
--     List.map (onUpdate transformation) entities
--         { id : String
--     , entity : Entity
--     , transformation : Int -> Float
--     , onUpdate : (Int -> Float) -> Int -> Delta -> Entity -> Entity
--     }


updateEntities : Delta -> Int -> List Entity -> List Behavior -> List Entity
updateEntities delta updates entities behaviors =
    behaviors
        |> List.foldl (runUpdates delta updates) entities


runUpdates : Delta -> Int -> Behavior -> List Entity -> List Entity
runUpdates delta updates updater entities =
    List.map (updater delta updates) entities


moveRight : Behavior
moveRight delta updates entity =
    case entity of
        AnimatedSprite data ->
            Pixi.animatedSprite { data | x = data.x + 10 / delta }

        Text data ->
            entity

        _ ->
            Debug.todo "Blah!"



-- updateScale : (Int -> Float) -> Int -> Delta -> Entity -> Entity
-- updateScale getScale updates _ entity =
--     { entity | scale = getScale updates }


getScale =
    Juice.sine { start = 1, end = 1.2, duration = 120 }


updateScale : Behavior
updateScale delta updates entity =
    case entity of
        AnimatedSprite data ->
            entity

        Text data ->
            Pixi.text { data | scale = Just (getScale updates) }

        _ ->
            Debug.todo "Blah!"


update : Msg -> Model -> ( Model, Cmd msg )
update msg lastModel =
    let
        newModel =
            case msg of
                -- UpdateSquare idToUpdate ->
                --     { lastModel
                --         | entities =
                --             lastModel.entities
                --                 |> List.map
                --                     (\entity ->
                --                         if isGraphicsEntity entity && entity.id == idToUpdate then
                --                             resetEntity entity
                --                         else
                --                             entity
                --                     )
                --     }
                Tick delta ->
                    { lastModel
                        | updates = lastModel.updates + 1
                        , entities = updateEntities delta lastModel.updates lastModel.entities lastModel.behaviors
                    }

                _ ->
                    lastModel

        -- { lastModel
        --     | entities = lastModel.behaviors |> List.map (run lastModel.updates delta lastModel.entities)
        --     , updates = lastModel.updates + 1
        -- }
    in
    ( newModel, Port.update (encodeEntities newModel.entities) )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ Port.incoming UpdateSquare, Browser.Events.onAnimationFrameDelta Tick ]


main : Program () Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
