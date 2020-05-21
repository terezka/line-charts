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
color (Config config) (Series line_) data_ =
  let
    (Style style_) =
      config (List.map .user data_)
  in
  style_.color line_.color



-- LINES


{-| -}
line : Color.Color -> Dot.Shape -> String -> List data -> Series data
line color_ shape_ label_ data_ =
  Series <| SeriesConfig color_ shape_ [] label_ data_


{-| -}
dash : Color.Color -> Dot.Shape -> String -> List Float -> List data -> Series data
dash color_ shape_ label_ dashing_ data_ =
  Series <| SeriesConfig color_ shape_ dashing_ label_ data_



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
style width color_ =
  Style { width = width, color = color_ }



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
    view_ area_ line_ dots_ =
      Svg.g [ Attributes.class "chart__line" ] [ area_, line_, dots_ ]
  in
  List.map3 view_ areas lines dots


viewStacked : Area.Config ->  ( List (Svg.Svg msg), List (Svg.Svg msg), List (Svg.Svg msg) ) -> List (Svg.Svg msg)
viewStacked area ( areas, lines, dots ) =
  let opacity = "opacity: " ++ String.fromFloat (Area.opacityContainer area)
      toList l d = [ l, d ]
      bottoms = List.concat <| List.map2 toList lines dots
  in
  [ Svg.g [ Attributes.class "chart__bottoms", Attributes.style opacity ] areas
  , Svg.g [ Attributes.class "chart__tops" ] bottoms
  ]


viewSingle : Arguments data -> Series data -> List (Data.Data data) -> ( Svg.Svg msg, Svg.Svg msg, Svg.Svg msg )
viewSingle arguments line_ data_ =
  let
    -- Parting
    sections =
      Utils.part .isReal data_ [] []

    parts =
      List.map Tuple.first sections

    -- Style
    style_ =
      arguments.lineConfig |> \(Config look) -> look (List.map .user data_)

    -- Dots
    viewDots =
      parts
        |> List.concat
        |> List.filter (Data.isWithinRange arguments.system << .point)
        |> List.map (viewDot arguments line_ style_)
        |> Svg.g [ Attributes.class "chart__dots" ]

    -- Interpolations
    commands =
      Interpolation.toCommands arguments.interpolation sections

    viewAreas () =
      Svg.g
        [ Attributes.class "chart__interpolation__area" ] <|
        List.map2 (viewArea arguments line_ style_) commands parts

    viewSeriess =
      Svg.g
        [ Attributes.class "chart__interpolation__line" ] <|
        List.map2 (viewSeries arguments line_ style_) commands parts
  in
  ( Utils.viewIf (Area.hasArea arguments.area) viewAreas
  , viewSeriess
  , viewDots
  )



-- VIEW / DOT


viewDot : Arguments data -> Series data -> Style -> Data.Data data -> Svg.Svg msg
viewDot arguments (Series lineConfig) (Style style_) =
  Dot.view
    { system = arguments.system
    , dotsConfig = arguments.dotsConfig
    , shape = lineConfig.shape
    , color = style_.color lineConfig.color
    }



-- VIEW / LINE


viewSeries : Arguments data -> Series data -> Style -> List Path.Command -> List (Data.Data data) -> Svg.Svg msg
viewSeries { system, lineConfig } line_ style_ interpolation data_ =
  let
    attributes =
      Junk.withinChartArea system :: toSeriesAttributes line_ style_
  in
  Utils.viewWithFirst data_ <| \first _ ->
    Path.view system attributes (Path.Move first.point :: interpolation)


toSeriesAttributes : Series data -> Style -> List (Svg.Attribute msg)
toSeriesAttributes (Series serie) (Style style_) =
  [ Attributes.style "pointer-events: none;"
  , Attributes.class "chart__interpolation__line__fragment"
  , Attributes.stroke (Color.toCssString (style_.color serie.color))
  , Attributes.strokeWidth (String.fromFloat style_.width)
  , Attributes.strokeDasharray (String.join " " (List.map String.fromFloat serie.dashing))
  , Attributes.fill "transparent"
  ]



-- VIEW / AREA


viewArea : Arguments data -> Series data -> Style -> List Path.Command -> List (Data.Data data) -> Svg.Svg msg
viewArea { system, lineConfig, area } line_ style_ interpolation data_ =
  let
    ground point =
      Data.Point point.x (Utils.towardsZero system.y)

    attributes =
      Junk.withinChartArea system
        :: Attributes.fillOpacity (String.fromFloat (Area.opacitySingle area))
        :: toAreaAttributes line_ style_ area

    commands first middle last =
      Utils.concat
        [ Path.Move (ground <| Path.toPoint first), Path.Line (Path.toPoint first) ] interpolation
        [ Path.Line (ground <| Path.toPoint last) ]
  in
  Utils.viewWithEdges interpolation <| \first middle last ->
     Path.view system attributes (commands first middle last)


toAreaAttributes : Series data -> Style -> Area.Config -> List (Svg.Attribute msg)
toAreaAttributes (Series serie) (Style style_) area =
  [ Attributes.class "chart__interpolation__area__fragment"
  , Attributes.fill (Color.toCssString (style_.color serie.color))
  ]



-- VIEW / SAMPLE


{-| -}
viewSample : Config data -> Series data -> Area.Config -> List (Data.Data data) -> Float -> Svg.Svg msg
viewSample (Config look) line_ area data_ sampleWidth =
  let
    style_ =
      look (List.map .user data_)

    lineAttributes =
      toSeriesAttributes line_ style_

    sizeAttributes =
      [ Attributes.x1 "0"
      , Attributes.y1 "0"
      , Attributes.x2 (String.fromFloat sampleWidth)
      , Attributes.y2 "0"
      ]

    areaAttributes =
      Attributes.fillOpacity (String.fromFloat (Area.opacity area))
       :: toAreaAttributes line_ style_ area

    rectangleAttributes =
      [ Attributes.x "0"
      , Attributes.y "0"
      , Attributes.height "9"
      , Attributes.width (String.fromFloat sampleWidth)
      ]

    viewRectangle () =
      Svg.rect (areaAttributes ++ rectangleAttributes) []
  in
  Svg.g []
    [ Svg.line (lineAttributes ++ sizeAttributes) []
    , Utils.viewIf (Area.hasArea area) viewRectangle
    ]
