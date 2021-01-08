import constructor

typeDef(Test, true):
        a b = int
        d = seq[int]:
            get(true): return result
            set(true):
                if value.len >= 1:
                    value = value[0..2]

#[
    Generates:
        type
            Test* = object
                a: int
                b: int
                dBacker: seq[int]

        proc d=*(test: var Test; value: seq[int]) =
        if value.len >= 1:
            test.dBacker = value[0 .. 2]

        proc d*(test: Test): seq[int] =
            test.dBacker
]#