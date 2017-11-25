module Internal.Path exposing (Command(..), view)

{-| SVG path commands.

@docs Command, Point, view

-}

import Svg exposing (Svg, Attribute)
import Svg.Attributes exposing (d)
import Lines.Coordinate as Coordinate exposing (..)



{-| -}
type Command
  = Move Point
  | Line Point
  | Horizontal Float
  | Vertical Float
  | CubicBeziers Point Point Point
  | CubicBeziersShort Point Point
  | QuadraticBeziers Point Point
  | QuadraticBeziersShort Point
  | Arc Float Float Int Bool Bool Point
  | Close


{-| Makes a path SVG element, translating your commands with the provided system.

    view =
      Svg.Path.view system attributes commands

-}
view : Coordinate.System -> List (Attribute msg) -> List Command -> Svg msg
view system attributes commands =
  viewPath <| attributes ++ [ d (description system commands) ]



-- INTERNAL


viewPath : List (Attribute msg) -> Svg msg
viewPath attributes =
  Svg.path attributes []


description : System -> List Command -> String
description system commands =
  join (List.map (translate system >> toString) commands)


toString : Command -> String
toString command =
  case command of
    Move p ->
      "M" ++ point p

    Line p ->
      "L" ++ point p

    Horizontal x ->
      "H" ++ Basics.toString x

    Vertical y ->
      "V" ++ Basics.toString y

    CubicBeziers c1 c2 p ->
      "C" ++ points [ c1, c2, p ]

    CubicBeziersShort c1 p ->
      "Q" ++ points [ c1, p ]

    QuadraticBeziers c1 p ->
      "Q" ++ points [ c1, p ]

    QuadraticBeziersShort p ->
      "T" ++ point p

    Arc rx ry xAxisRotation largeArcFlag sweepFlag p ->
      "A" ++ join
        [ Basics.toString rx
        , Basics.toString ry
        , Basics.toString xAxisRotation
        , bool largeArcFlag
        , bool sweepFlag
        , point p
        ]

    Close ->
      "Z"


translate : System -> Command -> Command
translate system command =
  case command of
    Move p ->
      Move
        (toSVGPoint system p)

    Line p ->
      Line
        (toSVGPoint system p)

    Horizontal x ->
        Horizontal (toSVG X system x)

    Vertical y ->
        Vertical (toSVG Y system y)

    CubicBeziers c1 c2 p ->
      CubicBeziers
        (toSVGPoint system c1)
        (toSVGPoint system c2)
        (toSVGPoint system p)

    CubicBeziersShort c1 p ->
      CubicBeziersShort
        (toSVGPoint system c1)
        (toSVGPoint system p)

    QuadraticBeziers c1 p ->
      QuadraticBeziers
        (toSVGPoint system c1)
        (toSVGPoint system p)

    QuadraticBeziersShort p ->
      QuadraticBeziersShort
        (toSVGPoint system p)

    Arc rx ry xAxisRotation largeArcFlag sweepFlag p ->
      Arc rx ry xAxisRotation largeArcFlag sweepFlag
        (toSVGPoint system p)

    Close ->
      Close



-- HELP


join : List String -> String
join commands =
  String.join " " commands


point : Point -> String
point { x, y } =
  Basics.toString x ++ " " ++ Basics.toString y


points : List Point -> String
points points =
  String.join "," (List.map point points)


bool : Bool -> String
bool bool =
  if bool then "1" else "0"
