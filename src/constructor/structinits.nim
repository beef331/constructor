import std/[macros, genasts, strutils]


var paramCounter {.compileTime.} = 0

macro unpack(args: varargs[typed]): untyped =
  # Retrieve the value inside a varargs of 'index'
  result = args[paramCounter]

macro init*(typ: typedesc[object], args: varargs[typed]): untyped =
  ## init constructor that uses order of args to assign to type's fields.
  ## Presently only works for non object variants
  runnableExamples:
    type MyType = object
      x, y: int
      z: string
    assert MyType.init(10, 20, "hello") == MyType(x: 10, y: 20, z: "hello")

  let
    i = gensym(nskVar, "i")
    unpackCall = newCall(bindSym"unpack")
  for arg in args:
    unpackCall.add arg

  result = genast(typ, args, i, unpackCall, paramCounter = bindSym"paramCounter"):
    var res: typ
    static: paramCounter = 0
    for name, field in res.fieldPairs: # Perhaps use disruptek's assume here
      when not compiles((let a: typeof(field) = unpackCall)):
          {.error: "Field '$#' (position $#) is of type '$#', but got a value type of '$#'." % [name, $paramCounter, $typeof(field), $typeof(unpackCall)].}
      field = unpackCall
      static: inc paramCounter
    res

macro new*(typ: typedesc[ref object or object], args: varargs[typed]): untyped =
  ## Same as init but heap allocates instead, accepts `ref object` or `object` making `object` into a `ref`.
  ## Presently only works for non object variants
  runnableExamples:
    type MyType = object
      x, y: int
      z: string
    assert MyType.new(10, 20, "hello")[] == (ref MyType)(x: 10, y: 20, z: "hello")[]
  let
    i = gensym(nskVar, "i")
    unpackCall = newCall(bindSym"unpack")
  for arg in args:
    unpackCall.add arg
  unpackCall.add i

  result = genast(typ, args, i, unpackCall, paramCounter = bindSym"paramCounter"):
    var res = system.new(typ)
    static: paramCounter = 0
    for name, field in res[].fieldPairs: # Perhaps use disruptek's assume here
      when not compiles((let a: typeof(field) = unpackCall)):
        {.error: "Field '$#' (position $#) is of type '$#', but got a value type of '$#'." % [name, $paramCounter, $typeof(field), $typeof(unpackCall)].}
      field = unpackCall
      static: inc paramCounter
    res
