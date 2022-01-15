# Constructor
A collection of useful macros, mostly related to the construction of objects.


Simply use Nimble to install, then
## Constructor
`constructor` works similarly to `construct` but does it with your own procedures so you can match your preferred method.
You can pass other parameters to the object constructor by having a variable named the same in the main scope of the procedure.
Aside from that it's practically like writting your own init procedure.
```nim
import constructor/constructor
type
  User = object
    name: string
    age: int
    lastOnline: float

proc initUser*(name: string, age: int): User {.constr.} # Can use like a forward declare.

proc init(T: typedesc[User], name: string, age: int): User {.constr.} =
  result.lastOnline = 30f


assert initUser("hello", 10) == User(name: "hello", lastOnline: 0f, age: 10)
assert User.init("hello", 30) == User(name: "hello", lastOnline: 30f, age: 30)

```


## Defaults
`defaults` macro which allows you to easily generate a constructor with default values.

```nim
import constructor/defaults
type Thingy{.defaults.} = object
  a: float = 10 # Can do it this way
  b = "Hmm" # Can also do it this way
  c = 10
implDefaults(Thingy) # Required to embed the procedure
assert initThingy() == Thingy(a: 10, b: "Hmm", c: 10)
```
