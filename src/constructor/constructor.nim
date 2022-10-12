import std/[macros, sets, sugar, strutils]
import micros

macro constr*(p: typed): untyped =
  ## Used as pragma. Automatically creates an instance of the desired type within
  ## results and populates it with the given parameters of the proc it is used on.
  ## The parameter names must equal the field names on the instance that is
  ## being created
  runnableExamples:
    import std/options

    type
      A* = object
        myInt*: int
        myOption*: Option[int] 
        myStr*: string

    proc initA(myInt: int, myOption: Option[int], myStr: string): A {.constr.}
    assert initA(5, some(2), "hello") == A(myInt: 5, myOption: some(2), myStr: "hello")

  let
    routine = routineNode(p)
    retT = routine.returnType
  if retT.kind == nnkEmpty:
    error("Constructors requires a return type", retT)
  let names = collect(initHashSet):
    for def in objectDef(retT).fields:
      for field in def.names:
        {($field.NimNode.baseName).nimIdentNormalize}

  var
    constrStmt = nnkObjConstr.newTree(retT)
    constrFields: HashSet[string]

  for defs in routine.params:
    for name in defs.names:
      let normalizedName = ($name.NimNode).nimIdentNormalize
      if normalizedName in constrFields:
        error(normalizedName & " was provided previously.", name.NimNode)
      if normalizedName in names:
        let idnt = ident(normalizedName)
        constrFields.incl normalizedName
        constrStmt.add nnkExprColonExpr.newTree(idnt, idnt)

  result = copyNimTree(p)
  if result[^2].kind != nnkEmpty and result[^1].kind == nnkSym:
    # Handles weird ast where last node is `sym` and second last is `body`
    result[^2] = newStmtList(nnkAsgn.newTree(result[^1], constrStmt), result[^2])
  else:
    # Handles weird case where last node is `body` and second last is bracket expr
    result[^1] =
      if result[^1].kind != nnkEmpty:
        newStmtList(nnkAsgn.newTree(ident"result", constrStmt), result[^1])
      else:
        nnkAsgn.newTree(ident"result", constrStmt)
    if {p[^1].kind, p[^2].kind} == {nnkEmpty}:
      # Is this a forward declare
      result = newStmtList(p, result)
