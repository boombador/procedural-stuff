module Main exposing (..)

import AnimationFrame
import Html exposing (Html, div)
import View
import Models exposing (Model, initialModel)
import Msgs exposing (Msg(..))


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
