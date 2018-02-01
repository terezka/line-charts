module LineChart.Line exposing
  ( Config, default
  , wider, hoverOne
  , custom
  , Style, style
  )

{-|

# Quick start
@docs Config, default, wider, hoverOne

# Customization
@docs custom

## Styles
@docs Style, style

-}

import Internal.Line as Line
import Color



{-| -}
type alias Config data =
  Line.Config data


{-| Makes a 1px wide line. Use in the `LineChart.Config` passed to `viewCustom`.

    chartConfig : LineChart.Config Data msg
    chartConfig =
      { ...
      , line = Line.default
      , ...
      }

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

_See full example [here](https://ellie-app.com/ctGj27yVCa1/1)._

-}
wider : Float -> Config data
wider =
  Line.wider


{-| Makes the line, to which the data in the first argument belongs, wider!

    chartConfig : Model -> LineChart.Config Data Msg
    chartConfig model =
      { ...
      , line = Line.hoverOne model.hovering
      , ...
      }

_See full example [here](https://ellie-app.com/ck5yVJkqCa1/1)._

-}
hoverOne : Maybe data -> Config data
hoverOne hovered =
  custom <| \data ->
    if List.any (Just >> (==) hovered) data then
      style 2 identity
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
          if List.any ((==) hovered) data then
            -- It is this one, so make it pop!
            Line.style 2 (Color.Extra.Manipulate.darken 0.15)
          else
            -- It is not this one, so hide it a bit
            Line.style 1 (Color.Extra.Manipulate.lighten 0.15)


_See full example [here](https://ellie-app.com/crf2pvCmta1/1)._

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

    emphasize : List.Style
    emphasize =
      Line.style 2 (Color.Extra.Manipulate.darken 0.15)

    hide : List.Style
    hide =
      Line.style 1 (Color.Extra.Manipulate.lighten 0.15)

    blacken : List.Style
    blacken =
      Line.style 2 (\_ -> Color.black)

_See full example [here](https://ellie-app.com/cqR72MhvZa1/1)._

-}
style : Float -> (Color.Color -> Color.Color) -> Style
style =
  Line.style
