module Internal.Legends exposing
  ( Legends, default, none
  , byEnding, byBeginning
  , bucketed, bucketedCustom
  -- INTERNAL
  , view
  )

{-| -}

import Svg exposing (Svg)
import Svg.Attributes as Attributes
import Lines.Coordinate as Coordinate
import Lines.Junk as Junk
import Lines.Color as Color
import Internal.Coordinate exposing (DataPoint)
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
  | Bucketed Float (Coordinate.System -> List (Legend msg) -> Svg msg)


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
  bucketed .max .max


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
bucketed : (Coordinate.Range -> Float) -> (Coordinate.Range -> Float) -> Legends msg
bucketed toX toY =
  Bucketed 30 (defaultLegends toX toY)


{-| -}
bucketedCustom : Float -> (Coordinate.System -> List (Legend msg) -> Svg.Svg msg) -> Legends msg
bucketedCustom =
  Bucketed



-- VIEW


{-| -}
type alias Arguments data msg =
  { system : Coordinate.System
  , dotLook : Dot.Look data
  , lineLook : Line.Look data
  , areaOpacity : Float
  , lines : List (Line.Line data)
  , dataPoints : List (List (DataPoint data))
  , legends : Legends msg
  }


{-| -}
view : Arguments data msg -> Svg.Svg msg
view arguments =
  case arguments.legends of
    Free placement view ->
      viewFrees arguments placement view

    Bucketed sampleWidth container ->
      viewBucketed arguments sampleWidth container

    None ->
      Svg.text ""



-- VIEW / FREE


viewFrees : Arguments data msg -> Placement -> (String -> Svg msg) -> Svg.Svg msg
viewFrees { system, lines, dataPoints } placement view =
  Svg.g [ Attributes.class "chart__legends" ] <|
    List.map2 (viewFree system placement view) lines dataPoints


viewFree : Coordinate.System -> Placement -> (String -> Svg msg) -> Line.Line data -> List (DataPoint data) -> Svg.Svg msg
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
  Utils.viewMaybe (List.head orderedPoints) viewLegend



-- VIEW / BUCKETED


viewBucketed : Arguments data msg -> Float -> Container msg -> Svg.Svg msg
viewBucketed arguments sampleWidth container =
  let
    toLegend lineConfig =
      { sample = viewSample arguments sampleWidth lineConfig
      , label = lineConfig.label
      }
  in
  container arguments.system <|
    List.map (Line.lineConfig >> toLegend) arguments.lines


viewSample : Arguments data msg -> Float -> Line.Config data -> Svg msg
viewSample { system, lineLook, dotLook, areaOpacity } sampleWidth line =
  let
    dotPosition =
      Coordinate.Point (sampleWidth / 2) 0
        |> Coordinate.toData system
  in
  Svg.g
    [ Attributes.class "chart__sample" ]
    [ Line.viewSample lineLook line.color line.dashing areaOpacity sampleWidth
    , Dot.viewSample dotLook line.shape line.color system dotPosition
    ]



-- DEFAULTS


defaultLegends
  :  (Coordinate.Range -> Float)
  -> (Coordinate.Range -> Float)
  -> Coordinate.System
  -> List (Legend msg)
  -> Svg msg
defaultLegends toX toY system legends =
  Svg.g
    [ Attributes.class "chart__legends"
    , Svg.transform [ Svg.move system (toX system.x) (toY system.y) ]
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
        [ Junk.text Color.inherit label ]
    ]
