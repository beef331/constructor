import std/[macros, genasts]
import micros

type DefaultFlag* = enum
  defExported   ## generate an exported procedure
  defTypeConstr ## generate only a `init(MyType)` procedure
  defBothConstr ## generates both `init(MyType)` and `initMyType()` procedures

macro defaults*(genFlags: static set[DefaultFlag], tdef: untyped): untyped =
  ## Used as pragma. Enables annotating fields on an object type `tdef` with initialization values
  ## When `tdef` is a value allocated type, it generates a init<YOUR TYPE> proc.
  ## When `tdef` is a heap allocated object, it generates a new<YOUR TYPE> proc.
  runnableExamples:
    import std/options
    type
      B {.defaults: {}.} = ref object of RootObj
        myFloat: float = 1.2

    type
      A {.defaults: {}.} = object
        myInt: int = 5
        myNoneOption: Option[int] = none(int)
        mySomeOption: Option[int] = some(6)
        myStr: string = "lala"
        myNewB: B = newB()

    assert initA().myInt == 5
    assert initA().myNoneOption == none(int)
    assert initA().mySomeOption == some(6)
    assert initA().myStr == "lala"
    assert initA().myNewB.myFloat == 1.2

  let
    objDef = objectDef(tdef).copy() # This is just the object definiton (type Obj = object ...)
    name = $objDef.name
    innerIdent = genSym(nskType, ident = "Inner") # Inner type identificator
    innerIdentTypedesc = newTree(nnkBracketExpr, ident("typedesc"), innerIdent) # typedesc[InnerType]
    procIdentBase =
      if tdef[2].kind == nnkRefTy:
        "new"
      else:
        "init"
    emptyNode = newEmptyNode()

  var
    params = @[innerIdent] # First parameter is the return type
    constrParams = params # Object constructor parameters, first param is the constructor type
    typeProcIdent = ident(procIdentBase)
    procIdent = ident(procIdentBase & name)

  if defExported in genFlags:
    typeProcIdent = typeProcIdent.postfix("*")
    procIdent = procIdent.postfix("*")

  # Here we replace all fields a = 1 to a: typeof(1) in objDef
  for identDef in objDef.fields:
    if identDef.val.kind != nnkEmpty:
      if identDef.typ.kind == nnkEmpty:
        identDef.typ =
          genAst(expr = identDef.val):
            typeof(expr)
      for ident in identDef.names:
        constrParams.add newColonExpr(ident.NimNode.basename, identDef.val)
      identDef.val = emptyNode

  let objCstr = nnkObjConstr.newTree(constrParams) # Object constructor: Obj(field1: val1, field2: val2)

  # Initialization procedures: initThingy() and init(Thingy)
  let newProc = newProc(procIdent, params, objCStr)

  params.add newIdentDefs(ident("_"), innerIdentTypedesc)

  let newTypeProc = newProc(typeProcIdent, params, objCStr)

  # This procedure checks for instantiation errors
  let checkProc = newProc(genSym(nskProc, "checker"), body = newTree(nnkDiscardStmt, newCall(ident(procIdentBase), innerIdentTypedesc)))

  var body = newStmtList(newTree(nnkTypeSection, NimNode objDef))

  if defBothConstr in genFlags:
    body.add(newProc, newTypeProc, checkProc)
  elif defTypeConstr in genFlags:
    body.add(newTypeProc, checkProc)
  else:
    body.add(newProc)

  body.add(innerIdent)

  result = tdef
  NimNode(objDef)[0] = innerIdent # Rename object definiton's name to innerIdent
  result[^1] = body

