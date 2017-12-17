module Internal.Axis exposing (..)


import Svg exposing (Svg, Attribute, g, text_, tspan, text)
import Svg.Attributes as Attributes exposing (class)
import Lines.Coordinate as Coordinate exposing (..)
import Internal.Utils exposing (..)
import Internal.Svg as Svg exposing (..)
import Round



-- CONFIG


{-| -}
type alias Axis data msg =
  { variable : data -> Float
  , limits : Coordinate.Limits -> Coordinate.Limits
  , look : Look msg
  , length : Float
  }


{-| -}
type alias Look msg =
  { title : Title msg
  , position : Coordinate.Limits -> Float
  , offset : Float
  , line : Maybe (Coordinate.Limits -> Line msg)
  , marks : Coordinate.Limits -> List (Mark msg)
  , direction : Direction
  }


{-| -}
type alias Title msg =
    { view : Svg msg
    , position : Coordinate.Limits -> Float
    , xOffset : Float
    , yOffset : Float
    }


{-| -}
type alias Mark msg =
  { label : Maybe (Svg msg)
  , tick : Maybe (Tick msg)
  , position : Float
  }


{-| -}
type alias Line msg =
  { attributes : List (Attribute msg)
  , start : Float
  , end : Float
  }


{-| -}
type alias Tick msg =
  { attributes : List (Attribute msg)
  , length : Int
  }


{-| -}
type Direction
  = Negative
  | Positive



-- API


{-| -}
axis : Float -> (data -> Float) -> String -> Axis data msg
axis length variable title =
  { variable = variable
  , limits = identity
  , look = look title (List.map mark << values False (round <| length / 100))
  , length = length
  }


{-| -}
axisCustom : Float -> (data -> Float) -> (Coordinate.Limits -> Coordinate.Limits) -> Look msg -> Axis data msg
axisCustom length variable limits look =
  { variable = variable
  , limits = limits
  , look = look
  , length = length
  }


{-| -}
look : String -> (Coordinate.Limits -> List (Mark msg)) -> Look msg
look title_ marks =
  { title = title title_ .max 0 0
  , position = towardsZero
  , offset = 20
  , line = Just line
  , marks = marks
  , direction = Negative
  }


{-| -}
lookCustom :
  { title : Title msg
  , position : Coordinate.Limits -> Float
  , line : Maybe (Coordinate.Limits -> Line msg)
  , marks : Coordinate.Limits -> List (Mark msg)
  }
  -> Look msg
lookCustom { title, position, line, marks} =
  { title = title
  , position = position
  , offset = 0
  , line = line
  , marks = marks
  , direction = Negative
  }


{-| -}
lookVeryCustom :
  { title : Title msg
  , position : Coordinate.Limits -> Float
  , offset : Float
  , line : Maybe (Coordinate.Limits -> Line msg)
  , marks : Coordinate.Limits -> List (Mark msg)
  , direction : Direction
  }
  -> Look msg
lookVeryCustom look =
  look


{-| -}
title : String -> (Coordinate.Limits -> Float) -> Float -> Float -> Title msg
title title =
  Title (viewText title)


{-| -}
titleCustom : Svg msg -> (Coordinate.Limits -> Float) -> Float -> Float -> Title msg
titleCustom =
  Title


{-| -}
mark : Float -> Mark msg
mark position =
  { label = Just <| viewText <| toString position
  , tick = Just tick
  , position = position
  }


{-| -}
markCustom : Maybe (Svg msg) -> Maybe (Tick msg) -> Float -> Mark msg
markCustom label tick position =
  { label = label
  , tick = tick
  , position = position
  }


{-| -}
line : Coordinate.Limits -> Line msg
line limits =
  { attributes = []
  , start = limits.min
  , end = limits.max
  }


{-| -}
lineCustom : List (Attribute msg) -> Coordinate.Limits -> Line msg
lineCustom attributes limits =
  { attributes = attributes
  , start = limits.min
  , end = limits.max
  }


{-| -}
tick : Tick msg
tick =
  { attributes = []
  , length = 5
  }


{-| TODO int to float -}
tickCustom : List (Attribute msg) -> Int -> Tick msg
tickCustom =
  Tick



-- VIEW


{-| -}
viewHorizontal : Coordinate.System -> Look msg -> Svg msg
viewHorizontal system axis =
    let
        axisPosition =
          axis.position system.y - scaleDataY system axis.offset

        at x =
          { x = x, y = axisPosition }

        viewAxisLine { start, end, attributes } =
          horizontal system attributes axisPosition start end

        viewMark { position, tick, label } =
          g [ class "mark" ]
            [ viewMaybe tick (viewHorizontalTick system axis (at position))
            , viewMaybe label (viewHorizontalLabel system axis (at position))
            ]
    in
    g [ class "axis--horizontal" ]
      [ viewHorizontalTitle system at axis
      , viewMaybe axis.line (apply system.x >> viewAxisLine)
      , g [ class "marks" ] (List.map viewMark (apply system.x axis.marks))
      ]


{-| -}
viewVertical : Coordinate.System -> Look msg -> Svg msg
viewVertical system axis =
    let
        axisPosition =
          axis.position system.x - scaleDataX system axis.offset

        at y =
          { x = axisPosition, y = y }

        viewAxisLine { start, end, attributes } =
          vertical system attributes axisPosition start end

        viewMark { position, tick, label } =
          g [ class "mark" ]
            [ viewMaybe tick (viewVerticalTick system axis (at position))
            , viewMaybe label (viewVerticalLabel system axis (at position))
            ]
    in
    g [ class "axis--vertical" ]
      [ viewVerticalTitle system at axis
      , viewMaybe axis.line (apply system.y >> viewAxisLine)
      , g [ class "marks" ] (List.map viewMark (apply system.y axis.marks))
      ]



-- VIEW TITLE


viewHorizontalTitle : Coordinate.System -> (Float -> Point) -> Look msg -> Svg msg
viewHorizontalTitle system at { title } =
  let
    position =
      at (title.position system.x)
  in
  g [ class "title"
    , transform
        [ move system position.x position.y
        , offset title.xOffset (title.yOffset + 40)
        ]
    , anchorStyle Middle
    ]
    [ title.view ]


viewVerticalTitle : Coordinate.System -> (Float -> Point) -> Look msg -> Svg msg
viewVerticalTitle system at { title } =
  let
    position =
      at (title.position system.y)
  in
  g [ class "title"
    , transform
        [ move system position.x position.y
        , offset (title.xOffset - 5) (title.yOffset - 15)
        ]
    , anchorStyle Middle
    ]
    [ title.view ]



-- VIEW TICK


viewHorizontalTick : Coordinate.System -> Look msg -> Point -> Tick msg -> Svg msg
viewHorizontalTick system view { x, y } { attributes, length } =
  xTick system (lengthOfTick view length) attributes y x


viewVerticalTick : Coordinate.System -> Look msg -> Point -> Tick msg -> Svg msg
viewVerticalTick system view { x, y } { attributes, length } =
  yTick system (lengthOfTick view length) attributes x y


lengthOfTick : Look msg -> Int -> Int
lengthOfTick { direction } length =
  if isPositive direction then -length else length



-- VIEW LABEL


viewHorizontalLabel : Coordinate.System -> Look msg -> Point -> Svg msg -> Svg msg
viewHorizontalLabel system { direction } position view =
  let
    yOffset = if isPositive direction then -10 else 20
  in
  g [ transform [ move system position.x position.y, offset 0 yOffset ]
    , anchorStyle Middle
    ]
    [ view ]


viewVerticalLabel : Coordinate.System -> Look msg -> Point -> Svg msg -> Svg msg
viewVerticalLabel system { direction } position view =
  let
    anchor = if isPositive direction then Start else End
    xOffset = if isPositive direction then 10 else -10
  in
  g [ transform [ move system position.x position.y, offset xOffset 5 ]
    , anchorStyle anchor
    ]
    [ view ]


viewText : String -> Svg msg
viewText string =
  text_ [] [ tspan [] [ text string ] ]



-- UTILS


isPositive : Direction -> Bool
isPositive direction =
  case direction of
    Positive -> True
    Negative -> False



-- VALUES


{-| -}
values : Bool -> Int -> Coordinate.Limits -> List Float
values exact amountRough limits =
    let
      range =
        limits.max - limits.min

      intervalRough =
        range / toFloat amountRough

      interval =
        getInterval intervalRough True exact

      ceilingTo number prec =
        prec * toFloat (ceiling (number / prec))

      beginning =
        ceilingTo limits.min interval
    in
    positions limits beginning interval 0 []


{-| -}
interval : Float -> Float -> Coordinate.Limits -> List Float
interval intersection interval limits =
    let
        offset value =
          interval * toFloat (floor (value / interval))

        beginning =
          intersection - offset (intersection - limits.min)
    in
    positions limits beginning interval 0 []



positions : Coordinate.Limits -> Float -> Float -> Float -> List Float -> List Float
positions limits beginning interval m acc =
  let next = correctFloat (beginning + (m * interval)) (getPrecision interval)
  in if next > limits.max then acc else positions limits beginning interval (m + 1) (next :: acc)


getInterval : Float -> Bool -> Bool -> Float
getInterval intervalRaw allowDecimals hasTickAmount =
  let
    magnitude =
      getMagnitude intervalRaw

    normalized =
      intervalRaw / magnitude

    multiples =
      getMultiples magnitude allowDecimals hasTickAmount

    findMultiple multiples =
      case multiples of
        m1 :: m2 :: rest ->
          if normalized <= (m1 + m2) / 2
            then m1 else findMultiple (m2 :: rest)

        m1 :: rest ->
          if normalized <= m1
            then m1 else findMultiple rest

        [] ->
          1

    findMultipleExact multiples =
      case multiples of
        m1 :: rest ->
          if m1 * magnitude >= intervalRaw
            then m1 else findMultipleExact rest

        [] ->
          1

    multiple =
      if hasTickAmount then
        findMultipleExact multiples
      else
        findMultiple multiples
  in
  correctFloat (multiple * magnitude) (getPrecision magnitude + getPrecision multiple)


getMultiples : Float -> Bool -> Bool -> List Float
getMultiples magnitude allowDecimals hasTickAmount =
  let
    defaults =
      if hasTickAmount then
        [ 1, 1.2, 1.5, 2, 2.5, 3, 4, 5, 6, 8, 10 ]
      else
        [ 1, 2, 2.5, 5, 10 ]
  in
    if allowDecimals then
      defaults
    else
      if magnitude == 1 then
        List.filter (\n -> toFloat (round n) /= n) defaults
      else if magnitude <= 0.1 then
        [ 1 / magnitude ]
      else
        defaults


-- UTILS


{-| -}
correctFloat : Float -> Int -> Float
correctFloat number prec =
  case String.split "." (toString number) of -- TODO
    [ before, after ] ->
        let
          afterSafe = after ++ String.repeat (prec + 2) "0"
          toFloatSafe = String.toFloat >> Result.withDefault 0
          decimals = String.slice 0 (prec + 1) <| afterSafe
        in
          toFloatSafe <| Round.round prec <| toFloatSafe <| before ++ "." ++ decimals

    _ ->
       number


{-| -}
getMagnitude : Float -> Float
getMagnitude num =
  toFloat <| 10 ^ (floor (logBase e num / logBase e 10))


{-| -}
getPrecision : Float -> Int
getPrecision interval =
  case String.split "." (toString interval) of -- TODO
    [ before, after ] ->
        String.length after

    _ ->
       0
