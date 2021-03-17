include constructor/implements
import implobjects/[button, radio]

type
  Clickable = concept
    proc onClick(i: Self): string
  Hoverable = concept
    proc isHovered(i: Self, x, y: int): bool
  Generic = concept
    proc returnT[T](s: Self, a: T): T
  FailObject = object # Should fail the match due to not implementing `returnT` and then fail due to not being inherited from RootRef


proc isHovered(fo: FailObject): bool = true
proc onClick*(b: FailObject): string = "You clicked a button!"


let 
  col: seq[RootRef] = @[
    Button(x: 10, y: 10, w: 3, h: 3),
    Radio(x: 0, y: 0, radius: 30)]
  strResponse = ["You clicked a button!", "You clicked a radio!"] 
  intResponse = [100, 200]

for i, x in col:
  x.implements Hoverable, Clickable, Generic:
    if x.isHovered(11, 11):
        assert x.onClick == strResponse[i]
    assert x.returnT(100) == intResponse[i]
