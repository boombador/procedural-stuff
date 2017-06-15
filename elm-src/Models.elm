module Models exposing (..)


type alias Model =
    { currentTime : Float
    }


initialModel : Model
initialModel =
    { currentTime = 0
    }
