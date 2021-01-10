import constructor
type
  Awbject = object
    awesome: float
    beautiful: string
    coolInt: int
  Bwbject = ref object
    a: int
    b: string

Awbject.construct(false):
  awesome = 1.5
  coolInt = 10 #Uses = for default values

Awbject.construct(true):
  beautiful = "This is indeed"
  coolInt: 10 #Uses : to indicate it's optional
  awesome: required #Uses required to indicate it's an required parameter

Bwbject.construct(false):
  (a, b): required

Bwbject.construct(false) # Parameterless constructor identical to `T()`.



assert initAwbject() == Awbject(awesome: 1.5, coolInt: 10)
assert initAwbject(1.1) == Awbject(beautiful: "This is indeed", awesome: 1.1, coolInt: 10)
assert newBwbject(10, "This is a ref so uses new")[] == Bwbject(a: 10,
        b: "This is a ref so uses new")[]
