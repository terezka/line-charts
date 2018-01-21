module Internal.Legends exposing
  ( Legends, default, none
  , byEnding, byBeginning
  , grouped, groupedCustom
  -- INTERNAL
  , view
  )

{-| -}

import Svg exposing (Svg)
import Svg.Attributes as Attributes
import Lines.Area as Area
import Lines.Color as Color
import Lines.Coordinate as Coordinate
import Lines.Junk as Junk
import Internal.Data as Data
import Internal.Dot as Dot
import Internal.Line as Line
import Internal.Utils as Utils
import Internal.Svg as Svg
import Lines.Junk as Junk



-- CONFIG


{-| -}
type Legends msg
  = None
  | Free Placement (String -> Svg msg)
  | Grouped Float (Coordinate.System -> List (Legend msg) -> Svg msg)


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
default : Legends msg
default =
  grouped .max .max


{-| -}
none : Legends msg
none =
  None


{-| -}
byEnding : (String -> Svg.Svg msg) -> Legends msg
byEnding =
  Free Ending


{-| -}
byBeginning : (String -> Svg.Svg msg) -> Legends msg
byBeginning =
  Free Beginning


{-| -}
grouped : (Coordinate.Range -> Float) -> (Coordinate.Range -> Float) -> Legends msg
grouped toX toY =
  Grouped 30 (defaultLegends toX toY)


{-| -}
groupedCustom : Float -> (Coordinate.System -> List (Legend msg) -> Svg.Svg msg) -> Legends msg
groupedCustom =
  Grouped



-- VIEW


{-| -}
type alias Arguments data msg =
  { system : Coordinate.System
  , dotLook : Dot.Look data
  , lineLook : Line.Look data
  , area : Area.Area
  , lines : List (Line.Line data)
  , dataPoints : List (List (Data.Data data))
  , legends : Legends msg
  }


{-| -}
view : Arguments data msg -> Svg.Svg msg
view arguments =
  case arguments.legends of
    Free placement view ->
      viewFrees arguments placement view

    Grouped sampleWidth container ->
      viewGrouped arguments sampleWidth container

    None ->
      Svg.text ""



-- VIEW / FREE


viewFrees : Arguments data msg -> Placement -> (String -> Svg msg) -> Svg.Svg msg
viewFrees { system, lines, dataPoints } placement view =
  Svg.g [ Attributes.class "chart__legends" ] <|
    List.map2 (viewFree system placement view) lines dataPoints


viewFree : Coordinate.System -> Placement -> (String -> Svg msg) -> Line.Line data -> List (Data.Data data) -> Svg.Svg msg
viewFree system placement viewLabel line dataPoints =
  let
    lineConfig =
      Line.lineConfig line

    ( orderedPoints, anchor, xOffset ) =
      case placement of
        Beginning -> ( dataPoints, Svg.End, -10 )
        Ending    -> ( List.reverse dataPoints, Svg.Start, 10 )

    transform { x, y } =
      Svg.transform [ Svg.move system x y, Svg.offset xOffset 3 ]

    viewLegend { point } =
      Svg.g
        [ transform point, Svg.anchorStyle anchor ]
        [ viewLabel lineConfig.label ]
  in
  Utils.viewMaybe (List.head <| List.filter .isReal orderedPoints) viewLegend



-- VIEW / BUCKETED


viewGrouped : Arguments data msg -> Float -> Container msg -> Svg.Svg msg
viewGrouped arguments sampleWidth container =
  let
    toLegend line data =
      let lineConfig = Line.lineConfig line in
      { sample = viewSample arguments sampleWidth lineConfig data
      , label = lineConfig.label
      }
  in
  container arguments.system <|
    List.map2 toLegend arguments.lines arguments.dataPoints


viewSample : Arguments data msg -> Float -> Line.Config data -> List (Data.Data data) -> Svg msg
viewSample { system, lineLook, dotLook, area, dataPoints } sampleWidth lineConfig data =
  let
    dotPosition =
      Coordinate.Point (sampleWidth / 2) 0
        |> Coordinate.toData system

    color =
      Line.getColor lineLook data lineConfig.color
  in
  Svg.g
    [ Attributes.class "chart__sample" ]
    [ Line.viewSample lineLook lineConfig area data sampleWidth
    , Dot.viewSample dotLook lineConfig.shape color system data dotPosition
    ]



-- DEFAULTS


defaultLegends
  :  (Coordinate.Range -> Float)
  -> (Coordinate.Range -> Float)
  -> Coordinate.System
  -> List (Legend msg)
  -> Svg msg
defaultLegends toX toY system legends =
  let
    view =
      List.filter (not << String.isEmpty << .label)
        >> List.indexedMap defaultLegend
  in
  Svg.g
    [ Attributes.class "chart__legends"
    , Svg.transform
        [ Svg.move system (toX system.x) (toY system.y)
        , Svg.offset 0 10
        ]
    ]
    (view legends)


defaultLegend : Int -> Legend msg -> Svg msg
defaultLegend index { sample, label } =
   Svg.g
    [ Attributes.class "chart__legend"
    , Svg.transform [ Svg.offset 20 (toFloat index * 20) ]
    ]
    [ sample
    , Svg.g
        [ Svg.transform [ Svg.offset 40 4 ] ]
        [ Junk.text Color.inherit label ]
    ]
