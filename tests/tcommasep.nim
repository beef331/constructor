import constructor

type
  VectorKind = enum
    Position, Speed, Acceleration

type Vector = object
  x, y, z: float
  kind: VectorKind

Vector.construct(false):
  (x, y, z): required
  kind: Position

assert initVector(1, 2, 3) == Vector(x: 1, y: 2, z: 3, kind: Position)
