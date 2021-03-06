import macros, tables

proc construct(T: NimNode, expNode: bool,
    body: NimNode): NimNode =
  var
    postConstructLogic: NimNode
    requiredParams: seq[NimNode]
    optionalParams: seq[NimNode]
    defaultValues: seq[(NimNode, NimNode)] #Left is ident, right is value

  for call in body:
    let isRequired = (call[1].len > 0 and call[1][0].kind == nnkIdent and $call[
        1][0] == "required")

    if call.kind == nnkCall: #Required value
      if call[0].kind == nnkPar: #Comma seperated identifiers
        for vari in call[0]:
          if isRequired:
            requiredParams.add(newCall(vari, call[1])) #Multiple required variables
          else:
            optionalParams.add(newCall(vari, call[1]))
      else:
        if $call[0] == "_":
          postConstructLogic = call[1] #This is the post constructed node position
        elif isRequired:
          requiredParams.add(call) #We know it's required
        else:
          optionalParams.add(call) #It's an optional value
    else: #This is an assignment which means it's a default value
      if call[0].kind == nnkPar:
        for vari in call[0]:
          defaultValues.add (vari, call[1]) #It's multiple fields to a default value
      else:
        defaultValues.add (call[0], call[1]) #It's a default value

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
    let varType = varDecl[^2]

    for vari in varDecl:
      case vari.kind:
        of nnkIdent, nnkPostfix: identType[$vari.basename] = varType
        else: discard

  #Proc name
  let constrName = (if isRef: "new" else: "init") & nameSym
  #Ident tells the constructor the type
  var objConstr = newNimNode(nnkObjConstr).add(ident($T))

  #First parameter is return type which is the type this constructor is for
  var parameters: seq[NimNode] = @[ident(nameSym)]
  if body.kind == nnkEmpty:
    for ident, t in identType:
      let ident = ident.ident # Converts the ident string to an ident
      # Add all the fields as params
      parameters.add(newIdentDefs(ident, t, newEmptyNode()))
      #Generates a: a, for all arguments
      objConstr.add(newColonExpr(ident, ident))

  else: # We have select params
    #For each parameter generate a new identdef
    for req in requiredParams:
      parameters.add(newIdentDefs(req[0], identType[$req[0]]))

    for opt in optionalParams:
      parameters.add(newIdentDefs(opt[0], identType[$opt[0]], opt[1][0]))

    #Generates a: a, for all arguments
    for param in requiredParams:
      objConstr.add(newColonExpr(param[0], param[0]))
    for param in optionalParams:
      objConstr.add(newColonExpr(param[0], param[0]))
    for def in defaultValues:
      objConstr.add(newColonExpr(def[0], def[1]))

  #Set result so we can use the object later in the `_` code
  let assignment = newAssignment(ident("result"), objConstr)
  #If ref the convention is new, else init
  let nameNode = if expNode: postfix(ident(constrName), "*") else: ident(constrName)
  #Dont have nil if there is no postConstructLogic
  let procBody = if postConstructLogic.isNil: newStmtList(
      assignment) else: newStmtList(assignment, postConstructLogic)
  #Where all our work ends
  result = newProc(nameNode,
                   parameters,
                   procBody)

macro construct*(T: typedesc[object | distinct | ref], expNode: static bool,
    body: untyped): untyped =
  ##[
      Generates constructor named initT for non refs and newT for refs.
      Bool indicates export.
      For each required field do name: required.
      To call logic after instantiation use _: the object is stored in result.
  ]##
  T.construct(expNode, body)

macro construct*(T: typedesc[object | distinct | ref], expNode: static bool): untyped =
  ##[
      Generates constructor named initT for non refs and newT for refs.
      The created constructor has no parameters, identical to T().
      Bool indactes export.
  ]##
  result = construct(T, expNode, newEmptyNode())
  