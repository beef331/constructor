import std/[macros, tables]

{.experimental: "dynamicBindSym".}

when (NimMajor, NimMinor, NimPatch) < (1, 5, 1):
  static: error: "This module requires atleast Nim 1.5.1 with new concepts"

macro implements*(ident: untyped, concepts: varargs[typed], body: untyped): untyped =
  let ident = ident($ident)
  var implTypes: Table[string, (NimNode, int)] # type, conversion, count
  for x in concepts:
    for x in x.getImpl[2][3]: # Get the impls
      if x.kind == nnkProcDef: # Check each proc impl
        let 
          procName = x[0]
          impls = bindSym($x[0], brOpen)
        for impl in impls:
          block getType:
            let impl = impl.getImpl
            if $impl[0] == $procName and $impl[3][0] == $x[3][0]:
              for i, def in impl[3]:
                if def.len != impl[3][i].len and def[^2] != impl[3][i][^2]: # Hey it's not impl remove it
                  implTypes.del($impl[3][1][^2])
                  break getType
              let implName = ident($impl[3][1][^2])
              if $implName in implTypes: # It's implemented, add it!
                inc implTypes[$implName][1]
              else:
                let conversion = quote do:
                  `ident` of `implName`
                implTypes[$implName] = (conversion, 1)
  var conditions: seq[(Nimnode, NimNode)]
  for (implType, count) in implTypes.values:
    if count == concepts.len:
      var 
        body = body.copyNimTree
        t = implType[^1]
      body.insert 0, quote do:
        let `ident` = `ident`.`t`
      conditions.add (implType, body)
  result = newIfStmt(conditions)
