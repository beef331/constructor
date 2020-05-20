import macros, strformat, tables, strutils

macro construct*( T : typedesc[object | distinct | ref], expNode : bool, args : varargs[untyped]): untyped=
    ##Generates a constructor for a given type
    doAssert args.len > 0, "You did not pass any arguements"
    #Get strings from args
    var vars : seq[string]
    var defaults : seq[NimNode]
    for x in args:
        doAssert x.len > 1, fmt"Use a (string, value)"
        var lowered = ($x[0]).replace("_","")
        lowered = lowered[0] & lowered[1..lowered.high].toLower()
        doAssert (not vars.contains(lowered)), fmt"Duplicated Variable {lowered}"
        vars.add(lowered)
        defaults.add(x[1])

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

    doAssert node.len > 0, fmt"{nameSym} is not an object, no constructor made" 
    
    #Name type table
    var symType = initOrderedTable[string,NimNode]()
    var symDefault = initOrderedTable[string,NimNode]()

    #Ensures the variables exist on the object
   
    var index = 0
    var 
        varNode : NimNode
        isRef = node[2].kind == nnkRefTy
    if(isRef):
        varNode = node[2][0][2]
    else:
        varNode = node[2][2]

    for x in vars:
        for n in varNode:
            var lowered = ($n[0]).replace("_")
            lowered = lowered[0] & lowered[1..lowered.high].toLower()
            if(x == lowered):

                var cleanNode = copyNimTree(n[1])
                if(cleanNode.kind == nnkSym): cleanNode = ident($n[1])
                for child in cleanNode.pairs:
                    if(child[1].kind == nnkSym):
                        cleanNode[child[0]] = ident($child[1])
                symType.add($n[0],cleanNode)

                if(defaults[index].kind == nnkIdent and $defaults[index] == "req"):
                    symDefault.add($n[0],newEmptyNode())
                else:
                    symDefault.add($n[0], defaults[index])                
                break

        inc index

    doAssert (symType.len == vars.len), fmt"Incorrect field names in {vars}"

    var 
        params : seq[NimNode]
        constExpr : seq[NimNode]
    params.add(newIdentNode(nameSym))
    constExpr.add(newIdentNode(nameSym))

    doAssert symType.len > 0, "No matched variable names"

    #Generates params
    for x in symType.keys:
        params.add(newIdentDefs(
                    ident(x),
                    symType[x],
                    symDefault[x]
                    )
                )
        constExpr.add(newColonExpr(newIdentNode(x),newIdentNode(x)))
    
    #Export using the bool provided
    let 
        exported = expNode.boolVal
        procNameStr = if(isRef): fmt"new{nameSym}" else: fmt"init{nameSym}"
    var procName : NimNode
    if(exported):
        procName = newNimNode(nnkPostfix).add(ident("*"),ident(procNameStr))
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