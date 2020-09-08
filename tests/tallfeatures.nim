import ../src/[constructor,events]

event(ScoreEvent, int)

var scoreEvent = ScoreEvent()

typeDef(Awbject, true):
    score = int:
        set:
            scoreEvent.invoke(value)
        get:
            return result

Awbject.construct(false):
    _: echo "Created an Awbject"

proc scored(score: int) = echo "Score: " & $score

proc laugh(score: int) =
    echo "Laughing " & $score & " Times"
    for i in 0..score:
        echo "Laugh"

scoreEvent.add(scored)
scoreEvent.add(laugh)

var awbject = initAwbject()
awbject.score = 11

scoreEvent.remove(scored)


awbject.score = 5