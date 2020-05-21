module Internal.Legends exposing
  ( Config, default, none
  , byEnding, byBeginning
  , grouped, groupedCustom
  , hover, hoverOne
  -- INTERNAL
  , view
  )

{-| -}

import Svg exposing (Svg)
import Svg.Attributes as Attributes
import LineChart.Area as Area
import LineChart.Coordinate as Coordinate
import Internal.Data as Data
import Internal.Dots as Dot
import Internal.Line as Line
import Internal.Utils as Utils
import Internal.Svg as Svg



-- CONFIG


{-| -}
type Config data msg
  = None
  | Free Placement (String -> Svg msg)
  | Grouped Float (Arguments data msg -> Container msg)


{-| -}
type Placement
  = Beginning
  | Ending


{-| -}
type alias Container msg =
  Coordinate.System -> List (Legend msg) -> Svg msg


{-| -}
type alias Legend msg =
  { sample : Svg msg
  , label : String
  }


{-| -}
default : Config data msg
default =
  hover []


{-| -}
hover : List data -> Config data msg
hover data =
  Grouped 30 (defaultLegends .max .max 0 10 data)


{-| -}
hoverOne : Maybe data -> Config data msg
hoverOne maybeOne =
  case maybeOne of
    Just data -> hover [ data ]
    Nothing   -> hover []


{-| -}
none : Config data msg
none =
  None


{-| -}
byEnding : (String -> Svg.Svg msg) -> Config data msg
byEnding =
  Free Ending


{-| -}
byBeginning : (String -> Svg.Svg msg) -> Config data msg
byBeginning =
  Free Beginning


{-| -}
grouped : (Coordinate.Range -> Float) -> (Coordinate.Range -> Float) -> Float -> Float -> Config data msg
grouped toX toY offsetX offsetY =
  Grouped 30 (defaultLegends toX toY offsetX offsetY [])


{-| -}
groupedCustom : Float -> (Coordinate.System -> List (Legend msg) -> Svg.Svg msg) -> Config data msg
groupedCustom sampleWidth container =
  Grouped sampleWidth (\_ -> container)



-- VIEW


{-| -}
type alias Arguments data msg =
  { system : Coordinate.System
  , dotsConfig : Dot.Config data
  , lineConfig : Line.Config data
  , area : Area.Config
  , lines : List (Line.Series data)
  , data : List (List (Data.Data data))
  , x : data -> Maybe Float
  , y : data -> Maybe Float
  , legends : Config data msg
  }


{-| -}
view : Arguments data msg -> Svg.Svg msg
view arguments =
  case arguments.legends of
    Free placement view_ ->
      viewFrees arguments placement view_

    Grouped sampleWidth container ->
      viewGrouped arguments sampleWidth (container arguments)

    None ->
      Svg.text ""



-- VIEW / FREE


viewFrees : Arguments data msg -> Placement -> (String -> Svg msg) -> Svg.Svg msg
viewFrees { system, lines, data } placement view_ =
  Svg.g [ Attributes.class "chart__legends" ] <|
    List.map2 (viewFree system placement view_) lines data


viewFree : Coordinate.System -> Placement -> (String -> Svg msg) -> Line.Series data -> List (Data.Data data) -> Svg.Svg msg
viewFree system placement viewLabel line data =
  let
    ( orderedPoints, anchor, xOffset ) =
      case placement of
        Beginning ->
          ( data, Svg.End, -10 )

        Ending ->
          ( List.reverse data, Svg.Start, 10 )

    transform { x, y } =
      Svg.transform
        [ Svg.move system x y
        , Svg.offset xOffset 3
        ]

    viewLegend { point } =
      Svg.g
        [ transform point, Svg.anchorStyle anchor ]
        [ viewLabel (Line.label line) ]
  in
  Utils.viewMaybe (List.head orderedPoints) viewLegend



-- VIEW / BUCKETED


viewGrouped : Arguments data msg -> Float -> Container msg -> Svg.Svg msg
viewGrouped arguments sampleWidth container =
  let
    toLegend line data =
      { sample = viewSample arguments sampleWidth line data
      , label = Line.label line
      }

    legends =
      List.map2 toLegend arguments.lines arguments.data
  in
  container arguments.system legends



viewSample : Arguments data msg -> Float -> Line.Series data -> List (Data.Data data) -> Svg msg
viewSample { system, lineConfig, dotsConfig, area } sampleWidth line data =
  let
    dotPosition =
      Data.Point (sampleWidth / 2) 0
        |> Coordinate.toData system

    color =
      Line.color lineConfig line data

    shape =
      Line.shape line
  in
  Svg.g
    [ Attributes.class "chart__sample" ]
    [ Line.viewSample lineConfig line area data sampleWidth
    , Dot.viewSample dotsConfig shape color system data dotPosition
    ]



-- DEFAULTS


defaultLegends
  :  (Coordinate.Range -> Float)
  -> (Coordinate.Range -> Float)
  -> Float
  -> Float
  -> List data
  -> Arguments data msg
  -> Coordinate.System
  -> List (Legend msg)
  -> Svg msg
defaultLegends toX toY offsetX offsetY hovered arguments system legends =
  Svg.g
    [ Attributes.class "chart__legends"
    , Svg.transform
        [ Svg.move system (toX system.x) (toY system.y)
        , Svg.offset offsetX offsetY
        ]
    ]
    (List.indexedMap defaultLegend legends)


defaultLegend : Int -> Legend msg -> Svg msg
defaultLegend index { sample, label } =
   Svg.g
    [ Attributes.class "chart__legend"
    , Svg.transform [ Svg.offset 20 (toFloat index * 20) ]
    ]
    [ sample
    , Svg.g
        [ Svg.transform [ Svg.offset 40 4 ] ]
        [ Svg.label "inherit" label ]
    ]
