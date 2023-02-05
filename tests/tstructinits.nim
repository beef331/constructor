import constructor/structinits
import std/unittest

type
  MyType = object
    x, y: int
    z: string
  MyRef = ref MyType
  MyGen[T] = object
    x: int

check MyType.init(10, 20, "hello") == MyType(x: 10, y: 20, z: "hello")
check MyType.new(10, 20, "hello")[] == (ref MyType)(x: 10, y: 20, z: "hello")[]
check MyRef.new(10, 20, "Hello")[] == MyRef(x: 10, y: 20, z: "Hello")[]
check MyGen[int].init(100) == MyGen[int](x: 100)
check MyGen[int].new(100)[] == (ref MyGen[int])(x: 100)[]


import std/[os, times]

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
