import std/[macros, sugar, macrocache, strutils]

var defaultTable {.compileTime.} = CacheTable"Constr"

macro defaults*(tdef: untyped, hasRequires: static bool = false): untyped =
  result = tdef
  let name = $tdef[0][0].basename
  var
    params = @[ident(name)]
    constrParams = params
    allDefs =
      if result[2].kind == nnkRefTy:
        result[2][0][2]
      else:
        result[2][2]
  let
    procName =
      if result[2].kind == nnkRefTy:
        ident("new" & name)
      else:
        ident("init" & name)
    requiredIdents = collect(newSeq):
      for identDefs in allDefs:
        if identDefs[^1] == newEmptyNode() and hasRequires:
          params.add(identDefs)
          (identDefs[0..^3], identDefs[^2])

  for identDefs in allDefs:
    if identDefs[^1].kind != nnkEmpty and identDefs[^2].kind == nnkEmpty:
      let expression = identDefs[^1]
      identDefs[^2] = quote do:
        type(`expression`)
    if identDefs[^1].kind != nnkEmpty:
      for ident in identDefs[0..^3]:
        constrParams.add newColonExpr(ident.basename, identDefs[^1])
      identDefs[^1] = newEmptyNode()

  for (idents, _) in requiredIdents:
    for ident in idents:
      constrParams.add newColonExpr(ident, ident)
  let objCstr = nnkObjConstr.newTree(constrParams)
  var newProc = newProc(procName, params, objCStr)
  defaultTable[result.repr.replace("*")] = newProc

macro implDefaults*(t: typedesc[typed], exported: static bool = false): untyped =
  result = defaultTable[t.getimpl.repr.replace("*")]
  if exported and result[0].kind == nnkIdent:
    result[0] = result[0].postfix("*")
