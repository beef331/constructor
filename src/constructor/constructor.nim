import std/[macros, sets, sugar, strutils]

macro constr*(p: typed): untyped =
  result = p.copyNimTree
  let retT = p.params[0]

  let names = collect(initHashSet):
    for def in retT.getImpl[2][2]:
      if def.kind != nnkIdentDefs:
        error("'constr' presently doesnt support object variants.", p)
      for field in def[0..^3]:
        {($field.basename).nimIdentNormalize}

  var
    constrStmt = nnkObjConstr.newTree(retT)
    constrFields: HashSet[string]

  template extractIdentDef(toIter: NimNode) =
    for name in toIter[0..^3]:
      let normalizedName = ($name).nimIdentNormalize
      if normalizedName in constrFields:
        error($name & " was provided previously.", name)
      if normalizedName in names:
        let idnt = ident(normalizedName)
        constrFields.incl normalizedName
        constrStmt.add nnkExprColonExpr.newTree(idnt, idnt)

  for defs in result.params[1..^1]:
    extractIdentDef(defs)

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
