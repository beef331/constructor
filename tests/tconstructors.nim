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

Bwbject.construct(false):
    a: required
    b: required


assert initAwbject(1.5) == Awbject(awesome : 1.5, coolInt : 10)
assert initAwbject() == Awbject(beautiful : "This is indeed", awesome : 1.1)
assert newBwbject(10, "This is a ref so uses new")[] == Bwbject(a : 10, b : "This is a ref so uses new")[]