import constructor/structinits
import std/unittest

type
  MyType = object
    x, y: int
    z: string
  MyRef = ref MyType
  MyGen[T] = object
    x: int
    val: T
  MyArr = object
    x, y: int
    myArr: array[3, int]
    myOtherArray: array[3, array[3, int]]

check MyArr.init(x = 1, y = 2, myArr[0] = 3, myArr[1] = 4) == MyArr(x: 1, y: 2, myArr: [3, 4, 0])
check MyArr.init(x = 30, y = 40, myOtherArray[0][0] = 300) == MyArr(x: 30, y: 40, myOtherArray: [[300, 0, 0], [0, 0, 0], [0, 0, 0]])
check MyArr.new(x = 30, y = 40, myOtherArray[0][0] = 300)[] == (ref MyArr)(x: 30, y: 40, myOtherArray: [[300, 0, 0], [0, 0, 0], [0, 0, 0]])[]
check MyGen[int](val: 100).init(x = 30) == MyGen[int](x: 30, val: 100)
check MyGen[int](val: 100).new(x = 30)[] == (ref MyGen[int])(x: 30, val: 100)[]


import std/[times]

type FileInfo* = object
  path*: string
  size*: BiggestInt
  exists*: bool

type Image* = object
  file*: FileInfo
  dest*: string
  date*: DateTime

proc initImage*(file: FileInfo, dest: string, lastModified: Time): Image =
  Image.init(file = default(FileInfo), dest = "", date = default(DateTime))
