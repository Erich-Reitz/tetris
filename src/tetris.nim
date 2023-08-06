## Bare-bones SDL2 example
import sdl2

import game
discard sdl2.init(INIT_EVERYTHING)

const DesiredFrameRate = 30
let FrameDelay: uint32 = uint32(1000 div DesiredFrameRate)


var lastUpdate = getTicks()

proc main() =
  var game = createGame()
  while done(game) == false:
    handleInput(game)

    let frameTime = getTicks() - lastUpdate
    if frameTime < FrameDelay:
      delay(FrameDelay - frameTime)

    update(game)
    render(game)

    lastUpdate = getTicks()


when isMainModule:
  main()
