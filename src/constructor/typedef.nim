import macros, strutils, sequtils

macro typeDef*(name: untyped, body: untyped): untyped=
  ##[
    Generates a type with getter/setters.
    Multiple variables can be created with `(a, b) = int`.
    Exporting is done with prefix notation and `*`.
    In get `result` is the stored value.
    In set `value` is the passed in value.
    Get and set take a block of code.
  ]##
  result = newStmtList()
  let
    exported = name.kind == nnkPrefix and $name[0] == "*"
    name = if exported: name[1] else: name
    exportedName = if exported: postfix(name, "*") else: name #if we want to export the type make a postfix
  result.add quote do: #Make typeDeff
    type `exportedName` = object
  result[0][0][2][2] = newNimNode(nnkRecList) #rec list
  for varDecl in body: #For each group decl
    var node = varDecl[0]
    let
      isProp = varDecl[1].len > 1 and varDecl[1][1].kind == nnkStmtList
      typeVal = if varDecl[1].len > 1: varDecl[1][0] else: varDecl[1]
      lowerName = ident(($name).toLowerAscii)
      isExported = node.kind == nnkPrefix and $node[0] == "*"

    if isExported: node = vardecl[0][1]
    #All our expected nodes are either idents or commands
    if node.kind in {nnkIdent, nnkCommand, nnkPar}:
      #Reduces redundant code
      let iterate = if node.kind == nnkIdent: @[node] else: toSeq(node.items)
      for varName in iterate:
        #Just add param to rec list if nnot prop 
        if not isProp:
          let varName = block:
              if isExported:
                postfix(varName, "*")
              else: varName
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
            let 
              (propNode, expNode) = block:
                if node.len == 3:
                  (node[1], node[0])
                else:
                  (node[0], newEmptyNode())
            if ($propNode) == "get": 
              getExported = expNode.kind == nnkIdent and ($expNode) == "*"
              getterBody = if getExported: node[2] else: node[1]
            if ($propNode) == "set": 
              setExported = expNode.kind == nnkIdent and ($expNode) == "*"
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
