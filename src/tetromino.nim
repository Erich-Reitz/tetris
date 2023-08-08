import random
import std/options
import std/sequtils
import std/sugar


import sdl2

import config
import point

type TetrominoType = enum
    STRAIGHT,
    SQUARE,
    T,
    L,
    SKEW



type Tetromino* = object
    t_type*: TetrominoType
    shape*: seq[seq[int]]
    btmLeft*: point.Point


proc deepCopy*(tetromino: Tetromino): Tetromino =
    var newShape: seq[seq[int]] = @[]
    for row in tetromino.shape:
        newShape.add(row)

    return Tetromino(
        t_type: tetromino.t_type,
        shape: newShape,
        btmLeft: tetromino.btmLeft
    )


func tetrominoColor(t: TetrominoType): Color =
    case t
    of STRAIGHT:
        return CYAN
    of SQUARE:
        return YELLOW
    of T:
        return PURPLE
    of L:
        return ORANGE
    of SKEW:
        return GREEN

func tetrominoColor*(t: Tetromino): Color =
    tetrominoColor(t.t_type)

func createSingleTetrominoFromExisting(t: Tetromino,
        point: point.Point): Tetromino =
    let singleBlock: seq[seq[int]] = @[ @[1]]

    Tetromino(t_type: t.t_type, shape: singleBlock, btmLeft: point)

proc createRandomTetromino*(): Tetromino =
    randomize()
    let tetroType = TetrominoType(rand(ord(SKEW)))

    var shape: seq[seq[int]]

    case tetroType
    of STRAIGHT:
        shape = @[@[0, 0, 0, 0], @[1, 1, 1, 1], @[0, 0, 0, 0], @[0, 0, 0, 0]]
    of SQUARE:
        shape = @[@[1, 1], @[1, 1]]
    of T:
        shape = @[@[0, 1, 0], @[1, 1, 1], @[0, 0, 0]]
    of L:
        shape = @[@[1, 0], @[1, 0], @[1, 1]]
    of SKEW:
        shape = @[@[0, 1, 1], @[1, 1, 0], @[0, 0, 0]]

    Tetromino(t_type: tetroType, shape: shape,
            btmLeft: point.Point(row: 2, col: 0))

func getPositionsOfTetromino*(tetromino: Tetromino): seq[point.Point] =
    var positions: seq[point.Point]
    for i in 0 ..< tetromino.shape.len:
        for j in 0 ..< tetromino.shape[i].len:
            if tetromino.shape[i][j] == 1:
                let row = tetromino.btmLeft.row - i
                let col = tetromino.btmLeft.col + j

                positions.add(point.Point(row: row, col: col))
    return positions


func splitTetrominoIntoSingleBlocks*(tetromino: Tetromino): seq[Tetromino] =
    var blocks: seq[Tetromino] = @[]
    let positions = getPositionsOfTetromino(tetromino)
    for pos in positions:
        let singleBlock = createSingleTetrominoFromExisting(tetromino, pos)
        blocks.add(singleBlock)

    return blocks


func renderablePositions*(tetromino: Tetromino): seq[point.Point] =
    let allPositions = getPositionsOfTetromino(tetromino)

    return collect(newSeq):
        for pos in allPositions:
            if isSome(withinBoard(pos)):
                get(withinBoard(pos))



func allPositionsWithinBoundsExceptUpper*(tetromino: Tetromino): bool =
    let positions = getPositionsOfTetromino(tetromino)
    for pos in positions:
        if pos.row >= MapRows or pos.col < 0 or pos.col >= MapCols:
            return false
    return true

func rightMostPosition(tetromino: Tetromino): int =
    var maxColIndex = -1
    for i in 0 ..< tetromino.shape.len:
        for j in 0 ..< tetromino.shape[i].len:
            if tetromino.shape[i][j] == 1 and j > maxColIndex:
                maxColIndex = j
    return tetromino.btmLeft.col + maxColIndex


func leftMostPosition*(tetromino: Tetromino): int =
    var minColIndex = tetromino.shape[0].len
    for i in 0 ..< tetromino.shape.len:
        for j in 0 ..< tetromino.shape[i].len:
            if tetromino.shape[i][j] == 1 and j < minColIndex:
                minColIndex = j
    return tetromino.btmLeft.col + minColIndex


func bottomMostPosition(tetromino: Tetromino): int =
    var maxRowIndex = -1
    for i in 0 ..< tetromino.shape.len:
        for j in 0 ..< tetromino.shape[i].len:
            if tetromino.shape[i][j] == 1 and i > maxRowIndex:
                maxRowIndex = i
    return tetromino.btmLeft.row - maxRowIndex


func moveRight*(tetromino: var Tetromino) =
    if rightMostPosition(tetromino) + 1 < MapCols:
        tetromino.btmLeft.col += 1


func moveLeft*(tetromino: var Tetromino) =
    if leftMostPosition(tetromino) - 1 >= 0:
        tetromino.btmLeft.col -= 1

func moveDown*(tetromino: var Tetromino) =
    if bottomMostPosition(tetromino) + 1 < MapRows:
        tetromino.btmLeft.row += 1

proc rotateRight*(tetromino: var Tetromino) =
    var newShape: seq[seq[int]] = newSeqWith(tetromino.shape[0].len, newSeq[
            int](tetromino.shape.len))

    for i in 0 ..< tetromino.shape.len:
        for j in 0 ..< tetromino.shape[i].len:
            newShape[j][tetromino.shape.len - i - 1] = tetromino.shape[i][j]

    tetromino.shape = newShape
