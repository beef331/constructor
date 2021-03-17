import constructor/defaults

type Thingy {.defaults.} = object # Tests the basic operation
  a: float = 100
  b: string = "Hello world"
implDefaults(Thingy)
assert initThingy() == Thingy(a: 100f, b: "Hello world")

type Thing2 {.defaults.} = object
  a = @[initThingy(), initThingy()]
  b = "Good News Everyone"
  c = 3.1415

implDefaults(Thing2)
assert initThing2() == Thing2(a: @[initThingy(), initThingy()], b: "Good News Everyone", c: 3.1415)

type RefThing {.defaults.} = ref object
  a = 100
  b* = "Hmmmm"
  c*: float
RefThing.implDefaults
assert newRefThing()[] == RefThing(a: 100, b: "Hmmmm")[]
