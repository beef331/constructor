import constructor

event(ScoreEvent, int)

var 
  scoreEvent = ScoreEvent()
  count = 0

typeDef(Awbject, true):
    score = int:
        set:
            scoreEvent.invoke(value)
        get:
            return result

Awbject.construct(false):
  _:discard

proc scored(score: int) = count += 1

proc laugh(score: int) = count += score

scoreEvent.add(scored)
scoreEvent.add(laugh)

var awbject = initAwbject()
awbject.score = 11

scoreEvent.remove(scored)


awbject.score = 5
assert awbject.score == 5
assert count == 17