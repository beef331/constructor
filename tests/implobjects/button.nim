type Button* = ref object of RootRef
    x*,y*,w*,h*: int

proc onClick*(b: Button): string = "You clicked a button!"
proc isHovered*(b: Button, x, y: int): bool = x > b.x and x < b.x + b.w and y > b.y and y < b.y + b.h