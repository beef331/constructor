import constructor/constructor
type
  User = object
    name: string
    age: int
    lastOnline: float

proc initUser*(name: string, age: int): User {.constr.} =
  let lastOnline = 30f

proc init(T: typedesc[User], name: string, age: int) {.constr.} =
  let lastOnline = 30f


assert initUser("hello", 10) == User(name: "hello", lastOnline: 30f, age: 10)
echo User.init("hello", 30) == User(name: "hello", lastOnline: 30f, age: 30)