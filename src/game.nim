import std/options

import sdl2

import config
import input
import map
import window



type Game* = object
    window*: Window
    map: Map
    inputs: array[Input, int]
    lastDropTime: Option[uint32]
    dropDelay: uint32



proc createGame*(): Game =
    let window = newWindow("Tetris", GAME_WIDTH, GAME_HEIGHT)
    let map = createMap(20, 20)
    Game(window: window, map: map, lastDropTime: none(uint32), dropDelay: 800)

proc handleInput*(game: var Game) =
    handleInput(game.window, game.inputs)
    handleInput(game.map, game.inputs)

func shouldDrop(game: Game): bool =
    isNone(game.lastDropTime) or getTicks() - game.lastDropTime.get() > game.dropDelay

proc update*(game: var Game) =
    update(game.window)
    if shouldDrop(game):
        update(game.map)
        game.lastDropTime = some(getTicks())

func getRenderer(game: Game): RendererPtr = game.window.renderer

proc render*(game: Game) =
    beginDraw(game.window)
    render(game.map, getRenderer(game))
    endDraw(game.window)




func done*(game: Game): bool =
    done(game.window)
