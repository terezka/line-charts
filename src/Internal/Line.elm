module Internal.Line exposing
  ( Line(..), line, dash
  , Look, default, wider, custom
  , Style, style
  -- INTERNAL
  , shape, label, color, data
  , view, viewSample
  )

{-|


-}

import Svg
import Svg.Attributes as Attributes
import Lines.Junk as Junk
import Internal.Area as Area
import Internal.Coordinate as Coordinate
import Internal.Data as Data
import Internal.Dot as Dot
import Internal.Interpolation as Interpolation
import Internal.Path as Path
import Internal.Utils as Utils
import Color
import Color.Convert



-- CONFIG


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
label : Line data -> String
label (Line config) =
  config.label


{-| -}
shape : Line data -> Dot.Shape
shape (Line config) =
  config.shape


{-| -}
data : Line data -> List data
data (Line config) =
  config.data


{-| -}
color : Look data -> Line data -> List (Data.Data data) -> Color.Color
color (Look look) (Line config) data =
  let
    (Style style) =
      look (List.map .user data)
  in
  style.color config.color



-- LINES


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
  Look (List data -> Style)


{-| -}
default : Look data
default =
  Look <| \_ -> style 1 identity


{-| -}
wider : Float -> Look data
wider width =
  Look <| \_ -> style width identity


{-| -}
custom : (List data -> Style) -> Look data
custom =
  Look



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
viewSingle arguments line data =
  let
    -- Parting
    parts =
      Utils.part .isReal data [] []

    -- Style
    style =
      arguments.lineLook |> \(Look look) -> look (List.map .user data)

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

    viewLines =
      Svg.g
        [ Attributes.class "chart__interpolation__line" ] <|
        List.map2 (viewLine arguments line style) commands parts
  in
  ( Utils.viewIf (Area.hasArea arguments.area) viewAreas
  , viewLines
  , viewDots
  )



-- VIEW / DOT


viewDot : Arguments data -> Line data -> Style -> Data.Data data -> Svg.Svg msg
viewDot arguments (Line lineConfig) (Style style) =
  Dot.view
    { system = arguments.system
    , dotLook = arguments.dotLook
    , shape = lineConfig.shape
    , color = style.color lineConfig.color
    }



-- VIEW / LINE


viewLine : Arguments data -> Line data -> Style -> List Path.Command -> List (Data.Data data) -> Svg.Svg msg
viewLine { system, lineLook, id } line style interpolation data =
  let
    attributes =
      Junk.withinChartArea system :: toLineAttributes line style
  in
  Utils.viewWithFirst data <| \first _ ->
    Path.view system attributes (Path.Move first.point :: interpolation)


toLineAttributes : Line data -> Style -> List (Svg.Attribute msg)
toLineAttributes (Line { color, dashing }) (Style style) =
  [ Attributes.style "pointer-events: none;"
  , Attributes.class "chart__interpolation__line__fragment"
  , Attributes.stroke (Color.Convert.colorToHex (style.color color))
  , Attributes.strokeWidth (toString style.width)
  , Attributes.strokeDasharray (String.join " " (List.map toString dashing))
  , Attributes.fill "transparent"
  ]



-- VIEW / AREA


viewArea : Arguments data -> Line data -> Style -> List Path.Command -> List (Data.Data data) -> Svg.Svg msg
viewArea { system, lineLook, area, id } line style interpolation data =
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


toAreaAttributes : Line data -> Style -> Area.Area -> List (Svg.Attribute msg)
toAreaAttributes (Line { color }) (Style style) area =
  [ Attributes.class "chart__interpolation__area__fragment"
  , Attributes.fill (Color.Convert.colorToHex (style.color color))
  ]



-- VIEW / SAMPLE


{-| -}
viewSample : Look data -> Line data -> Area.Area -> List (Data.Data data) -> Float -> Svg.Svg msg
viewSample (Look look) line area data sampleWidth =
  let
    style =
      look (List.map .user data)

    lineAttributes =
      toLineAttributes line style

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
