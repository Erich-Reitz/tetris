import sdl2
import point

type Input*{.pure.} = enum
  Left,
  Right,
  Down,
  Up,
  None


func toDelta*(input: Input): point.Point =
  case input
  of Left: point.Point(row: 0, col: -1)
  of Right: point.Point(row: 0, col: 1)
  of Down: point.Point(row: 1, col: 0)
  else: point.Point(row: 0, col: 0)

func toInput*(key: Scancode): Input =
  case key
  of SDL_SCANCODE_LEFT: Input.Left
  of SDL_SCANCODE_RIGHT: Input.Right
  of SDL_SCANCODE_DOWN: Input.Down
  of SDL_SCANCODE_UP: Input.Up
  else: Input.None
