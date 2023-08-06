import std/options

import config


type Point* = object
  row*: int
  col*: int


func withinBoard*(point: Point): Option[Point] =
  let row = point.row
  let col = point.col
  if row < 0 or row >= MapRows or col < 0 or col >= MapCols:
    return none(Point)

  return some(Point(row: row, col: col))

func positionUnder*(point: Point): Option[Point] =
  let newPoint = Point(row: point.row + 1, col: point.col)

  withinBoard(newPoint)

func applyDelta*(point: Point, delta: Point): Point =
  Point(row: point.row + delta.row, col: point.col + delta.col)

