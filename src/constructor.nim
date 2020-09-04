import macros, tables

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
    let varType = ident($varDecl.findChild(it.kind == nnkSym))
    for vari in varDecl:
      if vari.kind == nnkIdent: identType[$vari] = varType

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