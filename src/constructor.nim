import macros, strformat, tables, strutils

macro construct*( T : typedesc[object | distinct], args : varargs[string], expNode : bool): untyped=
    ##Generates a constructor for a given type

    assert args.len > 0, "You did not pass any arguements"
    #Get strings from args
    var vars : seq[string]
    for x in args:
        var lowered = ($x).replace("_","")
        lowered = lowered[0] & lowered[1..lowered.high].toLower()
        vars.add(lowered)


    var 
        node = T.getImpl
        isDistinct : bool = false
        rootName : string
    let nameSym = $node[0]
    #If distinct get original type
    if(node[2].kind == nnkDistinctTy):
        node = node[2][0].getImpl
        isDistinct = true
        rootName = $node[0]
    assert node.len > 0, fmt"{nameSym} is not an object, no constructor made" 
    #Name type table
    var symType  = initOrderedTable[string,NimNode]()

    #Ensures the variables exist on the object
    for n in node[2][2]:
        var lowered = ($n[0]).replace("_")
        lowered = lowered[0] & lowered[1..lowered.high].toLower()
        for x in vars:
            if(x == lowered):
                assert (not symType.contains(x)), "Duplicate variable names detected"
                symType.add($n[0],n[1])

    var 
        params : seq[NimNode]
        constExpr : seq[NimNode]
    params.add(newIdentNode(nameSym))
    constExpr.add(newIdentNode(nameSym))

    assert symType.len > 0, "No matched variable names"

    #Generates params
    for x in symType.keys:
        params.add(newIdentDefs(
                    ident(x),
                    symType[x],
                    newEmptyNode()
                    )
                )
        constExpr.add(newColonExpr(newIdentNode(x),newIdentNode(x)))
    
    #Export using the bool provided
    let exported = expNode.boolVal
    var procName : NimNode
    if(exported):
        procName = newNimNode(nnkPostfix).add(ident("*"),ident(fmt"new{nameSym}"))
    else:
        procName = ident(fmt"new{nameSym}")

    #Builds the nodes
    var 
        retNode : NimNode
    if(isDistinct):
        constExpr[0] = ident(rootName)
        retNode = newCall(ident(nameSym),newNimNode(nnkObjConstr).add(constExpr))
    else:
        retNode = newNimNode(nnkObjConstr).add(constExpr)


    let
        bodyNode = newStmtList(retNode)
        procNode = newStmtList(newProc(procName,params,bodyNode))
    return procNode