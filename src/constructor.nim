import macros, tables, strutils, sequtils

macro construct*(T : typedesc[object | distinct | ref], expNode : static bool, body: untyped): untyped=
  var 
    postConstructLogic: NimNode
    requiredParams: seq[NimNode]
    optionalParams: seq[NimNode]

  for call in body:
    if $call[0] == "_": postConstructLogic = call[1] #This is the post constructed node position
    elif call[1][0].kind == nnkIdent and $call[1][0] == "required" :
      requiredParams.add(call) #We know it's required
    else: optionalParams.add(call) #It's an optional value
  var node = T.getImpl #Get the Type Implementation
  let nameSym = $T

  #If distinct get original type
  if(node[2].kind == nnkDistinctTy):
    node = node[2][0].getImpl

  #Check if it's a ref object
  var isRef = false
  if(node[2].kind == nnkRefTy):
    isRef = true
    node = node[2][0][2] #Get Reclist
  else: node = node[2][2] #Get Reclist

  var identType = initTable[string, NimNode]()

  #Go for all vars and adding them to an identTable
  for varDecl in node:
    let varType = varDecl[1]
    for vari in varDecl:
      case vari.kind:
        of nnkIdent: identType[$vari] = varType
        of nnkPostfix: identType[$vari[1]] = varType #if exported it uses a postfix
        else: discard


  #Proc name
  let constrName = (if isRef: "new" else: "init") & nameSym

  #First parameter is return type which is the type this constructor is for
  var parameters: seq[NimNode] = @[ident(nameSym)]
  #For each parameter generate a new identdef
  for req in requiredParams:
    parameters.add(newIdentDefs(req[0], identType[$req[0]]))

  for opt in optionalParams:
    parameters.add(newIdentDefs(opt[0], identType[$opt[0]], opt[1][0]))

  #Generate the constructor
  #Ident tells the constructor the type
  var objConstr = newNimNode(nnkObjConstr).add(ident($T))
  #Generates a: a, for all arguements
  for param in requiredParams:
    objConstr.add(newColonExpr(param[0], param[0]))
  for param in optionalParams:
    objConstr.add(newColonExpr(param[0], param[0]))
  #Set result so we can use the object later in the `_` code
  let assignment = newAssignment(ident("result"), objConstr)
  #If ref the convention is new, else init
  let nameNode = if expNode : postfix(ident(constrName), "*") else: ident(constrName)
  #Dont have nil if there is no postConstructLogic
  let procBody = if postConstructLogic.isNil: newStmtList(assignment) else: newStmtList(assignment,postConstructLogic)
  #Where all our work ends
  result = newProc(nameNode,
                   parameters,
                   procBody)

macro typeDef*(name: untyped, exported: static bool, body: untyped): untyped=
  result = newStmtList()
  let exportedName = if exported: postfix(name, "*") else: name #if we want to export the type make a postfix
  result.add quote do: #Make typeDeff
    type `exportedName` = object
  result[0][0][2][2] = newNimNode(nnkRecList) #rec list
  for varDecl in body: #For each group decl
    var node = varDecl[0]
    let
      isProp = varDecl[1].len > 1 and varDecl[1][1].kind == nnkStmtList
      typeVal = if varDecl[1].len > 1: varDecl[1][0] else: varDecl[1]
      lowerName = ident(($name).toLowerAscii)
    #All our expected nodes are either idents or commands
    if node.kind in {nnkIdent, nnkCommand}:
      #Reduces redundant code
      let iterate = if node.kind == nnkIdent: @[node] else: toSeq(node.items)
      for varName in iterate:
        #Just add param to rec list if nnot prop 
        if not isProp:
          result[0][0][2][2].add newIdentDefs(varName, typeVal, newEmptyNode())
        else:
          let 
            backerName = ident($varName & "Backer")
          var
            setterBody: NimNode
            getterBody: NimNode
            getExported, setExported = false

          #Extract information from the varDecl
          for node in varDecl[1][1]:
            if $node[0] == "get": 
              getExported = node[1].kind == nnkident and $node[1] == "true"
              getterBody = if getExported: node[2] else: node[1]
            if $node[0] == "set": 
              setExported = node[1].kind == nnkident and $node[1] == "true"
              setterBody = if setExported: node[2] else: node[1]
          result[0][0][2][2].add newIdentDefs(backerName, typeVal, newEmptyNode())

          let 
            setterName = if setExported: postfix(ident($varName & "="), "*") else: ident($varName & "=") 
            getterName = if getExported: postfix(varName, "*") else: varName
          let
            valueIdent = ident("value")
            setter = quote do:
              proc `setterName`(`lowerName`: var `name`, `valueIdent` : `typeVal`)=
                `setterBody`
            getter = quote do:
              proc `getterName`(`lowerName`: `name`): `typeVal`= 
                `getterBody`

          if not setterBody.isNil: result.add setter
          if not getterBody.isNil: result.add getter
