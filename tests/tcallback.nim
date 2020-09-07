import ../src/constructor

typeDef(Test, true):
        a b = int
        d = seq[int]:
            get(true):
                test.dBacker
            set(true):
                if value.len >= 1:
                    test.dBacker = value[0..2]


var a = Test()
a.d = @[100, 200, 300, 400]
assert a.d == @[100 ,200, 300]