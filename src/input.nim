import sdl2

type Input*{.pure.} = enum
  Left,
  Right,
  None

func toInput*(key: Scancode): Input =
  case key
  of SDL_SCANCODE_LEFT: Input.Left
  of SDL_SCANCODE_RIGHT: Input.Right
  else: Input.None
