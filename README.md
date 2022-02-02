# Constructor

A collection of useful macros, mostly related to the construction of objects.

## Installation

`nimble install constructor`

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

You can use the `defaults` and `implDefaults` macros, which allow you to easily generate a constructor with default values.
If your type is a value-allocated type the constructor is `init<YOUR TYPE>()` (e.g. `initThingy()`).
If your type is a heap-allocated object the constructor is `new<YOUR TYPE>()` (e.g. `newThingy()`).

```nim
import constructor/defaults
type Thingy{.defaults.} = object
  a: float = 10 # Can do it this way
  b = "Hmm" # Can also do it this way
  c = 10
implDefaults(Thingy) # Required to embed the procedure
assert initThingy() == Thingy(a: 10, b: "Hmm", c: 10)
```

### Modifying implDefaults

You can pass `implDefaults` a list of `DefaultFlag` flags to modify its behaviour.
Currently implemented flags are:

-   `defExported` - Adds a '\*' to the proc so that it is exported (e.g. generates `newThingy\*()` instead of `newThingy()`)
-   `defTypeConstr` - Changes the constructor signature for heap-allocated from `newThingy()` to `new(_: typedesc[Thingy])`. Use only with heap-allocated objects !

```nim
import constructor/defaults
type Thingy{.defaults.} = ref object of RootObj
  a: float = 10 # Can do it this way
  b = "Hmm" # Can also do it this way
  c = 10

implDefaults(Thingy, {DefaultFlag.defExported, DefaultFlag.defTypeConstr})
assert new(Thingy) == Thingy(a: 10, b: "Hmm", c: 10)
```
