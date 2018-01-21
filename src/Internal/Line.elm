module Internal.Line exposing
  ( Line(..), Config, lineConfig, line, dash
  , Look, default, wider, custom
  , Style, style
  , view, viewSample
  )

{-|


-}

import Svg
import Svg.Attributes as Attributes
import Lines.Color as Color
import Lines.Junk as Junk
import Internal.Area as Area
import Internal.Coordinate as Coordinate
import Internal.Data as Data
import Internal.Dot as Dot
import Internal.Interpolation as Interpolation
import Internal.Path as Path
import Internal.Utils as Utils



{-| -}
type Line data =
  Line (Config data)


{-| -}
type alias Config data =
  { color : Color.Color
  , shape : Dot.Shape
  , dashing : List Float
  , label : String
  , data : List data
  }


{-| -}
lineConfig : Line data -> Config data
lineConfig (Line line) =
  line


{-| -}
line : Color.Color -> Dot.Shape -> String -> List data -> Line data
line color shape label data =
  Line <| Config color shape [] label data


{-| -}
dash : Color.Color -> Dot.Shape -> String -> List Float -> List data -> Line data
dash color shape label dashing data =
  Line <| Config color shape dashing label data



-- LOOK


{-| -}
type Look data =
  Look (Int -> List data -> Color.Color -> Style)


{-| -}
default : Look data
default =
  Look <| \_ _ color -> style 1 color


{-| -}
wider : Float -> Look data
wider width =
  Look <| \_ _ color -> style width color


{-| -}
custom : (Int -> List data -> Color.Color -> Style) -> Look data
custom =
  Look



-- STYLE


{-| -}
type Style =
  Style Float Color.Color


{-| -}
style : Float -> Color.Color -> Style
style  =
  Style



-- VIEW


type alias Arguments data =
  { system : Coordinate.System
  , dotLook : Dot.Look data
  , interpolation : Interpolation.Interpolation
  , lineLook : Look data
  , area : Area.Area
  , id : String
  }


{-| -}
view : Arguments data -> List (Line data) -> List (List (Data.Data data)) -> Svg.Svg msg
view arguments lines datas =
  let
    container =
      Svg.g [ Attributes.class "chart__lines" ]

    buildLineViews =
      if Area.opacityContainer arguments.area < 1
        then viewStacked arguments.area
        else viewNormal
  in
  Utils.indexedMap2 (viewSingle arguments) lines datas
    |> Utils.unzip3
    |> buildLineViews
    |> container


viewNormal : ( List (Svg.Svg msg), List (Svg.Svg msg), List (Svg.Svg msg) ) -> List (Svg.Svg msg)
viewNormal ( areas, lines, dots ) =
  let
    view area line dots =
      Svg.g [ Attributes.class "chart__line" ] [ area, line, dots ]
  in
  List.map3 view areas lines dots


viewStacked : Area.Area ->  ( List (Svg.Svg msg), List (Svg.Svg msg), List (Svg.Svg msg) ) -> List (Svg.Svg msg)
viewStacked area ( areas, lines, dots ) =
  let opacity = "opacity: " ++ toString (Area.opacityContainer area)
      toList l d = [ l, d ]
      bottoms = List.concat <| List.map2 toList lines dots
  in
  [ Svg.g [ Attributes.class "chart__bottoms", Attributes.style opacity ] areas
  , Svg.g [ Attributes.class "chart__tops" ] bottoms
  ]


viewSingle : Arguments data -> Int -> Line data -> List (Data.Data data) -> ( Svg.Svg msg, Svg.Svg msg, Svg.Svg msg )
viewSingle ({ system } as arguments) index (Line lineConfig) dataPoints =
  let
    parts =
      Utils.part .isReal dataPoints [] []

    -- Dots
    viewDots =
      parts
        |> List.concat
        |> List.filter (Data.isWithinRange system << .point)
        |> List.map viewDot
        |> Svg.g [ Attributes.class "chart__dots" ]

    viewDot =
      Dot.view
        { system = arguments.system
        , dotLook = arguments.dotLook
        , shape = lineConfig.shape
        , color = lineConfig.color
        }

    -- Interpolations
    commands =
      Interpolation.toCommands arguments.interpolation <|
        List.map (List.map .point) parts

    viewAreas () =
      Svg.g
        [ Attributes.class "chart__interpolation__area" ] <|
        List.map2 (viewArea arguments index lineConfig) commands parts

    viewLines =
      Svg.g
        [ Attributes.class "chart__interpolation__line" ] <|
        List.map2 (viewLine arguments index lineConfig) commands parts
  in
  ( Utils.viewIf (Area.hasArea arguments.area) viewAreas
  , viewLines
  , viewDots
  )



-- VIEW / LINE


viewLine : Arguments data -> Int -> Config data -> List Path.Command -> List (Data.Data data) -> Svg.Svg msg
viewLine { system, lineLook, id } index lineConfig interpolation dataPoints =
  let
    lineAttributes =
      Junk.withinChartArea system :: toLineAttributes lineLook index lineConfig dataPoints
  in
  Utils.viewWithFirst dataPoints <| \first rest ->
    Path.view system lineAttributes <|
      Path.Move first.point :: interpolation


toLineAttributes : Look data -> Int -> Config data -> List (Data.Data data) -> List (Svg.Attribute msg)
toLineAttributes (Look look) index { color, dashing } dataPoints =
  let
    (Style width finalColor) =
      look index (List.map .data dataPoints) color
  in
  [ Attributes.style "pointer-events: none;"
  , Attributes.class "chart__interpolation__line__fragment"
  , Attributes.stroke finalColor
  , Attributes.strokeWidth (toString width)
  , Attributes.strokeDasharray <| String.join " " (List.map toString dashing)
  , Attributes.fill "transparent"
  ]



-- VIEW / AREA


viewArea : Arguments data -> Int -> Config data -> List Path.Command -> List (Data.Data data) -> Svg.Svg msg
viewArea { system, lineLook, area, id } index lineConfig interpolation dataPoints =
  let
    ground dataPoint =
      Data.Point dataPoint.point.x (Utils.towardsZero system.y)

    attributes =
      Junk.withinChartArea system
        :: Attributes.fillOpacity (toString (Area.opacitySingle area))
        :: toAreaAttributes lineLook index lineConfig area dataPoints
  in
  Utils.viewWithEdges dataPoints <| \first rest last ->
    Path.view system attributes <|
      [ Path.Move (ground first), Path.Line first.point ]
      ++ interpolation ++
      [ Path.Line (ground last) ]


toAreaAttributes : Look data -> Int -> Config data -> Area.Area -> List (Data.Data data) -> List (Svg.Attribute msg)
toAreaAttributes (Look look) index { color } area dataPoints =
  let
    (Style width finalColor) =
      look index (List.map .data dataPoints) color
  in
  [ Attributes.class "chart__interpolation__area__fragment"
  , Attributes.fill finalColor
  ]



-- VIEW / SAMPLE


{-| -}
viewSample : Look data -> Int -> Config data -> Area.Area -> Float -> Svg.Svg msg
viewSample look index lineConfig area sampleWidth =
  let
    lineAttributes =
      toLineAttributes look index lineConfig []

    sizeAttributes =
      [ Attributes.x1 "0"
      , Attributes.y1 "0"
      , Attributes.x2 <| toString sampleWidth
      , Attributes.y2 "0"
      ]

    areaAttributes =
      Attributes.fillOpacity (toString (Area.opacity area))
       :: toAreaAttributes look index lineConfig area []

    rectangleAttributes =
      [ Attributes.x "0"
      , Attributes.y "0"
      , Attributes.height "9"
      , Attributes.width <| toString sampleWidth
      ]

    viewRectangle () =
      Svg.rect (areaAttributes ++ rectangleAttributes) []
  in
  Svg.g []
    [ Svg.line (lineAttributes ++ sizeAttributes) []
    , Utils.viewIf (Area.hasArea area) viewRectangle
    ]
