module Model exposing (..)

import Array exposing (..)
import Color exposing (Color)


type alias Model =
    { turnCount : Int
    , boards : Array Board
    , activePlayer : Player
    , playerOne : PlayerConfig
    , playerTwo : PlayerConfig
    , winner : Maybe Player
    }


type alias Board =
    { state : BoardState
    , grid : Array (Maybe Player)
    }


type BoardState
    = Active
    | Inactive
    | Won Player


type Player
    = PlayerOne
    | PlayerTwo


type alias PlayerConfig =
    { name : String
    , color : Color
    }
