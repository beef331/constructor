# Constructor
Nim automated object constructor

Simply use Nimble to install, then
```
import constructor
type
    Awwwbject = object
        awesome : float
        beautiful : string
        coolInt : int
Awwbject.construct("awesome","coolInt",true) #bool indicates exporting

newAwwbject(1.5,10)