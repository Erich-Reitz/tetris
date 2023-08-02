import std/options

import config


type Point* = object
  row*: int
  col*: int

func positionUnder*(point: Point): Option[Point] =
  let row = point.row + 1
  let col = point.col

  if row < 0 or row >= MapRows:
    return none(Point)

  return some(Point(row: row, col: col))
