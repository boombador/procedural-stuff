port module Main exposing (..)

import Html exposing (..)
import Debug exposing (log)
import Task


--import Html.Events exposing (..)
--import String
--import Json.Encode


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = (always Sub.none) -- ??
        }



-- MODEL


type alias Mesh =
    { vertices : List Float
    , faces : List Int
    }


type alias Model =
    { meshRequest : String
    , mesh : Maybe Mesh
    }


init : ( Model, Cmd Msg )
init =
    ( Model "" Nothing, Cmd.none )



-- UPDATE


type Msg
    = EmitMesh
    | RequestMesh String
    | MeshGenerated Mesh


port emitMesh : String -> Cmd msg


meshToString : Maybe Mesh -> String
meshToString maybeMesh =
    case maybeMesh of
        Nothing ->
            ""

        Just { vertices, faces } ->
            let
                toCsv values =
                    values
                        |> List.map toString
                        |> String.join ","
            in
                String.concat [ "{\"vertices\": [", toCsv vertices, "], \"faces\": [", toCsv faces, "]}" ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EmitMesh ->
            ( model, emitMesh (meshToString model.mesh) )

        RequestMesh meshType ->
            let
                _ =
                    Debug.log "meshType" meshType
                cmds =
                    Task.perform MeshGenerated (generateMesh meshType)
            in
                ( { model | meshRequest = meshType }, cmds )

        MeshGenerated mesh ->
            ( { model | mesh = Just mesh }, Cmd.none )


generateMesh : String -> Task.Task x Mesh
generateMesh meshType =
    Task.succeed
        { vertices = []
        , faces = []
        }



-- SUBSCRIPTIONS


port meshRequests : (String -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    meshRequests RequestMesh



-- VIEW


view : Model -> Html Msg
view model =
    div [] [ text "hello" ]
