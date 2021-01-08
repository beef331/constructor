import macros, strutils, sequtils

macro typeDef*(name: untyped, exported: static bool, body: untyped): untyped=
  ##[
    Generates a type with getter/setters
    Bool indcates if exported.
    Uses space seperated variables with `a = int`
    In get `result` is the stored value
    In set `value` is the passed in value
    Get and set take a block of code
  ]##
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
                var `valueIdent` = `valueIdent` #Value is shadowed
                `setterBody`
                `lowerName`.`backerName` = `valueIdent` #Autoset it to value so we dont have to expose backer
            getter = quote do:
              proc `getterName`(`lowerName`: `name`): `typeVal`=
                result = `lowerName`.`backerName` #Let's us get the value from backer without manually exposing
                `getterBody`

          if not setterBody.isNil: result.add setter
          if not getterBody.isNil: result.add getter
