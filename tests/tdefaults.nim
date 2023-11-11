import std/unittest
import constructor/defaults

type Thingy {.defaults: {}.} = object # Tests the basic operation
  a: float = 100
  b: string = "Hello world"

check initThingy() == Thingy(a: 100f, b: "Hello world")

type Thing2 {.defaults: {}.} = object
  a = @[initThingy(), initThingy()]
  b = "Good News Everyone"
  c = 3.1415

check initThing2() == Thing2(a: @[initThingy(), initThingy()], b: "Good News Everyone", c: 3.1415)

const
  SillyA = 1
type RefThing {.defaults: {defBothConstr}.} = ref object
  a = 100
  b* = "Hmmmm"
  c* = SillyA

check newRefThing()[] == RefThing(a: 100, b: "Hmmmm", c: SillyA)[]
check RefThing.new[] == RefThing(a: 100, b: "Hmmmm", c: SillyA)[]


type
  A = ref object of RootObj
  B {.defaults: {}.} = ref object of A
    a = 100
    b = 300

type
  C {.defaults: {}.} = object
    a = 300
    b: int

check initC() == C(a: 300)
