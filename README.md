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

#Simply write (varName, req) to force the variable to be needed.
#Otherwise (varName,defaultValue) where default value is what you want it to default to.
Awbject.construct(false, (awesome, req), (coolInt, 10)) #bool indicates exporting
Awbject.construct(true, (beautiful, "This is indeed"), (awesome, 1.1), (coolInt, 10))

Bwbject.construct(false,(a, req),(b, req))

#[
    The macros create
    proc initAwbject(awesome : float, coolInt : int = 10): Awbject =
        Awbject(awesome:awesome,coolInt : coolInt)

    proc initAwbject*(beautiful : string = "This is indeed",
                    awesome : float = 1.1,
                    coolInt : int = 10): Awbject =
        Awbject(awesome : awesome, coolInt : coolInt, beautiful : beautiful)

    proc newBwbject(a : int, b : string): Bwbject =
        Bwbject(a : a, b : b)
]#



#Now these can be called
initAwbject(1.5)
initAwbject()

newBwbject(10,"This is a ref so uses new")# Notice refs do not use init but new

#Instead of
Awbject(awesome : 1.5, coolInt : 10)
Awbject(beautiful : "This is indeed", awesome : 1.1, coolInt : 11)
Bwbject(a : 10, b : "This is a ref so uses new")
```
