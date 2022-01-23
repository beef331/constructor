import std/[macros, sugar, macrocache, strutils]

var defaultTable {.compileTime.} = CacheTable"Constr"

macro defaults*(tdef: untyped, hasRequires: static bool = false): untyped =
  ## Used as pragma. Enables annotating fields on an object type `tdef` with initialization values
  ## When `tdef` is a value allocated type, it generates a init<YOUR TYPE> proc.
  ## When `tdef` is a heap allocated object, it generates a new<YOUR TYPE> proc. 
  ## The procs are only generated after implDefaults(<YOUR TYPE>) is called.
  runnableExamples:
    import std/options
    type
      B {.defaults.} = ref object of RootObj
        myFloat: float = 1.2
    
    implDefaults(B)

    type
      A {.defaults.} = object
        myInt: int = 5
        myNoneOption: Option[int] = none(int)
        mySomeOption: Option[int] = some(6)
        myStr: string = "lala"
        myNewB: B = newB()

    implDefaults(A)
    assert initA().myInt == 5
    assert initA().myNoneOption == none(int)
    assert initA().mySomeOption == some(6)
    assert initA().myStr == "lala"
    assert initA().myNewB.myFloat == 1.2

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
