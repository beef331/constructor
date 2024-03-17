import std/[unittest, sequtils]
import constructor/constructor

suite"Constructor test":
  type
    User = object
      name: string
      age: int
      lastOnline: float

  proc initUser(name: string, age: int): User {.constr.}

  proc init(T: typedesc[User], name: string, age: int): User {.constr.} =
    result.lastOnline = 30f


  check initUser("hello", 10) == User(name: "hello", lastOnline: 0f, age: 10)
  check User.init("hello", 30) == User(name: "hello", lastOnline: 30f, age: 30)


  type Field = object
    opts*: seq[(string, string)]
    name*: string
  proc initField(name = "", options: openarray[(string, string)]): Field {.constr.} =
    result.opts = toSeq(options)
  check initField("beef", {"Hi": "Mr. Beef"}) == Field(opts: @{"Hi": "Mr. Beef"}, name: "beef")

  type Generic[T] = object
    val: T
    bleh: int

  proc init[Y](_: typedesc[Generic], val: Y, bleh = 30): Generic[Y] {.constr.} = discard

  assert Generic.init(3) == Generic[int](val: 3, bleh: 30)
  assert Generic.init(3d) == Generic[float](val: 3d, bleh: 30)
