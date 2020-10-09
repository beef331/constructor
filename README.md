# Constructor
A collection of useful macros, mostly related to the construction of objects.


Simply use Nimble to install, then
`construct` generates constructors so you can quickly write constructors without having to write extremely redundant code.
```nim
import ../src/constructor
type
    Awbject = object
        awesome : float
        beautiful : string
        coolInt : int
    Bwbject = ref object
        a : int
        b : string

Awbject.construct(false): #false means it is not exported
    awesome = 1.5
    coolInt = 10 #Uses = for default values

Awbject.construct(true): #true means it is exported
    beautiful = "This is indeed" 
    coolInt: 10 #Uses : to indicate it's optional
    awesome: required #Uses required to indicate it's an required parameter
    _: #Code called after the creation of the object
      echo "Created a new Awbject"

Bwbject.construct(false):
    a: required
    b: required


assert initAwbject() == Awbject(awesome : 1.5, coolInt : 10)
assert initAwbject(1.1) == Awbject(beautiful: "This is indeed", awesome: 1.1, coolInt: 10)
assert newBwbject(10, "This is a ref so uses new")[] == Bwbject(a: 10, b: "This is a ref so uses new")[]
```
`typeDef` macro which can generate objects with properties.
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

`event` macro which generates an event, and coresponding procs to interact with it

```nim
event(TestEvent, int)

var testEvent = TestEvent()

proc countTo(a: int)= 
    for x in 0..a:
        echo x

testEvent.add(countTo)

testEvent.invoke(10)
```
