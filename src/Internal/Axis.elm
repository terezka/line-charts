module Internal.Axis exposing
  ( viewHorizontal, viewVertical )


import Svg exposing (Svg, Attribute, g, text_, tspan, text)
import Svg.Attributes as Attributes exposing (class, strokeWidth, stroke)
import LineChart.Axis.Tick as Tick exposing (Direction)
import Internal.Coordinate as Coordinate exposing (..)
import Internal.Data as Data
import Internal.Axis.Tick as Tick
import Internal.Axis.Ticks as Ticks
import Internal.Axis.Line as Line
import Internal.Axis.Intersection as Intersection
import Internal.Axis.Title as Title
import Internal.Svg as Svg exposing (..)
import Internal.Utils exposing (..)
import Color.Convert



-- INTERNAL / VIEW


type alias ViewConfig msg =
  { line : Line.Properties msg
  , ticks : List (Tick.Tick msg)
  , intersection : Float
  , title : Title.Config msg
  }


{-| -}
viewHorizontal : Coordinate.System -> Intersection.Config -> Title.Title msg -> Line.Config msg -> Ticks.Config data msg -> Svg msg
viewHorizontal system intersection title line axis =
    let
        config =
          { line = Line.config line system.xData system.x
          , ticks = Ticks.ticks system.xData system.x axis
          , intersection = Intersection.getY intersection system
          , title = Title.config title
          }

        at x =
          { x = x, y = config.intersection }

        viewAxisLine =
          viewHorizontalAxisLine system config.intersection

        viewTick tick =
          viewHorizontalTick system (at tick.position) tick
    in
    g [ class "chart__axis--horizontal" ]
      [ viewHorizontalTitle system at config
      , viewAxisLine config.line
      , g [ class "chart__ticks" ] (List.map viewTick config.ticks)
      ]


{-| -}
viewVertical : Coordinate.System -> Intersection.Config -> Title.Title msg -> Line.Config msg -> Ticks.Config data msg -> Svg msg
viewVertical system intersection title line axis =
    let
        config =
          { line = Line.config line system.yData system.y
          , ticks = Ticks.ticks system.yData system.y axis
          , intersection = Intersection.getX intersection system
          , title = Title.config title
          }

        at y =
          { x = config.intersection, y = y }

        viewAxisLine =
          viewVerticalAxisLine system config.intersection

        viewTick tick =
          viewVerticalTick system (at tick.position) tick
    in
    g [ class "chart__axis--vertical" ]
      [ viewVerticalTitle system at config
      , viewAxisLine config.line
      , g [ class "chart__ticks" ] (List.map viewTick config.ticks)
      ]



-- INTERNAL / VIEW / TITLE


viewHorizontalTitle : Coordinate.System -> (Float -> Data.Point) -> ViewConfig msg -> Svg msg
viewHorizontalTitle system at { title } =
  let
    position =
      at (title.position system.xData system.x)
  in
  g [ class "chart__title"
    , transform
        [ move system position.x position.y
        , offset title.xOffset (title.yOffset + 40)
        ]
    , anchorStyle Middle
    ]
    [ title.view ]


viewVerticalTitle : Coordinate.System -> (Float -> Data.Point) -> ViewConfig msg -> Svg msg
viewVerticalTitle system at { title } =
  let
    position =
      at (title.position system.yData system.y)
  in
  g [ class "chart__title"
    , transform
        [ move system position.x position.y
        , offset (title.xOffset - 5) (title.yOffset - 15)
        ]
    , anchorStyle Middle
    ]
    [ title.view ]



-- INTERNAL / VIEW / LINE


viewHorizontalAxisLine : Coordinate.System -> Float -> Line.Properties msg -> Svg msg
viewHorizontalAxisLine system axisPosition config =
  horizontal system (attributesLine config) axisPosition config.start config.end


viewVerticalAxisLine : Coordinate.System -> Float -> Line.Properties msg -> Svg msg
viewVerticalAxisLine system axisPosition config =
  vertical system (attributesLine config) axisPosition config.start config.end


attributesLine : Line.Properties msg -> List (Svg.Attribute msg)
attributesLine { events, width, color } =
  events ++ [ strokeWidth (toString width), stroke (Color.Convert.colorToHex color) ]



-- INTERNAL / VIEW / TICK


viewHorizontalTick : Coordinate.System -> Data.Point -> Tick.Tick msg -> Svg msg
viewHorizontalTick system ({ x, y } as point) tick =
  g [ class "chart__tick" ]
    [ xTick system (lengthOfTick tick) (attributesTick tick) y x
    , viewMaybe tick.label (viewHorizontalLabel system tick point)
    ]


viewVerticalTick : Coordinate.System -> Data.Point -> Tick.Tick msg -> Svg msg
viewVerticalTick system ({ x, y } as point) tick =
  g [ class "chart__tick" ]
    [ yTick system (lengthOfTick tick) (attributesTick tick) x y
    , viewMaybe tick.label (viewVerticalLabel system tick point)
    ]


lengthOfTick : Tick.Tick msg -> Float
lengthOfTick { length, direction } =
  if Tick.isPositive direction then -length else length


attributesTick : Tick.Tick msg -> List (Svg.Attribute msg)
attributesTick { width, color } =
  [ strokeWidth (toString width), stroke (Color.Convert.colorToHex color) ]


viewHorizontalLabel : Coordinate.System -> Tick.Tick msg -> Data.Point -> Svg msg -> Svg msg
viewHorizontalLabel system { direction, length } position view =
  let
    yOffset = if Tick.isPositive direction then -5 - length else 15 + length
  in
  g [ transform [ move system position.x position.y, offset 0 yOffset ]
    , anchorStyle Middle
    ]
    [ view ]


viewVerticalLabel : Coordinate.System -> Tick.Tick msg -> Data.Point -> Svg msg -> Svg msg
viewVerticalLabel system { direction, length } position view =
  let
    anchor = if Tick.isPositive direction then Start else End
    xOffset = if Tick.isPositive direction then 5 + length else -5 - length
  in
  g [ transform [ move system position.x position.y, offset xOffset 5 ]
    , anchorStyle anchor
    ]
    [ view ]
