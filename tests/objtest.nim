import constructor/typedef

typeDef(*Test):
  *(a, b) = int
  c = string
  d = seq[int]:
    *get:
      return result
    *set:
      if value.len >= 1:
        value = value[0..2]