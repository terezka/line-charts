module Internal.Line exposing
  ( Line(..), Config, lineConfig, line, dash
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
  { width : Float
  , color : Color.Color
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
line : Float -> Color.Color -> Dot.Shape -> String -> List data -> Line data
line width color shape label data =
  Line <| Config width color shape [] label data


{-| -}
dash : Float -> Color.Color -> Dot.Shape -> String -> List Float -> List data -> Line data
dash width color shape label dashing data =
  Line <| Config width color shape dashing label data



-- VIEW


type alias Arguments data =
  { system : Coordinate.System
  , dotLook : Dot.Look data
  , interpolation : Interpolation.Interpolation
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
  List.map2 (viewSingle arguments) lines datas
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


viewSingle : Arguments data -> Line data -> List (Data.Data data) -> ( Svg.Svg msg, Svg.Svg msg, Svg.Svg msg )
viewSingle ({ system } as arguments) (Line lineConfig) dataPoints =
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
        List.map2 (viewArea arguments lineConfig) commands parts

    viewLines =
      Svg.g
        [ Attributes.class "chart__interpolation__line" ] <|
        List.map2 (viewLine arguments lineConfig) commands parts
  in
  ( Utils.viewIf (Area.hasArea arguments.area) viewAreas
  , viewLines
  , viewDots
  )



-- VIEW / LINE


viewLine : Arguments data -> Config data -> List Path.Command -> List (Data.Data data) -> Svg.Svg msg
viewLine { system, id } lineConfig interpolation dataPoints =
  let
    lineAttributes =
      Junk.withinChartArea system :: toLineAttributes lineConfig dataPoints
  in
  Utils.viewWithFirst dataPoints <| \first rest ->
    Path.view system lineAttributes <|
      Path.Move first.point :: interpolation


toLineAttributes : Config data -> List (Data.Data data) -> List (Svg.Attribute msg)
toLineAttributes { color, width, dashing } dataPoints =
  [ Attributes.style "pointer-events: none;"
  , Attributes.class "chart__interpolation__line__fragment"
  , Attributes.stroke color
  , Attributes.strokeWidth (toString width)
  , Attributes.strokeDasharray <| String.join " " (List.map toString dashing)
  , Attributes.fill "transparent"
  ]



-- VIEW / AREA


viewArea : Arguments data -> Config data -> List Path.Command -> List (Data.Data data) -> Svg.Svg msg
viewArea { system, area, id } lineConfig interpolation dataPoints =
  let
    ground dataPoint =
      Data.Point dataPoint.point.x (Utils.towardsZero system.y)

    attributes =
      Junk.withinChartArea system
        :: Attributes.fillOpacity (toString (Area.opacitySingle area))
        :: toAreaAttributes lineConfig area dataPoints
  in
  Utils.viewWithEdges dataPoints <| \first rest last ->
    Path.view system attributes <|
      [ Path.Move (ground first), Path.Line first.point ]
      ++ interpolation ++
      [ Path.Line (ground last) ]


toAreaAttributes : Config data -> Area.Area -> List (Data.Data data) -> List (Svg.Attribute msg)
toAreaAttributes { color } area dataPoints =
  [ Attributes.class "chart__interpolation__area__fragment"
  , Attributes.fill color
  ]



-- VIEW / SAMPLE


{-| -}
viewSample : Config data -> Area.Area -> Float -> Svg.Svg msg
viewSample lineConfig area sampleWidth =
  let
    lineAttributes =
      toLineAttributes lineConfig []

    sizeAttributes =
      [ Attributes.x1 "0"
      , Attributes.y1 "0"
      , Attributes.x2 <| toString sampleWidth
      , Attributes.y2 "0"
      ]

    areaAttributes =
      Attributes.fillOpacity (toString (Area.opacity area))
       :: toAreaAttributes lineConfig area []

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
