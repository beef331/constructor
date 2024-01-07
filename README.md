# Constructor

A collection of useful macros, mostly related to the construction of objects.

## Installation

`nimble install constructor`

## Constructor

`constr` works on procedures so you can match your preferred init method.
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

You can use the `defaults` macro, which allows you to easily generate a constructor with default values.
If your type is a value type the constructor is `init<YOUR TYPE>()` (e.g. `initThingy()`).
If your type is a reference object the constructor is `new<YOUR TYPE>()` (e.g. `newThingy()`).

```nim
import constructor/defaults

type Thingy {.defaults: {}.} = object
  a: float = 10 # Can do it this way
  b = "Hmm" # Can also do it this way
  c = 10

assert initThingy() == Thingy(a: 10, b: "Hmm", c: 10)
```

### Flags

You can modify the generation of the defaults procedure by passing a set of `DefaultFlag` flags.
Currently implemented flags are:

-   `defExported` - Adds a '\*' to the proc so that it is exported (e.g. generates `newThingy\*()` instead of `newThingy()`)
-   `defTypeConstr` - Changes the constructor signature for references from `newThingy()` to `new(_: typedesc Thingy)` and for value types from `initThingy()` to `init(_: typedesc[Thingy])`
-   `defBothConstr` - Includes both `initThingy()`/`newThingy` and `new(_: typedesc[Thingy])`/`init(_: typedesc[Thingy])`

```nim
import constructor/defaults

type Thingy {.defaults: {defExported, defTypeConstr}.} = ref object of RootObj
  a: float = 10 # Can do it this way
  b = "Hmm" # Can also do it this way
  c = 10

assert new(Thingy)[] == Thingy(a: 10, b: "Hmm", c: 10)[]

type OtherThingy {.defaults: {defBothConstr}.} = object
  d = "lula"

assert init(OtherThingy) == OtherThingy(d: "lula")
assert initOtherThingy() == OtherThingy(d: "lula")
```


## Struct Intialisers
A variant of positional initialisers exists inside `constructor/structinits`.
There are type checks to ensure safety and it works on `typedesc`s that are not object variants.

```nim
import constructor/structinits

type
  MyType = object
    x, y: int
    z: string
  MyRef = ref MyType
  MyGen[T] = object
    x: int

assert MyType.init(10, 20, "hello") == MyType(x: 10, y: 20, z: "hello")
assert MyType.new(10, 20, "hello")[] == (ref MyType)(x: 10, y: 20, z: "hello")[]
assert MyRef.new(10, 20, "Hello")[] == MyRef(x: 10, y: 20, z: "Hello")[]
assert MyGen[int].init(100) == MyGen[int](x: 100)
assert MyGen[int].new(100)[] == (ref MyGen[int])(x: 100)[]
```
