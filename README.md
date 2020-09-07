# Constructor
Nim automated object constructors, it creates constructors with specified parameters to avoid named parameter constructors.

Simply use Nimble to install, then
```nim
import constructor

type
    Awbject = object
        awesome : float
        beautiful : string
        coolInt : int
    Bwbject = ref object
        a : int
        b : string

Awbject.construct(false):
    awesome: required
    coolInt: 10
Awbject.construct(true):
    beautiful: "This is indeed"
    awesome: 1.1
    _:
    #[
        Can call code after created.
        'result' is where the constructed variable is stored.
    ]#
    echo "Heh"

Bwbject.construct(false):
    a: required
    b: required


#Now these can be called
initAwbject(1.5)
initAwbject()

newBwbject(10,"This is a ref so uses new")# Notice refs do not use init but new

```
This module also has a `typeDef` macro which can generate objects with properties.
Below is the syntax.
```nim
import ../src/constructor

typeDef(Test, true):
        a b = int
        d = seq[int]:
            get(true):
                test.dBacker
            set(true): #In setters value is the input value
                if value.len >= 1:
                    test.dBacker = value[0..2]

var a = Test()
a.d = @[100, 200, 300, 400]
assert a.d == @[100 ,200, 300] #Means the Setter did the job
```

