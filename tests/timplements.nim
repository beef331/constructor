include constructor/implements
import implobjects/[button, radio]

type
  Clickable = concept
    proc onClick(i: Self): string
  Hoverable = concept
    proc isHovered(i: Self, x, y: int): bool

let 
  col: seq[RootRef] = @[
    Button(x: 10, y: 10, w: 3, h: 3),
    Radio(x: 0, y: 0, radius: 30)]
  response = ["You clicked a button!", "You clicked a radio!"] 

for i, x in col:
  x.implements Hoverable, Clickable:
    if x.isHovered(11, 11):
        assert x.onClick == response[i]