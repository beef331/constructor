import constructor/constructor
type
  User = object
    name: string
    age: int
    lastOnline: float

proc initUser*(name: string, age: int): User {.constr.}

proc init(T: typedesc[User], name: string, age: int): User {.constr.} =
  result.lastOnline = 30f


assert initUser("hello", 10) == User(name: "hello", lastOnline: 0f, age: 10)
assert User.init("hello", 30) == User(name: "hello", lastOnline: 30f, age: 30)


import sequtils
type Field* = object
  opts*: seq[(string, string)]
  name*: string
proc initField*(name = "", options: openarray[(string, string)]): Field {.constr.} =
  result.opts = toSeq(options)
assert initField("beef", {"Hi": "Mr. Beef"}) == Field(opts: @{"Hi": "Mr. Beef"}, name: "beef")
