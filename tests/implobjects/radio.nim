type Radio* = ref object of RootRef
    x*, y*, radius*: int

proc onClick*(r: Radio): string = "You clicked a radio!"
proc isHovered*(r: Radio, x, y: int): bool = abs(r.x - x) + abs(r.y - y) < r.radius
proc returnT*[T](r: Radio, a: T): T = a * 2