import macros, tables, strutils
{.experimental: "strictNotNil"}

type
  Field = object
    name: NimNode
    case isVariant: bool
    of true:
      kind: NimNode
    else:
      fieldType: NimNode

macro variant(name: untyped, publicEnum: static bool = false, body: untyped): untyped = 
  let 
    (typeName, enumName) = # New type name and enum name
      if name.len > 0:
        (postfix(name[1], "*"), ident($name[1] & "Kind"))
      else:
        (name, ident($name & "Kind"))
    name = typeName.baseName
  var
    enums: seq[NimNode]
    fields: Table[string, seq[Field]] # Enum -> Fields
    isPublic = typeName.len > 0
    recursive = false
  for decl in body:
    let
      enumName = $decl[0]
      isGlobalFields = enumName == "_" # `_` is used for global fields
   
    if not isGlobalFields:
      enums.add decl[0]
    fields[enumName] = @[]

    for field in decl[1]:
      let name = field[0]
      if field[1].len > 0 and field[1][0].kind == nnkInfix and $field[1][0][0] == "of":
        # So we can enforce subtypes
        fields[enumName].add Field(name: name, isVariant: true, kind: field[1][^1][^1])
        recursive = true
      else:
        fields[enumName].add Field(name: name, isVariant: false, fieldType: field[1][0])

  result = newStmtList()
  let kindIdent = ident("kind")
  result.add newEnum(enumName, enums, publicEnum, false)
  if recursive:
    let name = ident($typeName.basename & "Nilable") # We're using strict not nil for recursives
    result.add quote do:
      type `name` = ref object
        case `kindIdent`: `enumName`
  else:
    result.add quote do:
      type `typeName` = object
        case `kindIdent`: `enumName`
  var 
    globalIdents = @[ident($name.baseName)] # All the shared fields
    globalCalls: seq[NimNode] # Shared passing in constructor
    globalBody = newStmtList() 

  for field in fields.getOrDefault("_", @[]):
    let t =
      if field.isVariant:
        typeName.basename
      else:
        field.fieldType
    let identDef = newIdentDefs(field.name, t, newEmptyNode())
    globalIdents.add identDef

    # Add field to object global
    if recursive:
      result[1][0][2][0][2].insert 0, identDef 
    else:
      result[1][0][2][2].insert 0, identDef 

    let fieldName = field.name
    globalCalls.add newColonExpr(fieldName, fieldName)

    if field.isVariant: # Our field safety
      let 
        expectedKind = field.kind
        fieldStr = $fieldName
      globalBody.add quote do:
        body.add quote do:
          assert `fieldName`.kind == `expectedKind`, `fieldStr` & "'s kind is not " & $`expectedKind`
  for enm in enums:
    var
      idents = globalIdents
      calls = globalCalls
      body = globalBody.copyNimTree
    let procName = ident("init" & ($enm).capitalizeAscii)
    # Add each enum to the reclist ofBranch
    if recursive:
      result[1][0][2][0][2][^1].add nnkOfBranch.newNimNode().add(enm, nnkRecList.newNimNode())
    else:
      result[1][0][2][2][1].add nnkOfBranch.newNimNode().add(enm, nnkRecList.newNimNode())
    let recList = 
      if recursive: 
        result[1][0][2][0][2][^1][^1][1]
      else:
        result[1][0][2][2][1][^1][1]
    calls.insert newColonExpr(kindIdent, enm), 0

    for i, field in fields[$enm]:
      let 
        t =
          if field.isVariant:
            typeName.basename
          else:
            field.fieldType
        identDef = newIdentDefs(field.name, t, newEmptyNode())
      idents.add identDef
      recList.add identDef
      let fieldName = field.name
      calls.add newColonExpr(fieldName, fieldName)

      if field.isVariant:
        let 
          expectedKind = field.kind
          fieldStr = $fieldName
        body.add quote do:
          assert `fieldName`.kind == `expectedKind`, `fieldStr` & "'s kind is not " & $`expectedKind`

    calls.insert typeName.basename, 0
    body.add nnkObjConstr.newTree(calls)
    result.add newProc(procName, idents, body)
  
  if recursive:
    let name = ident($typeName.basename & "Nilable")
    result[1].add nnkTypeDef.newTree(typeName, newEmptyNode(), nnkInfix.newTree(ident("not"), name, newNilLit()))

macro variantImpl(kind: enum, p: untyped): untyped =
  result = newStmtList()
  let
    lambdaT = nnkProcTy.newNimNode()
    lambda = nnkLambda.newNimNode()
    name = 
      if p[0].kind == nnkAccQuoted:
        $p[0][0]
      else:
        $p[0].basename
    arrCompName = ident(name & "CompTable")
    arrName = ident(name & "Table")
  lambdaT.add [p[3], newEmptyNode()]
  p.copyChildrenTo(lambda)
  lambda[0] = newEmptyNode()
  
  let 
    newProc = p.copyNimTree()
    firstParam = p[3][1][0]
  newProc[^1] = newStmtList().add quote do:
    `arrName`[`firstParam`.kind]()
  for idef in p[3][1..^1]:
    for idnt in idef[0..^3]:
      newProc[^1][0].add(idnt)

  
  result.add quote do:
    when not declared(`arrCompName`):
      var `arrCompName`{.compileTime.}: array[`kind`.type, `lambdaT`]
      const `arrName` = `arrCompName`
      `newProc`
    static:
      `arrCompName`[`kind`] = `lambda`

variant LambdaExp, true:
  Var:
    b: string
  Abs:
    absName: string
    c: LambdaExp of Var # Enforces only kinds of Var
  App:
    appName: string
    d: LambdaExp of Var

proc `$`(l: LambdaExp): string {.variantImpl: Var.} = l.b
proc `$`(l: LambdaExp): string {.variantImpl: Abs.} = l.absName & " " & $l.c
proc `$`(l: LambdaExp): string {.variantImpl: App.} = l.appName & " " & $l.d

let 
  a = initVar("Hello")
  b = initAbs("hehe", a)
  c = initApp("Hmmmm", a)
echo b
echo c