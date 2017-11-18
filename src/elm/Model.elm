module Model exposing (..)

import Array exposing (..)
import Color exposing (Color)


type alias Model =
    { boards : Array Board
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


defaults : Model
defaults =
    { boards = Array.fromList <| List.repeat 9 initialBoard
    , activePlayer = PlayerOne
    , playerOne = p1
    , playerTwo = p2
    , winner = Nothing
    }


p1 : PlayerConfig
p1 =
    { name = "Red"
    , color = Color.red
    }


p2 : PlayerConfig
p2 =
    { name = "Blue"
    , color = Color.blue
    }


initialBoard : Board
initialBoard =
    { state = Active
    , grid = Array.fromList <| List.repeat 9 Nothing
    }
