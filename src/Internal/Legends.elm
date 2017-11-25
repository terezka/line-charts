module Internal.Legends exposing (..)

import Svg exposing (Svg)
import Svg.Attributes as Attributes
import Lines.Coordinate as Coordinate
import Lines.Junk as Junk
import Internal.Coordinate as Coordinate
import Internal.Dot as Dot
import Internal.Line as Line
import Internal.Utils as Utils



{-| -}
type Legends msg
  = None
  | Free Placement (String -> Svg msg)
  | Bucketed Float (Coordinate.System -> List (Pieces msg) -> Svg msg)


{-| -}
type Placement
  = Beginning
  | Ending


{-| -}
type alias Pieces msg =
  { sample : Svg msg
  , label : String
  }


{-| -}
bucketed : (Coordinate.Limits -> Float) -> (Coordinate.Limits -> Float) -> Legends msg
bucketed toX toY =
  Bucketed 30 <| \system legends ->
    Svg.g
      [ Junk.transform [ Junk.move system (toX system.x) (toY system.y) ] ]
      (List.indexedMap defaultLegend legends)


defaultLegend : Int -> Pieces msg -> Svg msg
defaultLegend index { sample, label } =
   Svg.g
    [ Junk.transform [ Junk.offset 20 (toFloat index * 15) ] ]
    [ sample
    , Svg.g
        [ Junk.transform [ Junk.offset 40 4 ] ]
        [ defaultLabel label ]
    ]


defaultLabel : String -> Svg msg
defaultLabel label =
  Svg.text_ [] [ Svg.tspan [] [ Svg.text label ] ]




-- VIEW


view
  :  Coordinate.System
  -> Line.Look data
  -> Dot.Look data
  -> Legends msg
  -> List (Line.Line data)
  -> List (List (Coordinate.DataPoint data))
  -> Svg.Svg msg
view system lineLook dotLook legends lines dataPoints =
  case legends of
    Free placement view ->
      Svg.g [ Attributes.class "legends" ] <|
        List.map2 (viewLegendFree system placement view) lines dataPoints

    Bucketed sampleWidth toContainer ->
      toContainer system <|
        List.map (toLegendConfig lineLook dotLook system sampleWidth) lines

    None ->
      Svg.text ""


viewLegendFree : Coordinate.System -> Placement -> (String -> Svg msg) -> Line.Line data -> List (Coordinate.DataPoint data) -> Svg.Svg msg
viewLegendFree system placement view (Line.Line line) dataPoints =
  let
    ( orderedPoints, anchor, xOffset ) =
        case placement of
          Beginning ->
            ( dataPoints, "end", -10 )

          Ending ->
            ( List.reverse dataPoints, "start", 10 )
  in
  Utils.viewMaybe (List.head orderedPoints) <| \{ point } ->
    Svg.g
      [ Junk.transform [ Junk.move system point.x point.y, Junk.offset xOffset 3 ]
      , Attributes.style <| "text-anchor: " ++ anchor ++ ";"
      ]
      [ view line.label ]


toLegendConfig : Line.Look data -> Dot.Look data -> Coordinate.System -> Float -> Line.Line data -> Pieces msg
toLegendConfig lineLook dotLook system sampleWidth (Line.Line line) =
  { sample = viewSample system lineLook dotLook sampleWidth line
  , label = line.label
  }


viewSample : Coordinate.System -> Line.Look data -> Dot.Look data -> Float -> Line.LineConfig data -> Svg msg
viewSample system lineLook dotLook sampleWidth line =
  let
    middle =
      Coordinate.toCartesianPoint system <| Coordinate.Point (sampleWidth / 2) 0
  in
  Svg.g
    [ Attributes.class "sample" ]
    [ Line.viewSample lineLook line.color line.dashing sampleWidth
    , Dot.viewNormal dotLook line.shape line.color system middle
    ]
