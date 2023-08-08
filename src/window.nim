import sdl2
import config
import input

type Window* = object
    window*: WindowPtr
    renderer*: RendererPtr
    isDone*: bool

proc newWindow*(title: string, width: cint, height: cint): Window =
    let window = createWindow(title, SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED, width, height, SDL_WINDOW_SHOWN);
    let renderer = createRenderer(window, -1, Renderer_Accelerated or
            Renderer_PresentVsync or Renderer_TargetTexture)

    Window(window: window, renderer: renderer, isDone: false)


proc beginDraw*(window: Window) =
    clear(window.renderer)
proc endDraw*(window: Window) =
    setDrawColor(window.renderer, BLACK)
    present(window.renderer)

proc handleInput*(window: var Window, inputs: var array[Input, int]) =
    var evt = sdl2.defaultEvent
    while pollEvent(evt):
        if evt.kind == QuitEvent:
            window.isDone = true
            break
        if evt.kind == KeyDown:
            let input = evt.key.keysym.scancode.toInput

            if inputs[input] < 5:
                inputs[input] += 1



proc done*(window: Window): bool =
    window.isDone


proc update*(window: var Window) =
    discard

