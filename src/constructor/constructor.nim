import std/[macros, sets, sugar, strutils]

import times

macro constr*(p: typed): untyped =
  result = p.copyNimTree
  let retT = p.params[0]

  let names = collect(initHashSet):
    for def in retT.getImpl[2][2]:
      if def.kind != nnkIdentDefs:
        error("'constr' presently doesnt support object variants.", p)
      for field in def[0..^3]:
        {($field).nimIdentNormalize}

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
  if result[^1].kind == nnkSym: # Weird AST
    result[^2] = newStmtList(nnkAsgn.newTree(ident"result", constrStmt))
  else:
    result[^1] = newStmtList(nnkAsgn.newTree(ident"result", constrStmt)):
      result[^1]
  echo result.repr