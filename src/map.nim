import std/options

import sdl2

import cell
import config
import input
import point
import tetromino




type Map* = object
    playfield: array[MapRows, array[MapCols, Cell]]
    fallingBlock: Option[Tetromino]
    landedBlocks: seq[Tetromino]



proc createMap*(cellWidth: cint, cellHeight: cint): Map =
    let playfieldWidth = cellWidth * 10
    let playfieldHeight = cellHeight * 24

    let topLeftX = (GAME_WIDTH - playfieldWidth) div 2
    let topLeftY = (GAME_HEIGHT - playfieldHeight) div 2
    for row in 0 ..< 24:
        for col in 0 ..< 10:
            let cellX = topLeftX + col * cellWidth
            let cellY = topLeftY + row * cellHeight
            result.playfield[row][col] = createCell(cellHeight, cellWidth,
                    cellX.cint, cellY.cint)

    result.fallingBlock = none(Tetromino)

proc cellAt(map: Map, point: point.Point): Cell =
    map.playfield[point.row][point.col]


proc renderTetromino(map: Map, tetromino: Tetromino, renderer: RendererPtr) =
    let color = tetrominoColor(tetromino)
    let cellsToColor = getPositionsOfTetromino(tetromino)
    for cellToColor in cellsToColor:
        renderFill(cellAt(map, cellToColor), renderer, color)


proc render*(map: Map, renderer: RendererPtr) =

    for row in map.playfield:
        for cell in row:
            renderOutline(cell, renderer)

    if map.fallingBlock.isSome:
        let falling = get(map.fallingBlock)
        renderTetromino(map, falling, renderer)

    for tetromino in map.landedBlocks:
        renderTetromino(map, tetromino, renderer)




proc shouldStopTetromino(map: Map, tetromino: Tetromino): bool =
    let bottomLeft = tetromino.btmLeft
    for i in 0 ..< tetromino.shape.len:
        for j in 0 ..< tetromino.shape[i].len:
            if tetromino.shape[i][j] == 0:
                continue

            let pos = point.Point(row: bottomLeft.row - i,
                    col: bottomLeft.col + j)
            let posUnder = positionUnder(pos)
            if isNone(posUnder) or cellAt(map, get(posUnder)).filled:
                return true

    return false


proc addLandedTetromino(map: var Map, tetromino: Tetromino) =
    add(map.landedBlocks, tetromino)
    for pos in getPositionsOfTetromino(tetromino):
        map.playfield[pos.row][pos.col].filled = true


proc handleInput*(map: var Map, inputs: var array[Input, int]) =
    while inputs[Right] > 0 and isSome(map.fallingBlock):
        inputs[Right] = inputs[Right] - 1
        moveRight(map.fallingBlock.get())
    while inputs[Left] > 0 and isSome(map.fallingBlock):
        inputs[Left] = inputs[Left] - 1
        moveLeft(map.fallingBlock.get())


proc update*(map: var Map) =
    if not map.fallingBlock.isSome:
        let newTet = createRandomTetromino()
        map.fallingBlock = some(newTet)
    else:
        var falling = map.fallingBlock.get()
        falling.btmLeft.row += 1
        if shouldStopTetromino(map, falling):
            # place tetro
            addLandedTetromino(map, falling)
            map.fallingBlock = none(Tetromino)
        else:
            map.fallingBlock = some(falling)




