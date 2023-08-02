import sdl2
import config

type Cell* = object
    height: int
    width: int
    xpos: cint
    ypos: cint
    filled*: bool

proc createCell*(height: int, width: int, xpos: cint, ypos: cint): Cell =
    Cell(height: height, width: width, xpos: xpos, ypos: ypos, filled: false)




proc renderOutline*(cell: Cell, renderer: RendererPtr) =
    setDrawColor(renderer, WHITE)
    var rect = rect(cell.xpos, cell.ypos, cint(cell.width), cint(cell.height))
    drawRect(renderer, rect)

proc renderFill*(cell: Cell, renderer: RendererPtr, color: Color) =
    setDrawColor(renderer, color)
    var rect = rect(cell.xpos, cell.ypos, cint(cell.width), cint(cell.height))
    fillRect(renderer, rect)


