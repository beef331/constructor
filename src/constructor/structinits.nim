import std/[macros, genasts, strutils, intsets]


macro unpack(count: static int, args: varargs[typed]): untyped =
  # Retrieve the value inside a varargs of 'index'
  result = args[count]

macro init*(typ: typedesc[object], args: varargs[untyped]): untyped =
  ## init constructor that uses order of args to assign to type's fields.
  ## Presently only works for non object variants
  runnableExamples:
    type MyType = object
      x, y: int
      z: string
    assert MyType.init(10, 20, "hello") == MyType(x: 10, y: 20, z: "hello")

  let
    i = gensym(nskVar, "i")
    paramCounter = gensym(nskVar, "paramCounter")
    unpackCall = newCall(bindSym"unpack", paramCounter)
    res = genSym(nskVar, "result")

  var
    addins = newStmtList()
    lastVal = -1

  for i, arg in args:
    if arg.kind == nnkExprEqExpr:
      let left =
        if arg[0].kind == nnkBracketExpr:
          let bracketExpr = arg[0].copyNimTree
          bracketExpr[0] = nnkDotExpr.newTree(res, bracketExpr[0])
          bracketExpr
        else:
          arg[0]

      addins.add:
        nnkAsgn.newTree(
          left,
          arg[1]
        )

      if lastVal < 0:
        lastVal = i

    else:
      if lastVal >= 0:
        error("Provided positional setter, following expression setters ambiguous what to do.", arg)
      unpackCall.add arg

  if addins.len == 0:
    lastVal = args.len

  result = genast(res, typ, args, i, unpackCall, addins, lastVal, paramCounter):
    var res: typ
    var paramCounter {.compileTime, global.} = 0
    static: paramCounter = 0
    for name, field in res.fieldPairs: # Perhaps use disruptek's assume here
      when paramCounter < lastVal:
        when not compiles((let a: typeof(field) = unpackCall)):
          {.error: "Field '$#' (position $#) is of type '$#', but got a value type of '$#'." % [name, $paramCounter, $typeof(field), $typeof(unpackCall)].}
        field = unpackCall
        static: inc paramCounter


    addins
    res

macro new*(typ: typedesc[ref object or object], args: varargs[untyped]): untyped =
  ## Same as init but heap allocates instead, accepts `ref object` or `object` making `object` into a `ref`.
  ## Presently only works for non object variants
  runnableExamples:
    type MyType = object
      x, y: int
      z: string
    assert MyType.new(10, 20, "hello")[] == (ref MyType)(x: 10, y: 20, z: "hello")[]

  let
    i = gensym(nskVar, "i")
    paramCounter = gensym(nskVar, "paramCounter")
    unpackCall = newCall(bindSym"unpack", paramCounter)
    res = genSym(nskVar, "result")

  var
    addins = newStmtList()
    lastVal = -1

  for i, arg in args:
    if arg.kind == nnkExprEqExpr:
      let left =
        if arg[0].kind == nnkBracketExpr:
          let bracketExpr = arg[0].copyNimTree
          bracketExpr[0] = nnkDotExpr.newTree(res, bracketExpr[0])
          bracketExpr
        else:
          arg[0]

      addins.add:
        nnkAsgn.newTree(
          left,
          arg[1]
        )

      if lastVal < 0:
        lastVal = i

    else:
      if lastVal >= 0:
        error("Provided positional setter, following expression setters ambiguous what to do.", arg)
      unpackCall.add arg

  if addins.len == 0:
    lastVal = args.len

  result = genast(res, typ, args, i, unpackCall, addins, lastVal, paramCounter):
    var res = system.new(typ)
    var paramCounter {.compileTime, global.} = 0
    static: paramCounter = 0
    for name, field in res[].fieldPairs: # Perhaps use disruptek's assume here
      when paramCounter < lastVal:
        when not compiles((let a: typeof(field) = unpackCall)):
          {.error: "Field '$#' (position $#) is of type '$#', but got a value type of '$#'." % [name, $paramCounter, $typeof(field), $typeof(unpackCall)].}
        field = unpackCall
        static: inc paramCounter


    addins
    res




