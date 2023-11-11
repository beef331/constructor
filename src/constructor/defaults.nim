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
    innerIdent = ident("Inner" & name)#genSym(nskType, ident = "Inner") # This is the identificator of the inner type
  var
    # First parameter is the return type
    params = @[innerIdent]
    constrParams = params # constrParams are the parameters for the object constructor

  let
    procNameBase =
      if tdef[2].kind == nnkRefTy:
        "new"
      else:
        "init"

    typeProcName = ident(procNameBase)
    procName = ident(procNameBase & name)

    emptyNode = newEmptyNode()

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

  let newProc = newProc(if defExported in genFlags: procName.postfix("*") else: procName, params, objCStr) # Initialization procedure

  params.add newIdentDefs(ident("_"), newTree(nnkBracketExpr, ident("typedesc"), innerIdent))

  let newTypeProc = newProc(if defExported in genFlags: typeProcName.postfix("*") else: typeProcName, params, objCStr) # Initialization procedure

  result = tdef
  NimNode(objDef)[0] = innerIdent # Rename object definiton's name to innerIdent
  result[^1] =
    if defBothConstr in genFlags:
      newStmtList(newTree(nnkTypeSection, NimNode objDef), newProc, newTypeProc, innerIdent)
    elif defTypeConstr in genFlags:
      newStmtList(newTree(nnkTypeSection, NimNode objDef), newTypeProc, innerIdent)
    else:
      newStmtList(newTree(nnkTypeSection, NimNode objDef), newProc, innerIdent)

