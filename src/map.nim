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



# if can move: should take a Point that represents a delta
proc canMoveTetromino(map: Map, tetromino: Tetromino,
        delta: point.Point): bool =

    let bottomLeft = tetromino.btmLeft
    for i in 0 ..< tetromino.shape.len:
        for j in 0 ..< tetromino.shape[i].len:
            if tetromino.shape[i][j] == 0:
                continue

            let pos = point.Point(row: bottomLeft.row - i,
                    col: bottomLeft.col + j)

            # if point is above board, don't check
            if pos.row < 0:
                continue

            let newPos = withinBoard(applyDelta(pos, delta))
            if isNone(newPos) or cellAt(map, get(newPos)).filled:
                return false

    return true





proc addLandedTetromino(map: var Map, tetromino: Tetromino) =
    add(map.landedBlocks, tetromino)
    for pos in getPositionsOfTetromino(tetromino):
        map.playfield[pos.row][pos.col].filled = true



func placeTetromino(map: var Map, tetromino: Tetromino) =
    addLandedTetromino(map, tetromino)
    map.fallingBlock = none(Tetromino)


proc canRotateTetromino(map: var Map, tetromino: Tetromino): bool =
    var temp = deepCopy(tetromino)
    rotateRight(temp)
    allPositionsWithinBoundsExceptUpper(temp)



proc handleInput*(map: var Map, inputs: var array[Input, int]) =
    if isNone(map.fallingBlock):
        return
    var falling = map.fallingBlock.get()

    while inputs[Up] > 0:
        inputs[Up] = inputs[Up] - 1
        if canRotateTetromino(map, falling):
            rotateRight(falling)

    while inputs[Right] > 0:
        inputs[Right] = inputs[Right] - 1
        if canMoveTetromino(map, falling, toDelta(Right)):
            moveRight(falling)

    while inputs[Left] > 0:
        inputs[Left] = inputs[Left] - 1
        if canMoveTetromino(map, falling, toDelta(Left)):
            moveLeft(falling)

    var setRemoved = false
    while inputs[Down] > 0:
        inputs[Down] = inputs[Down] - 1
        if canMoveTetromino(map, falling, toDelta(Down)) == true:
            moveDown(falling)
        if canMoveTetromino(map, falling, toDelta(Down)) == false:
            placeTetromino(map, falling)
            inputs[Down] = 0
            setRemoved = true



    if setRemoved == false:
        map.fallingBlock = some(falling)




proc update*(map: var Map) =
    if not map.fallingBlock.isSome:
        let newTet = createRandomTetromino()
        map.fallingBlock = some(newTet)
    else:
        var falling = map.fallingBlock.get()
        moveDown(falling)
        let deltaDown = point.Point(row: 1, col: 0)
        if canMoveTetromino(map, falling, deltaDown) == false:
            placeTetromino(map, falling)
        else:
            map.fallingBlock = some(falling)





