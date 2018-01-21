module Internal.Legends exposing
  ( Legends, default, none
  , byEnding, byBeginning
  , grouped, groupedCustom
  , hover
  -- INTERNAL
  , view
  )

{-| -}

import Svg exposing (Svg)
import Svg.Attributes as Attributes
import Lines.Area as Area
import Lines.Coordinate as Coordinate
import Internal.Data as Data
import Internal.Dot as Dot
import Internal.Line as Line
import Internal.Utils as Utils
import Internal.Svg as Svg



-- CONFIG


{-| -}
type Legends data msg
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
default : Legends data msg
default =
  Grouped 30 (defaultLegends .max .max [])


{-| -}
hover : List data -> Legends data msg
hover data =
  Grouped 30 (defaultLegends .max .max data)


{-| -}
none : Legends data msg
none =
  None


{-| -}
byEnding : (String -> Svg.Svg msg) -> Legends data msg
byEnding =
  Free Ending


{-| -}
byBeginning : (String -> Svg.Svg msg) -> Legends data msg
byBeginning =
  Free Beginning


{-| -}
grouped : (Coordinate.Range -> Float) -> (Coordinate.Range -> Float) -> Legends data msg
grouped toX toY =
  Grouped 30 (defaultLegends toX toY [])


{-| -}
groupedCustom : Float -> (Coordinate.System -> List (Legend msg) -> Svg.Svg msg) -> Legends data msg
groupedCustom sampleWidth container =
  Grouped sampleWidth (\_ -> container)



-- VIEW


{-| -}
type alias Arguments data msg =
  { system : Coordinate.System
  , dotLook : Dot.Look data
  , lineLook : Line.Look data
  , area : Area.Area
  , lines : List (Line.Line data)
  , data : List (List (Data.Data data))
  , legends : Legends data msg
  , x : data -> Maybe Float
  , y : data -> Maybe Float
  }


{-| -}
view : Arguments data msg -> Svg.Svg msg
view arguments =
  case arguments.legends of
    Free placement view ->
      viewFrees arguments placement view

    Grouped sampleWidth container ->
      viewGrouped arguments sampleWidth (container arguments)

    None ->
      Svg.text ""



-- VIEW / FREE


viewFrees : Arguments data msg -> Placement -> (String -> Svg msg) -> Svg.Svg msg
viewFrees { system, lines, data } placement view =
  Svg.g [ Attributes.class "chart__legends" ] <|
    List.map2 (viewFree system placement view) lines data


viewFree : Coordinate.System -> Placement -> (String -> Svg msg) -> Line.Line data -> List (Data.Data data) -> Svg.Svg msg
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



viewSample : Arguments data msg -> Float -> Line.Line data -> List (Data.Data data) -> Svg msg
viewSample { system, lineLook, dotLook, area } sampleWidth line data =
  let
    dotPosition =
      Data.Point (sampleWidth / 2) 0
        |> Coordinate.toData system

    color =
      Line.color lineLook line data

    shape =
      Line.shape line
  in
  Svg.g
    [ Attributes.class "chart__sample" ]
    [ Line.viewSample lineLook line area data sampleWidth
    , Dot.viewSample dotLook shape color system data dotPosition
    ]



-- DEFAULTS


defaultLegends
  :  (Coordinate.Range -> Float)
  -> (Coordinate.Range -> Float)
  -> List data
  -> Arguments data msg
  -> Coordinate.System
  -> List (Legend msg)
  -> Svg msg
defaultLegends toX toY hovered arguments system legends =
  let
    viewLegends =
      Utils.indexedMap2 (defaultLegend arguments hovered)
  in
  Svg.g
    [ Attributes.class "chart__legends"
    , Svg.transform
        [ Svg.move system (toX system.x) (toY system.y)
        , Svg.offset 0 10
        ]
    ]
    (viewLegends legends arguments.data)


defaultLegend : Arguments data msg -> List data -> Int -> Legend msg -> List (Data.Data data) -> Svg msg
defaultLegend arguments hovered index { sample, label } data =
  let
    hoveredData =
      List.map .user data
        |> List.filter (flip List.member hovered)
        |> List.head

    hoveredText =
      case hoveredData of
        Nothing    -> ""
        Just value -> printYValue value

    printYValue value =
      case arguments.y value of
        Nothing    -> ": Unknown"
        Just value -> ": " ++ toString value
  in
   Svg.g
    [ Attributes.class "chart__legend"
    , Svg.transform [ Svg.offset 20 (toFloat index * 20) ]
    ]
    [ sample
    , Svg.g
        [ Svg.transform [ Svg.offset 40 4 ] ]
        [ Svg.label "inherit" (label ++ hoveredText) ]
    ]
