module Internal.Legends exposing (..)

{-| -}

import Svg exposing (Svg)
import Svg.Attributes as Attributes
import Lines.Coordinate as Coordinate
import Internal.Coordinate as Coordinate
import Internal.Dot as Dot
import Internal.Line as Line
import Internal.Utils as Utils
import Internal.Svg as Svg



-- CONFIG


{-| -}
type Legends msg
  = None
  | Free Placement (String -> Svg msg)
  | Bucketed SampleWidth (Coordinate.System -> List (Pieces msg) -> Svg msg)


{-| -}
type Placement
  = Beginning
  | Ending


{-| -}
type alias Container msg =
  Coordinate.System -> List (Pieces msg) -> Svg msg


{-| -}
type alias SampleWidth =
  Float


{-| -}
type alias Pieces msg =
  { sample : Svg msg
  , label : String
  }


{-| -}
default : Legends msg
default =
  bucketed .max .max


{-| -}
bucketed : (Coordinate.Limits -> Float) -> (Coordinate.Limits -> Float) -> Legends msg
bucketed toX toY =
  Bucketed 30 <| \system legends ->
    Svg.g
      [ Svg.transform [ Svg.move system (toX system.x) (toY system.y) ] ]
      (List.indexedMap defaultLegend legends)



-- VIEW


view
  :  Coordinate.System
  -> Line.Look data
  -> Dot.Look data
  -> Legends msg
  -> Float
  -> List (Line.Line data)
  -> List (List (Coordinate.DataPoint data))
  -> Svg.Svg msg
view system lineLook dotLook legends areaOpacity lines dataPoints =
  case legends of
    Free placement view ->
      viewFrees system placement view lines dataPoints

    Bucketed sampleWidth container ->
      viewBucketed system lineLook dotLook sampleWidth areaOpacity container lines

    None ->
      Svg.text ""



-- VIEW / FREE


viewFrees
  :  Coordinate.System
  -> Placement
  -> (String -> Svg msg)
  -> List (Line.Line data)
  -> List (List (Coordinate.DataPoint data))
  -> Svg.Svg msg
viewFrees system placement view lines dataPoints =
  Svg.g [ Attributes.class "legends" ] <|
    List.map2 (viewFree system placement view) lines dataPoints


viewFree : Coordinate.System -> Placement -> (String -> Svg msg) -> Line.Line data -> List (Coordinate.DataPoint data) -> Svg.Svg msg
viewFree system placement viewLabel (Line.Line line) dataPoints =
  let
    ( orderedPoints, anchor, xOffset ) =
        case placement of
          Beginning -> ( dataPoints, Svg.End, -10 )
          Ending    -> ( List.reverse dataPoints, Svg.Start, 10 )

    transformation { x, y } =
      Svg.transform [ Svg.move system x y, Svg.offset xOffset 3 ]
  in
  Utils.viewMaybe (List.head orderedPoints) <| \{ point } ->
    Svg.g [ transformation point, Svg.anchorStyle anchor ] [ viewLabel line.label ]



-- VIEW / BUCKETED


viewBucketed
  : Coordinate.System
  -> Line.Look data
  -> Dot.Look data
  -> SampleWidth
  -> Float
  -> Container msg
  -> List (Line.Line data)
  -> Svg.Svg msg
viewBucketed system lineLook dotLook sampleWidth areaOpacity container lines =
  let
    toConfig (Line.Line line) =
      { sample = viewSample system lineLook dotLook sampleWidth areaOpacity line
      , label = line.label
      }
  in
  container system <| List.map toConfig lines


viewSample : Coordinate.System -> Line.Look data -> Dot.Look data -> Float -> Float -> Line.LineConfig data -> Svg msg
viewSample system lineLook dotLook sampleWidth areaOpacity line =
  let
    middle =
      Coordinate.toCartesianPoint system <| Coordinate.Point (sampleWidth / 2) 0
  in
  Svg.g
    [ Attributes.class "sample" ]
    [ Line.viewSample lineLook line.color line.dashing areaOpacity sampleWidth
    , Dot.viewSample dotLook line.shape line.color system middle
    ]



-- DEFAULTS


defaultLegend : Int -> Pieces msg -> Svg msg
defaultLegend index { sample, label } =
   Svg.g
    [ Svg.transform [ Svg.offset 20 (toFloat index * 20) ] ]
    [ sample
    , Svg.g
        [ Svg.transform [ Svg.offset 40 4 ] ]
        [ defaultLabel label ]
    ]


defaultLabel : String -> Svg msg
defaultLabel label =
  Svg.text_ [] [ Svg.tspan [] [ Svg.text label ] ]
