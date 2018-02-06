module LineChart.Line exposing
  ( Config, default
  , wider, hoverOne
  , custom
  , Style, style
  )

{-|

@docs Config, default, wider, hoverOne, custom

## Styles
@docs Style, style

-}

import Internal.Line as Line
import Color



{-| Use in the `LineChart.Config` passed to `LineChart.viewCustom`.

    chartConfig : LineChart.Config Data msg
    chartConfig =
      { ...
      , line = Line.default
      , ...
      }

-}
type alias Config data =
  Line.Config data


{-| Makes 1px wide lines.
-}
default : Config data
default =
  Line.default


{-| Pass the desired width of your lines.

    chartConfig : LineChart.Config Data msg
    chartConfig =
      { ...
      , line = Line.wider 3
      , ...
      }


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Line/Example1.elm)._

-}
wider : Float -> Config data
wider =
  Line.wider


{-| Makes the line, to which the data in the first argument belongs, wider!

    chartConfig : Maybe Data -> LineChart.Config Data Msg
    chartConfig hovered =
      { ...
      , line = Line.hoverOne hovered
      , ...
      }


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Line/Example2.elm)._

-}
hoverOne : Maybe data -> Config data
hoverOne hovered =
  custom <| \data ->
    if List.any (Just >> (==) hovered) data then
      style 3 identity
    else
      style 1 identity


{-| Edit as style of a line based on its data.

    lineConfig : Maybe Data -> Line.Config Data
    lineConfig maybeHovered =
      Line.custom (toLineStyle maybeHovered)


    toLineStyle : Maybe Data -> List Data -> Line.Style
    toLineStyle maybeHovered lineData =
      case maybeHovered of
        Nothing -> -- No line is hovered
          Line.style 1 identity

        Just hovered -> -- Some line is hovered
          if List.any ((==) hovered) lineData then
            -- It is this one, so make it pop!
            Line.style 2 (Manipulate.darken 0.1)
          else
            -- It is not this one, so hide it a bit
            Line.style 1 (Manipulate.lighten 0.35)


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Line/Example3.elm)._

-}
custom : (List data -> Style) -> Config data
custom =
  Line.custom



-- STYLE


{-| -}
type alias Style =
  Line.Style


{-| Pass the width of the line and a function transforming the line's color.

    vanilla : Line.Style
    vanilla =
      Line.style 1 identity

    emphasize : Line.Style
    emphasize =
      Line.style 2 (Manipulate.darken 0.15)

    hide : Line.Style
    hide =
      Line.style 1 (Manipulate.lighten 0.15)

    blacken : Line.Style
    blacken =
      Line.style 2 (\_ -> Colors.black)


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Line/Example4.elm)._

-}
style : Float -> (Color.Color -> Color.Color) -> Style
style =
  Line.style
