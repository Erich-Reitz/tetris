import std/options
import std/sequtils

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
    for row in 0 ..< MapRows:
        for col in 0 ..< MapCols:
            let cellX = topLeftX + col * cellWidth
            let cellY = topLeftY + row * cellHeight
            result.playfield[row][col] = createCell(cellHeight, cellWidth,
                    cellX.cint, cellY.cint)

    result.fallingBlock = none(Tetromino)

proc cellAt(map: Map, point: point.Point): Cell =
    map.playfield[point.row][point.col]


proc renderTetromino(map: Map, tetromino: Tetromino, renderer: RendererPtr) =
    let color = tetrominoColor(tetromino)
    let cellsToColor = renderablePositions(tetromino)
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
    let blocks = splitTetrominoIntoSingleBlocks(tetromino)
    for tetromino in blocks:
        add(map.landedBlocks, tetromino)
        # should only be one position; use loop anyway
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


proc clearRow(map: var Map, row: int) =

    for r in countdown(row, 1):
        for c in 0..MapCols - 1:
            map.playfield[r][c].filled = map.playfield[r-1][c].filled

    for col in 0..MapCols - 1:
        map.playfield[0][col].filled = false




    let cellsNotInClearedrow = map.landedBlocks.filterIt(it.btmLeft.row != row)

    var newLandedBlocks: seq[Tetromino] = @[]
    for tetromino in cellsNotInClearedrow:
        let positions = getPositionsOfTetromino(tetromino)
        var shouldMoveDown = false
        for pos in positions:
            if pos.row < row:
                shouldMoveDown = true
                break


        var newTetromino = deepCopy(tetromino)
        if shouldMoveDown:
            newTetromino.btmLeft.row += 1

        newLandedBlocks.add(newTetromino)

    map.landedBlocks = newLandedBlocks




func rowIsFilled(map: Map, row: int): bool =
    for col in 0 ..< MapCols:
        if not map.playfield[row][col].filled:
            return false
    return true


proc update*(map: var Map) =
    if not map.fallingBlock.isSome:
        let newTet = createRandomTetromino()
        map.fallingBlock = some(newTet)
    else:
        var falling = map.fallingBlock.get()

        if canMoveTetromino(map, falling, toDelta(Down)) == false:
            placeTetromino(map, falling)
        else:
            moveDown(falling)
            map.fallingBlock = some(falling)


    for i in countdown(MapRows - 1, 0):
        if rowIsFilled(map, i):
            clearRow(map, i)







