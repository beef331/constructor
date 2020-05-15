# Constructor
Nim automated object constructors, it creates constructors with specificied parameters to avoid named parameter constructors.

Simply use Nimble to install, then
```
import constructor
type
    Awwwbject = object
        awesome : float
        beautiful : string
        coolInt : int
Awwbject.construct("awesome","coolInt",true) #bool indicates exporting

#[
The macro then creates
proc newAwwbject(awesome : float, coolInt : int): Awwbject =
    Awwbject(awesome:awesome,coolInt : coolInt)
]#

newAwwbject(1.5,10)# so now you can call this instead of
newAwwbject(awesome : 1.5, coolInt : 10)