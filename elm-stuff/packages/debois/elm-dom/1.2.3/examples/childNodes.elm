module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Platform.Cmd exposing (none)
import Platform.Sub
import Json.Decode as Decode exposing (Decoder)
import String
import DOM exposing (..)


type alias Model =
  String


model0 : Model
model0 =
  "(Nothing)"


type Msg
  = Measure String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Measure str ->
      ( str, none )


items : Html a
items =
  List.range 0 5
    |> List.map
      (\idx ->
        li
          -- elm-dom will later extract the class names directly from the DOM out of
          -- the elements.
          [ class <| "class-" ++ (toString idx) ]
          [ text <| "Item " ++ toString idx ]
      )
    -- childNodes
    |>
      ul []



--childNode 0 (b)


infixr 5 :>
(:>) : (a -> b) -> a -> b
(:>) f x =
  f x


decode : Decoder String
decode =
  DOM.target
    :> parentElement
    :> childNode 0
    -- (a)
    :>
      childNode 0
    -- (b)
    :>
      childNodes className
    -- Extract the class name from the elements
    |>
      Decode.map (String.join ", ")


view : Model -> Html Msg
view model =
  div
    -- parentElement
    [ class "root" ]
    [ div
      -- childNode 0 (a)
      [ class "container" ]
      [ items ]
      -- See childNode 0 (b) in the above "items" function
    , div
      [ class "value" ]
      [ text <| "Model value: " ++ toString model ]
    , Html.map Measure <|
      button
        -- target
        [ class "button"
        , on "click" decode
        ]
        [ text "Click" ]
    ]


main : Program Never Model Msg
main =
  Html.program
    { init = ( model0, none )
    , update = update
    , subscriptions = always Sub.none
    , view = view
    }
