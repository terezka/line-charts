module Internal.Axis exposing
  ( Config, default, custom, full, time, none, picky
  , variable, pixels, range, ticks
  , viewHorizontal, viewVertical
  )


import Svg exposing (Svg, Attribute, g, text_, tspan, text)
import Svg.Attributes as Attributes exposing (class, strokeWidth, stroke)
import LineChart.Axis.Tick as Tick exposing (Direction)
import Internal.Coordinate as Coordinate exposing (..)
import LineChart.Colors as Colors
import Internal.Data as Data
import Internal.Axis.Range as Range
import Internal.Axis.Tick
import Internal.Axis.Values as Values
import Internal.Axis.Ticks as Ticks
import Internal.Axis.Line as AxisLine
import Internal.Axis.Intersection as Intersection
import Internal.Axis.Title as Title
import Internal.Svg as Svg exposing (..)
import Internal.Utils exposing (..)
import Color
import Time


{-| -}
type Config data msg =
  Config (Properties data msg)


{-| -}
type alias Properties data msg =
  { title : Title.Config msg
  , variable : data -> Maybe Float
  , pixels : Int
  , range : Range.Config
  , axisLine : AxisLine.Config msg
  , ticks : Ticks.Config msg
  }


{-| -}
default : Int -> String -> (data -> Float) -> Config data msg
default pixels_ title_ variable_ =
  custom
    { title = Title.atDataMax 0 0 title_
    , variable = Just << variable_
    , pixels = pixels_
    , range = Range.padded 20 20
    , axisLine = AxisLine.rangeFrame Colors.gray
    , ticks =
        Ticks.custom <| \data range_ ->
          let smallest = Coordinate.smallestRange data range_
              rangeLong = range_.max - range_.min
              rangeSmall = smallest.max - smallest.min
              diff = 1 - (rangeLong - rangeSmall) / rangeLong
              amount = round <| diff * toFloat pixels_ / 90
          in
          List.map Tick.float <| Values.float (Values.around amount) smallest
    }



{-| -}
full : Int -> String -> (data -> Float) -> Config data msg
full pixels_ title_ variable_ =
  custom
    { title = Title.atAxisMax 0 0 title_
    , variable = Just << variable_
    , pixels = pixels_
    , range = Range.padded 20 20
    , axisLine = AxisLine.default
    , ticks =
        Ticks.custom <| \data range_ ->
          let largest = Coordinate.largestRange data range_
              amount = pixels_ // 90
          in
          List.map Tick.float <| Values.float (Values.around amount) largest
    }


{-| -}
time : Time.Zone -> Int -> String -> (data -> Float) -> Config data msg
time zone pixels_ title_ variable_ =
  custom
    { title = Title.atDataMax 0 0 title_
    , variable = Just << variable_
    , pixels = pixels_
    , range = Range.padded 20 20
    , axisLine = AxisLine.rangeFrame Colors.gray
    , ticks =
        Ticks.custom <| \data range_ ->
          let smallest = Coordinate.smallestRange data range_
              rangeLong = range_.max - range_.min
              rangeSmall = smallest.max - smallest.min
              diff = 1 - (rangeLong - rangeSmall) / rangeLong
              amount = round <| diff * toFloat pixels_ / 90
          in
          List.map Tick.time <| Values.time zone amount smallest
    }


{-| -}
none : Int -> (data -> Float) ->  Config data msg
none pixels_ variable_ =
  custom
    { title = Title.default ""
    , variable = Just << variable_
    , pixels = pixels_
    , range = Range.padded 20 20
    , axisLine = AxisLine.none
    , ticks = Ticks.custom <| \_ _ -> []
    }


{-| -}
picky : Int -> String -> (data -> Float) -> List Float -> Config data msg
picky pixels_ title_ variable_ ticks_ =
  custom
    { title = Title.atAxisMax 0 0 title_
    , variable = Just << variable_
    , pixels = pixels_
    , range = Range.padded 20 20
    , axisLine = AxisLine.default
    , ticks = Ticks.custom <| \_ _ -> List.map Tick.float ticks_
    }


{-| -}
custom : Properties data msg -> Config data msg
custom =
  Config


{-| -}
variable : Config data msg -> (data -> Maybe Float)
variable (Config config) =
  config.variable


{-| -}
pixels : Config data msg -> Float
pixels (Config config) =
  toFloat config.pixels


{-| -}
range : Config data msg -> Range.Config
range (Config config) =
  config.range


{-| -}
ticks : Config data msg -> Ticks.Config msg
ticks (Config config) =
  config.ticks



-- INTERNAL / VIEW


type alias ViewConfig msg =
  { line : AxisLine.Properties msg
  , ticks : List (Tick.Properties msg)
  , intersection : Float
  , title : Title.Properties msg
  }


{-| -}
viewHorizontal : Coordinate.System -> Intersection.Config -> Config data msg -> Svg msg
viewHorizontal system intersection (Config config) =
    let
        viewConfig =
          { line = AxisLine.config config.axisLine system.xData system.x
          , ticks = Ticks.ticks system.xData system.x config.ticks
          , intersection = Intersection.getY intersection system
          , title = Title.config config.title
          }

        at x =
          { x = x, y = viewConfig.intersection }

        viewAxisLine =
          viewHorizontalAxisLine system viewConfig.intersection

        viewTick tick =
          viewHorizontalTick system (at tick.position) tick
    in
    g [ class "chart__axis--horizontal" ]
      [ viewHorizontalTitle system at viewConfig
      , viewAxisLine viewConfig.line
      , g [ class "chart__ticks" ] (List.map viewTick viewConfig.ticks)
      ]


{-| -}
viewVertical : Coordinate.System -> Intersection.Config -> Config data msg -> Svg msg
viewVertical system intersection (Config config) =
    let
        viewConfig =
          { line = AxisLine.config config.axisLine system.yData system.y
          , ticks = Ticks.ticks system.yData system.y config.ticks
          , intersection = Intersection.getX intersection system
          , title = Title.config config.title
          }

        at y =
          { x = viewConfig.intersection, y = y }

        viewAxisLine =
          viewVerticalAxisLine system viewConfig.intersection

        viewTick tick =
          viewVerticalTick system (at tick.position) tick
    in
    g [ class "chart__axis--vertical" ]
      [ viewVerticalTitle system at viewConfig
      , viewAxisLine viewConfig.line
      , g [ class "chart__ticks" ] (List.map viewTick viewConfig.ticks)
      ]



-- INTERNAL / VIEW / TITLE


viewHorizontalTitle : Coordinate.System -> (Float -> Data.Point) -> ViewConfig msg -> Svg msg
viewHorizontalTitle system at { title } =
  let position = at (title.position system.xData system.x)
      ( xOffset, yOffset ) = title.offset
  in
  g [ class "chart__title"
    , transform
        [ move system position.x position.y
        , offset (xOffset + 15) (yOffset + 5)
        ]
    , anchorStyle Start
    ]
    [ title.view ]


viewVerticalTitle : Coordinate.System -> (Float -> Data.Point) -> ViewConfig msg -> Svg msg
viewVerticalTitle system at { title } =
  let position = at (title.position system.yData system.y)
      ( xOffset, yOffset ) = title.offset
  in
  g [ class "chart__title"
    , transform
        [ move system position.x position.y
        , offset (xOffset + 2) (yOffset - 10)
        ]
    , anchorStyle End
    ]
    [ title.view ]



-- INTERNAL / VIEW / LINE


viewHorizontalAxisLine : Coordinate.System -> Float -> AxisLine.Properties msg -> Svg msg
viewHorizontalAxisLine system axisPosition config =
  horizontal system (attributesLine system config) axisPosition config.start config.end


viewVerticalAxisLine : Coordinate.System -> Float -> AxisLine.Properties msg -> Svg msg
viewVerticalAxisLine system axisPosition config =
  vertical system (attributesLine system config) axisPosition config.start config.end


attributesLine : Coordinate.System -> AxisLine.Properties msg -> List (Svg.Attribute msg)
attributesLine system { events, width, color } =
  events ++
    [ strokeWidth (String.fromFloat width)
    , stroke (Color.toCssString color)
    , Svg.withinChartArea system
    ]



-- INTERNAL / VIEW / TICK


viewHorizontalTick : Coordinate.System -> Data.Point -> Tick.Properties msg -> Svg msg
viewHorizontalTick system ({ x, y } as point) tick =
  g [ class "chart__tick" ]
    [ xTick system (lengthOfTick tick) (attributesTick tick) y x
    , viewMaybe tick.label (viewHorizontalLabel system tick point)
    ]


viewVerticalTick : Coordinate.System -> Data.Point -> Tick.Properties msg -> Svg msg
viewVerticalTick system ({ x, y } as point) tick =
  g [ class "chart__tick" ]
    [ yTick system (lengthOfTick tick) (attributesTick tick) x y
    , viewMaybe tick.label (viewVerticalLabel system tick point)
    ]


lengthOfTick : Tick.Properties msg -> Float
lengthOfTick { length, direction } =
  if Internal.Axis.Tick.isPositive direction then -length else length


attributesTick : Tick.Properties msg -> List (Svg.Attribute msg)
attributesTick { width, color } =
  [ strokeWidth (String.fromFloat width), stroke (Color.toCssString color) ]


viewHorizontalLabel : Coordinate.System -> Tick.Properties msg -> Data.Point -> Svg msg -> Svg msg
viewHorizontalLabel system { direction, length } position view =
  let
    yOffset = if Internal.Axis.Tick.isPositive direction then -5 - length else 15 + length
  in
  g [ transform [ move system position.x position.y, offset 0 yOffset ]
    , anchorStyle Middle
    ]
    [ view ]


viewVerticalLabel : Coordinate.System -> Tick.Properties msg -> Data.Point -> Svg msg -> Svg msg
viewVerticalLabel system { direction, length } position view =
  let
    anchor = if Internal.Axis.Tick.isPositive direction then Start else End
    xOffset = if Internal.Axis.Tick.isPositive direction then 5 + length else -5 - length
  in
  g [ transform [ move system position.x position.y, offset xOffset 5 ]
    , anchorStyle anchor
    ]
    [ view ]
