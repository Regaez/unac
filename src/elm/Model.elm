module Model exposing (..)

import Array exposing (..)
import Color exposing (Color)


type alias Model =
    { turn : PlayerIdentifier
    , board : List ( Int, Maybe Player )
    , conditions : List WinCondition
    , playerOne : Player
    , playerTwo : Player
    }


type alias WinCondition =
    ( Int, Int, Int )


type alias Player =
    { id : PlayerIdentifier
    , name : String
    , color : Color
    }


type PlayerIdentifier
    = PlayerOne
    | PlayerTwo
