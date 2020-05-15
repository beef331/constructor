# Constructor
Nim automated object constructors, it creates constructors with specificied parameters to avoid named parameter constructors.

Simply use Nimble to install, then
```
import constructor
type
    Awbject = object
        awesome : float
        beautiful : string
        coolInt : int
Awbject.construct("awesome","coolInt",true) #bool indicates exporting

#[
The macro then creates
proc newAwbject(awesome : float, coolInt : int): Awbject =
    Awbject(awesome:awesome,coolInt : coolInt)
]#

newAwbject(1.5,10)# so now you can call this instead of
newAwbject(awesome : 1.5, coolInt : 10)