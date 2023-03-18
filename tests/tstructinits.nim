import constructor/structinits
import std/unittest

type
  MyType = object
    x, y: int
    z: string
  MyRef = ref MyType
  MyGen[T] = object
    x: int
  MyArr = object
    x, y: int
    myArr: array[3, int]
    myOtherArray: array[3, array[3, int]]

check MyType.init(10, 20, "hello") == MyType(x: 10, y: 20, z: "hello")
check MyType.new(10, 20, "hello")[] == (ref MyType)(x: 10, y: 20, z: "hello")[]
check MyRef.new(10, 20, "Hello")[] == MyRef(x: 10, y: 20, z: "Hello")[]
check MyGen[int].init(100) == MyGen[int](x: 100)
check MyGen[int].new(100)[] == (ref MyGen[int])(x: 100)[]

check MyArr.init(1, 2, myArr[0] = 3, myArr[1] = 4) == MyArr(x: 1, y: 2, myArr: [3, 4, 0])
check MyArr.init(30, 40, myOtherArray[0][0] = 300) == MyArr(x: 30, y: 40, myOtherArray: [[300, 0, 0], [0, 0, 0], [0, 0, 0]])


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
  Image.init(default(FileInfo), "", default(DateTime))
