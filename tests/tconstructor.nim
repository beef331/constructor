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
