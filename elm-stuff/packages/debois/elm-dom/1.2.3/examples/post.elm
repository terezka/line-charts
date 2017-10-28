module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Platform.Cmd exposing (none)
import Platform.Sub
import String
import Json.Decode exposing (Decoder)
import DOM exposing (..)


type alias Model =
  List Float


model : Model
model =
  []


type Msg
  = Measure (List Float)


init : ( Model, Cmd Msg )
init =
  ( [], none )


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    Measure measures ->
      ( measures, none )



-- VIEW


infixr 5 :>
(:>) : (a -> b) -> a -> b
(:>) f x =
  f x


decode : Decoder (List Float)
decode =
  DOM.target
    -- (a)
    :>
      parentElement
    -- (b)
    :>
      childNode 0
    -- (c)
    :>
      childNode 0
    -- (d)
    :>
      childNodes
        -- (e)
        DOM.offsetWidth



-- read the width of each element


css : Attribute a
css =
  style [ ( "padding", "1em" ) ]


view : Model -> Html Msg
view model =
  div
    -- parentElement (b)
    []
    [ div
      -- childNode 0 (c)
      [ css ]
      [ div
        -- childNode 0 (d)
        []
        [ span [ css ] [ text "short" ]
        , span [ css ] [ text "somewhat long" ]
        , span [ css ] [ text "longer than the others" ]
        ]
        -- childNodes (e)
      ]
    , Html.map Measure <|
      button
        -- target (a)
        [ css
        , on "click" decode
        ]
        [ text "Measure!" ]
    , div
      [ css ]
      [ model
        |> List.map toString
        |> String.join ", "
        |> text
      , text "!"
      ]
    ]



-- STARTAPP


main : Program Never Model Msg
main =
  Html.program
    { init = ( model, none )
    , view = view
    , subscriptions = always Sub.none
    , update = update
    }
