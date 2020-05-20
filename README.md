# Constructor
Nim automated object constructors, it creates constructors with specified parameters to avoid named parameter constructors.

Simply use Nimble to install, then
```
import constructor

type
    Awbject = object
        awesome : float
        beautiful : string
        coolInt : int


#Simply write (varName, req) to force the variable to be needed.
#Otherwise (varName,defaultValue) where default value is what you want it to default to.
Awbject.construct(false, (awesome, req), (coolInt, 10)) #bool indicates exporting
Awbject.construct(true, (beautiful, "This is indeed"), (awesome, 1.1), (coolInt, 10))

#[
    The macros create
    proc newAwbject(awesome : float, coolInt : int = 10): Awbject =
        Awbject(awesome:awesome,coolInt : coolInt)

    proc newAwbject*(beautiful : string = "This is indeed",
                    awesome : float = 1.1,
                    coolInt : int = 11): Awbject =
        Awbject(awesome : awesome, coolInt : coolInt, beautiful : beautiful)
]#



#Now these can be called
newAwbject(1.5)
newAwbject()

#Instead of
Awbject(awesome : 1.5, coolInt : 10)
Awbject(beautiful : "This is indeed", awesome : 1.1, coolInt : 11)
```
