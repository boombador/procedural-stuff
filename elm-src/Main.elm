module Main exposing (..)

import AnimationFrame
import Html exposing (Html, div)
import Math.Vector3 as Vec3 exposing (vec3, Vec3)
import Time exposing (Time)
import View
import Models exposing (Model, initialModel)


type Msg
    = TimeUpdate Time


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, Cmd.none )
        , view = View.view
        , subscriptions = subscriptions
        , update = update
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TimeUpdate elapsed ->
            ( { model | currentTime = model.currentTime + elapsed }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    AnimationFrame.diffs TimeUpdate
