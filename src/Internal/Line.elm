module Internal.Line exposing
  ( Series, line, dash
  , Config, default, wider, custom
  , Style, style
  -- INTERNAL
  , shape, label, color, data
  , view, viewSample
  )

{-|


-}

import Svg
import Svg.Attributes as Attributes
import LineChart.Junk as Junk
import Internal.Area as Area
import Internal.Coordinate as Coordinate
import Internal.Data as Data
import Internal.Dots as Dot
import Internal.Interpolation as Interpolation
import Internal.Path as Path
import Internal.Utils as Utils
import Color
import Color.Convert



-- CONFIG


{-| -}
type Series data =
  Series (SeriesConfig data)


{-| -}
type alias SeriesConfig data =
  { color : Color.Color
  , shape : Dot.Shape
  , dashing : List Float
  , label : String
  , data : List data
  }


{-| -}
label : Series data -> String
label (Series config) =
  config.label


{-| -}
shape : Series data -> Dot.Shape
shape (Series config) =
  config.shape


{-| -}
data : Series data -> List data
data (Series config) =
  config.data


{-| -}
color : Config data -> Series data -> List (Data.Data data) -> Color.Color
color (Config config) (Series line) data =
  let
    (Style style) =
      config (List.map .user data)
  in
  style.color line.color



-- LINES


{-| -}
line : Color.Color -> Dot.Shape -> String -> List data -> Series data
line color shape label data =
  Series <| SeriesConfig color shape [] label data


{-| -}
dash : Color.Color -> Dot.Shape -> String -> List Float -> List data -> Series data
dash color shape label dashing data =
  Series <| SeriesConfig color shape dashing label data



-- LOOK


{-| -}
type Config data =
  Config (List data -> Style)


{-| -}
default : Config data
default =
  Config <| \_ -> style 1 identity


{-| -}
wider : Float -> Config data
wider width =
  Config <| \_ -> style width identity


{-| -}
custom : (List data -> Style) -> Config data
custom =
  Config



-- STYLE


{-| -}
type Style =
  Style
    { width : Float
    , color : Color.Color -> Color.Color
    }


{-| -}
style : Float -> (Color.Color -> Color.Color) -> Style
style width color =
  Style { width = width, color = color }



-- VIEW


type alias Arguments data =
  { system : Coordinate.System
  , dotsConfig : Dot.Config data
  , interpolation : Interpolation.Config
  , lineConfig : Config data
  , area : Area.Config
  }


{-| -}
view : Arguments data -> List (Series data) -> List (List (Data.Data data)) -> Svg.Svg msg
view arguments lines datas =
  let
    container =
      Svg.g [ Attributes.class "chart__lines" ]

    buildSeriesViews =
      if Area.opacityContainer arguments.area < 1
        then viewStacked arguments.area
        else viewNormal
  in
  List.map2 (viewSingle arguments) lines datas
    |> Utils.unzip3
    |> buildSeriesViews
    |> container


viewNormal : ( List (Svg.Svg msg), List (Svg.Svg msg), List (Svg.Svg msg) ) -> List (Svg.Svg msg)
viewNormal ( areas, lines, dots ) =
  let
    view area line dots =
      Svg.g [ Attributes.class "chart__line" ] [ area, line, dots ]
  in
  List.map3 view areas lines dots


viewStacked : Area.Config ->  ( List (Svg.Svg msg), List (Svg.Svg msg), List (Svg.Svg msg) ) -> List (Svg.Svg msg)
viewStacked area ( areas, lines, dots ) =
  let opacity = "opacity: " ++ toString (Area.opacityContainer area)
      toList l d = [ l, d ]
      bottoms = List.concat <| List.map2 toList lines dots
  in
  [ Svg.g [ Attributes.class "chart__bottoms", Attributes.style opacity ] areas
  , Svg.g [ Attributes.class "chart__tops" ] bottoms
  ]


viewSingle : Arguments data -> Series data -> List (Data.Data data) -> ( Svg.Svg msg, Svg.Svg msg, Svg.Svg msg )
viewSingle arguments line data =
  let
    -- Parting
    parts =
      Utils.part .isReal data [] []

    -- Style
    style =
      arguments.lineConfig |> \(Config look) -> look (List.map .user data)

    -- Dots
    viewDots =
      parts
        |> List.concat
        |> List.filter (Data.isWithinRange arguments.system << .point)
        |> List.map (viewDot arguments line style)
        |> Svg.g [ Attributes.class "chart__dots" ]

    -- Interpolations
    commands =
      Interpolation.toCommands arguments.interpolation <|
        List.map (List.map .point) parts

    viewAreas () =
      Svg.g
        [ Attributes.class "chart__interpolation__area" ] <|
        List.map2 (viewArea arguments line style) commands parts

    viewSeriess =
      Svg.g
        [ Attributes.class "chart__interpolation__line" ] <|
        List.map2 (viewSeries arguments line style) commands parts
  in
  ( Utils.viewIf (Area.hasArea arguments.area) viewAreas
  , viewSeriess
  , viewDots
  )



-- VIEW / DOT


viewDot : Arguments data -> Series data -> Style -> Data.Data data -> Svg.Svg msg
viewDot arguments (Series lineConfig) (Style style) =
  Dot.view
    { system = arguments.system
    , dotsConfig = arguments.dotsConfig
    , shape = lineConfig.shape
    , color = style.color lineConfig.color
    }



-- VIEW / LINE


viewSeries : Arguments data -> Series data -> Style -> List Path.Command -> List (Data.Data data) -> Svg.Svg msg
viewSeries { system, lineConfig } line style interpolation data =
  let
    attributes =
      Junk.withinChartArea system :: toSeriesAttributes line style
  in
  Utils.viewWithFirst data <| \first _ ->
    Path.view system attributes (Path.Move first.point :: interpolation)


toSeriesAttributes : Series data -> Style -> List (Svg.Attribute msg)
toSeriesAttributes (Series { color, dashing }) (Style style) =
  [ Attributes.style "pointer-events: none;"
  , Attributes.class "chart__interpolation__line__fragment"
  , Attributes.stroke (Color.Convert.colorToHex (style.color color))
  , Attributes.strokeWidth (toString style.width)
  , Attributes.strokeDasharray (String.join " " (List.map toString dashing))
  , Attributes.fill "transparent"
  ]



-- VIEW / AREA


viewArea : Arguments data -> Series data -> Style -> List Path.Command -> List (Data.Data data) -> Svg.Svg msg
viewArea { system, lineConfig, area } line style interpolation data =
  let
    ground data =
      Data.Point data.point.x (Utils.towardsZero system.y)

    attributes =
      Junk.withinChartArea system
        :: Attributes.fillOpacity (toString (Area.opacitySingle area))
        :: toAreaAttributes line style area

    commands first rest last =
      Utils.concat
        [ Path.Move (ground first), Path.Line first.point ] interpolation
        [ Path.Line (ground last) ]
  in
  Utils.viewWithEdges data <| \first rest last ->
     Path.view system attributes (commands first rest last)


toAreaAttributes : Series data -> Style -> Area.Config -> List (Svg.Attribute msg)
toAreaAttributes (Series { color }) (Style style) area =
  [ Attributes.class "chart__interpolation__area__fragment"
  , Attributes.fill (Color.Convert.colorToHex (style.color color))
  ]



-- VIEW / SAMPLE


{-| -}
viewSample : Config data -> Series data -> Area.Config -> List (Data.Data data) -> Float -> Svg.Svg msg
viewSample (Config look) line area data sampleWidth =
  let
    style =
      look (List.map .user data)

    lineAttributes =
      toSeriesAttributes line style

    sizeAttributes =
      [ Attributes.x1 "0"
      , Attributes.y1 "0"
      , Attributes.x2 (toString sampleWidth)
      , Attributes.y2 "0"
      ]

    areaAttributes =
      Attributes.fillOpacity (toString (Area.opacity area))
       :: toAreaAttributes line style area

    rectangleAttributes =
      [ Attributes.x "0"
      , Attributes.y "0"
      , Attributes.height "9"
      , Attributes.width (toString sampleWidth)
      ]

    viewRectangle () =
      Svg.rect (areaAttributes ++ rectangleAttributes) []
  in
  Svg.g []
    [ Svg.line (lineAttributes ++ sizeAttributes) []
    , Utils.viewIf (Area.hasArea area) viewRectangle
    ]
