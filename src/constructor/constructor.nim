import std/[macros, sets, sugar, strutils]

import times

macro constr*(p: typed): untyped =
  result = p.copyNimTree
  var retT = p.params[0]
  let
    firstParamType = p.params[1][^2]
    isInitStyle = firstParamType.kind == nnkBracketExpr and (($firstParamType[0]).eqIdent(
        "typedesc") or ($firstParamType[0]).eqIdent("type"))

  if isInitStyle and result.params[0].kind == nnkEmpty:
    result.params[0] = firstParamType[1]
    retT = firstParamType[1]

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
        error($name & " was provided previously, most likely as a parameter to the procedure.", name)
      if normalizedName in names:
        let idnt = ident(normalizedName)
        constrFields.incl normalizedName
        constrStmt.add nnkExprColonExpr.newTree(idnt, idnt)

  for defs in result.params[1..^1]:
    extractIdentDef(defs)
  let body =
    if result[^2].kind != nnkEmpty:
      result[^2]
    else:
      result[^1]


  for stmt in body:
    case stmt.kind
    of nnkIdentDefs:
      extractIdentDef(stmt)
    else:
      for def in stmt:
        extractIdentDef(def)

  if result[^2].kind != nnkEmpty:
    result[^2] = newStmtList(body)
    result[^2].add constrStmt
  else:
    result[^1] = newStmtList(body)
    result[^1].add constrStmt
