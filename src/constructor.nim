import macros, strformat, tables, strutils

macro construct*( T : typedesc[object | distinct], args : varargs[(string, untyped)], expNode : bool): untyped=
    ##Generates a constructor for a given type
    assert args.len > 0, "You did not pass any arguements"
    #Get strings from args
    var vars : seq[string]
    var defaults : seq[NimNode]
    for x in args:
        var lowered = ($x[0]).replace("_","")
        lowered = lowered[0] & lowered[1..lowered.high].toLower()
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
    assert node.len > 0, fmt"{nameSym} is not an object, no constructor made" 
    #Name type table
    var symType = initOrderedTable[string,NimNode]()
    var symDefault = initOrderedTable[string,NimNode]()
    #Ensures the variables exist on the object
    for n in node[2][2]:
        var lowered = ($n[0]).replace("_")
        lowered = lowered[0] & lowered[1..lowered.high].toLower()
        var index = 0
        for x in vars:
            if(x == lowered):
                assert (not symType.contains(x)), "Duplicate variable names detected"

                var cleanNode = copyNimTree(n[1])
                if(cleanNode.kind == nnkSym): cleanNode = ident($n[1])
                for child in cleanNode.pairs:
                    if(child[1].kind == nnkSym):
                        cleanNode[child[0]] = ident($child[1])
                symType.add($n[0],cleanNode)
                if(defaults[index].kind == nnkSym and $defaults[index] == "required"):
                    symDefault.add($n[0],newEmptyNode())
                else:
                    symDefault.add($n[0], defaults[index])
            inc index
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
                    symDefault[x]
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
    echo procNode.treeRepr
    return procNode

proc required*() = 
    ##This is used for required params to force values
    discard

type
    Huh = object
        a : int
        b : array[4,float]
        c : float



Huh.construct(("a", required), ("b", [1.3,2.5,5,10.3]),false)
Huh.construct(("b", required), ("c", 10.1),false)

echo newHuh(11, [5.5,5.3,10.0,12.3])
echo newHuh([10.3,13.55,3.421,2.123], 11.321)