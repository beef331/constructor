import macros

macro event*(args: varargs[untyped]): untyped =
  let name = args[0]
  var
    procArgs = @[newEmptyNode()] #Holds the ident defs for formal params
    argIdents: seq[NimNode]      #Holds the ident names
  for i, arg in args[1..<args.len]:
    let varName = ident("var" & $i) #Generated name for passing to the listeners
    procArgs.add(newIdentDefs(varName, arg, newEmptyNode()))
    argIdents.add(varName)


  let
    params = newNimNode(nnkFormalParams).add(procArgs)         #formal params
    procTy = newNimNode(nnkProcTy).add(params).add(newEmptyNode()) #Generate proc type
    exportedName = postfix(name, "*") #We always export the event cause we're dumb

  result = newStmtList().add quote do:
    type `exportedName` = object
      listeners: seq[`procTy`]
    proc add*(evt: var `name`, newProc: `procTy`) =
      let ind = evt.listeners.find(newProc)
      if ind < 0: evt.listeners.add(newProc)

    proc remove*(evt: var `name`, toRemove: `procTy`) =
      let ind = evt.listeners.find(toRemove)
      if ind >= 0: evt.listeners.delete(ind)

  #Sometimes in our lives we all have things we need to borrow
  #AST is sometimes easier than quoteDo
  procArgs.insert(newIdentDefs(ident("evt"), name, newEmptyNode()), 1)
  var procBody = newNimNode(nnkForStmt).add(ident("listen"), newDotExpr(ident(
      "evt"), ident("listeners")), newStmtList().add(newCall(ident("listen"))))
  procBody[2][0].add(argIdents)
  let invokeProc = newProc(postfix(ident("invoke"), "*"), procArgs, procBody)
  result.add(invokeProc)
