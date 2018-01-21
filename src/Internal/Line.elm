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
color : Look data -> List (Data.Data data) -> Line data -> Color.Color
color (Look look) data (Line config) =
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
viewSingle ({ system } as arguments) (Line lineConfig) data =
  let
    parts =
      Utils.part .isReal data [] []

    -- Dots
    viewDots =
      parts
        |> List.concat
        |> List.filter (Data.isWithinRange system << .point)
        |> List.map viewDot
        |> Svg.g [ Attributes.class "chart__dots" ]

    (Look lineLook) =
      arguments.lineLook

    (Style style) =
      lineLook (List.map .user data)

    viewDot =
      Dot.view
        { system = arguments.system
        , dotLook = arguments.dotLook
        , shape = lineConfig.shape
        , color = style.color lineConfig.color
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
viewLine { system, lineLook, id } lineConfig interpolation data =
  let
    lineAttributes =
      Junk.withinChartArea system :: toLineAttributes lineLook lineConfig data
  in
  Utils.viewWithFirst data <| \first rest ->
    Path.view system lineAttributes <|
      Path.Move first.point :: interpolation


toLineAttributes : Look data -> Config data -> List (Data.Data data) -> List (Svg.Attribute msg)
toLineAttributes (Look look) { color, dashing } data =
  let
    (Style style) =
      look (List.map .user data)
  in
  [ Attributes.style "pointer-events: none;"
  , Attributes.class "chart__interpolation__line__fragment"
  , Attributes.stroke (Color.Convert.colorToHex (style.color color))
  , Attributes.strokeWidth (toString style.width)
  , Attributes.strokeDasharray <| String.join " " (List.map toString dashing)
  , Attributes.fill "transparent"
  ]



-- VIEW / AREA


viewArea : Arguments data -> Config data -> List Path.Command -> List (Data.Data data) -> Svg.Svg msg
viewArea { system, lineLook, area, id } lineConfig interpolation data =
  let
    ground data =
      Data.Point data.point.x (Utils.towardsZero system.y)

    attributes =
      Junk.withinChartArea system
        :: Attributes.fillOpacity (toString (Area.opacitySingle area))
        :: toAreaAttributes lineLook lineConfig area data
  in
  Utils.viewWithEdges data <| \first rest last ->
    Path.view system attributes <|
      [ Path.Move (ground first), Path.Line first.point ]
      ++ interpolation ++
      [ Path.Line (ground last) ]


toAreaAttributes : Look data -> Config data -> Area.Area -> List (Data.Data data) -> List (Svg.Attribute msg)
toAreaAttributes (Look look) { color } area data =
  let
    (Style style) =
      look (List.map .user data)
  in
  [ Attributes.class "chart__interpolation__area__fragment"
  , Attributes.fill (Color.Convert.colorToHex (style.color color))
  ]



-- VIEW / SAMPLE


{-| -}
viewSample : Look data -> Line data -> Area.Area -> List (Data.Data data) -> Float -> Svg.Svg msg
viewSample look (Line config) area data sampleWidth =
  let
    lineAttributes =
      toLineAttributes look config data

    sizeAttributes =
      [ Attributes.x1 "0"
      , Attributes.y1 "0"
      , Attributes.x2 <| toString sampleWidth
      , Attributes.y2 "0"
      ]

    areaAttributes =
      Attributes.fillOpacity (toString (Area.opacity area))
       :: toAreaAttributes look config area []

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
