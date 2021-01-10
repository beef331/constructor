import objtest

var a = Test()
a.d = @[100, 200, 300, 400]
assert a.d == @[100, 200, 300]
