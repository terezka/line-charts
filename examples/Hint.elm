module HintExample exposing (main)

import Lines as Lines exposing (..)
import Plot.Attributes as Attributes
import Plot.Junk as Junk exposing (..)
import Plot.Color as Color
import Plot.Dot as Dot
import Plot.Axis as Axis
import Plot.Coordinate as Coordinate exposing (..)
import Html exposing (Html, div, h1, node, p, text)
import Svg exposing (Svg, Attribute, text_, tspan, g)


-- MODEL


type alias Model =
    { hovering : Maybe Point }


initialModel : Model
initialModel =
    { hovering = Nothing }



-- UPDATE


type Msg
    = Hover (Maybe Point)


update : Msg -> Model -> Model
update msg model =
    case msg of
        Hover point ->
            { model | hovering = point }




-- VIEW


view : Model -> Svg Msg
view model =
  Lines.viewCustom
    { frame = Frame (Margin 20 20 20 20) (Size 300 300)
    , attributes =
        [ Attributes.onMouseMove (Just >> Hover)
        , Attributes.onMouseLeave (Hover Nothing)
        ]
    , junk =
        Maybe.map junk model.hovering
          |> Maybe.withDefault Junk.none
    , y = Axis.defaultAxis .heartattacks
    , x = Axis.defaultAxis .magnesium
    , interpolation = Monotone
    }
    [ Lines.line Color.gray 1 Dot.none data1
    , Lines.line Color.blue 2 Dot.none data2
    , Lines.line Color.pink 3 pinkDot data3
    ]


pinkDot : Dot.Dot msg
pinkDot =
  Dot.dot <| Dot.Config Dot.Circle [] 5 Color.pink


junk : Point -> Junk.Junk Msg
junk hoverSvgCoordinates =
  Junk.withHint (Junk.findNearest hoverSvgCoordinates) <|
      \system hint ->
          let
            viewHint hint =
              g [ place system hint.x hint.y ]
                [ text_ []
                  [ tspan []
                      [ text <| "( " ++ toString hint.x ++ ", " ++ toString hint.y ++ " )"
                      ]
                  ]
                ]
          in
          { below = []
          , above =
              [ Maybe.map viewHint hint
                  |> Maybe.withDefault (text "")
              ]
          , html = []
          }



-- DATA


type alias Data =
  { magnesium : Float
  , heartattacks : Float
  }


data1 : List Data
data1 =
  [ Data 1 4
  , Data 2 7
  , Data 3 6
  , Data 9 3
  ]


data2 : List Data
data2 =
  [ Data 2 2
  , Data 3 4
  , Data 4 6
  , Data 5 8
  ]


data3 : List Data
data3 =
  [ Data 2 5
  , Data 3 2
  , Data 4 8
  , Data 5 4
  ]


-- Boring stuff


main : Program Never Model Msg
main =
    Html.beginnerProgram { model = initialModel, update = update, view = view }


viewJust : (a -> Svg msg) -> Maybe a -> Svg msg
viewJust view maybe =
    Maybe.map view maybe
        |> Maybe.withDefault (text "")
