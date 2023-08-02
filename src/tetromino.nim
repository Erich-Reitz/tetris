import random
import std/sequtils

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
            btmLeft: point.Point(row: 0, col: 0))

func getPositionsOfTetromino*(tetromino: Tetromino): seq[point.Point] =
    var positions: seq[point.Point]
    for i in 0 ..< tetromino.shape.len:
        for j in 0 ..< tetromino.shape[i].len:
            if tetromino.shape[i][j] == 1:
                let row = tetromino.btmLeft.row - i
                let col = tetromino.btmLeft.col + j
                if row >= 0 and row < MapRows and col >= 0 and col < MapCols:
                    positions.add(point.Point(row: row, col: col))
    return positions

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


func moveRight*(tetromino: var Tetromino) =
    if rightMostPosition(tetromino) + 1 < MapCols:
        tetromino.btmLeft.col += 1


func moveLeft*(tetromino: var Tetromino) =
    if leftMostPosition(tetromino) - 1 >= 0:
        tetromino.btmLeft.col -= 1

proc rotateRight*(tetromino: var Tetromino) =
    var newShape: seq[seq[int]] = newSeqWith(tetromino.shape[0].len, newSeq[
            int](tetromino.shape.len))

    for i in 0 ..< tetromino.shape.len:
        for j in 0 ..< tetromino.shape[i].len:
            newShape[j][tetromino.shape.len - i - 1] = tetromino.shape[i][j]

    tetromino.shape = newShape