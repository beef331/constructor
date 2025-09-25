import std/macros

macro applyArgs(val: typed, fields: varargs[untyped]): untyped =
  result = newStmtList()
  for x in fields:
    case x[0].kind
    of nnkIdent:
      result.add nnkAsgn.newTree(nnkDotExpr.newTree(val, x[0]), x[1])
    of nnkBracketExpr:
      let origNode = x[0]
      var node = origNode
      while node[0].kind == nnkBracketExpr:
        node = node[0]
      node[0] = nnkDotExpr.newTree(val, node[0])

      result.add nnkAsgn.newTree(
        origNode,
        x[1]
      )
    else:
      error("Incorrect field initer", x)

template init*(typ: typedesc[object], args: varargs[untyped]): untyped =
  ## initializes an object from a type
  runnableExamples:
    type MyObject = object
      a, b: int
      z: array[3, int]
    assert MyObject.init(x = 30, b = 10, z[0] = 3, z[1..2] = [1, 2]) == MyObject(a: 30, b: 10, z: [0, 1, 2])

  var val = typ()
  applyArgs(val, args)
  val

template init*(val: object, args: varargs[untyped]): untyped =
  ## initializes an object from a value, this lets using `someVar.init(...)`
  runnableExamples:
    type MyObject = object
      a, b: int
      z: array[3, int]
    assert MyObject(a: 30, b: 10).init(z[0] = 3, z[1..2] = [1, 2]) == MyObject(a: 30, b: 10, z: [0, 1, 2])
  var it = val
  applyArgs(it, args)
  it

template new*(typ: typedesc[ref object | object], args: varargs[untyped]): untyped =
  ## allocates a new object from a type
  runnableExamples:
    type
      MyObject = object
        a, b: int
        z: array[3, int]
      RefObj = ref MyObject
    assert MyObject.new(a = 30, b = 10, z[0] = 3, z[1..2] = [1, 2])[] == RefObj(a: 30, b: 10, z: [0, 1, 2])[]
    assert MyRef.new(a = 30, b = 10, z[0] = 3, z[1..2] = [1, 2])[] == RefObj(a: 30, b: 10, z: [0, 1, 2])[]

  var val = system.new typ
  applyArgs(val, args)
  val

template new*(val: typed, args: varargs[untyped]): untyped =
  runnableExamples:
    type
      MyObject = object
        a, b: int
        z: array[3, int]
      RefObj = ref MyObject
    assert MyObject(a: 30, b: 10).new(z[0] = 3, z[1..2] = [1, 2])[] == RefObj(a: 30, b: 10, z: [0, 1, 2])[]
    assert MyRef(a: 30, b: 10).new(z[0] = 3, z[1..2] = [1, 2])[] == RefObj(a: 30, b: 10, z: [0, 1, 2])[]
  when val is ref:
    var it = val
  else:
    var it = new typeof(val)
    it[] = val

  applyArgs(it, args)
  it
