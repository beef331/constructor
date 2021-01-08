import ../src/constructor

type 
  VectorKind = enum
    Position, Speed, Acceleration
  
type Vector = object
  x, y, z: float
  kind: VectorKind

Vector.construct(false):
  (x, y, z): required
  kind: Position
  _:
    echo "done!"

echo initVector(1, 2, 3)