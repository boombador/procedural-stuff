module Main exposing (..)

import Browser
import Browser.Events exposing (onAnimationFrame, onAnimationFrameDelta)
import Html exposing (Html, div)
import Models exposing (Model, initialModel)
import Msgs exposing (Msg(..))
import View



-- main : Program Never Model Msg


main =
    Browser.element
        { init = init
        , view = View.view
        , subscriptions = subscriptions
        , update = update
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AnimationFrameDeltaInMS elapsed ->
            ( { model | currentTime = model.currentTime + elapsed }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    onAnimationFrameDelta AnimationFrameDeltaInMS
