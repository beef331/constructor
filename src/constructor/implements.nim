import std/[macros, sugar]

{.experimental: "dynamicBindSym".}

macro implements*(ident: untyped, concepts: varargs[typed], body: untyped): untyped =
  let ident = ident($ident)
  var implTypes: seq[NimNode]
  for x in concepts:
    for x in x.getImpl[2][3]:
      if x.kind == nnkProcDef:
        let 
          procName = x[0]
          impls = bindSym($x[0], brOpen)
        for impl in impls:
          block getType:
            let impl = impl.getImpl
            if $impl[0] == $procName and $impl[3][0] == $x[3][0]:
              for i, def in impl[3]:
                if def.len != impl[3][i].len and def[^2] != impl[3][i][^2]:
                  break getType
              let implName = ident($impl[3][1][^2])
              implTypes.add quote do:
                `ident` of `implName`
  var conditions: seq[(Nimnode, NimNode)]
  for implType in implTypes:
    var 
      body = body.copyNimTree
      t = implType[^1]
    body.insert 0, quote do:
      let `ident` = `ident`.`t`
    conditions.add (implType, body)
  result = newIfStmt(conditions)
