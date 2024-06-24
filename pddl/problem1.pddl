(define
    (problem problem1)
    (:domain emergency)

    (:objects
        a - agent
        place1 place2 place3 place4 - carrierplace
        depot l1 l2 - location
        c - carrier
        p1 p2 p3 - person
        b1 b2 b3 b4 b5 - box
        food medicine tools - content
    )

    (:init
        (empty b1)
        (empty b2)
        (empty b3)
        (empty b4)
        (empty b5)

        (at a depot)
        (at c depot)
        (at b1 depot)
        (at b2 depot)
        (at b3 depot)
        (at b4 depot)
        (at b5 depot)
        (at tools depot)
        (at medicine depot)
        (at food depot)
        (at p1 l1)
        (at p2 l1)
        (at p3 l2)

        (availablePlace place1)
        (availablePlace place2)
        (availablePlace place3)
        (availablePlace place4)

        (carrierPlace place1 c)
        (carrierPlace place2 c)
        (carrierPlace place3 c)
        (carrierPlace place4 c)

        (need p1 food)
        (need p1 medicine)
        (need p2 medicine)
        (need p3 food)

        (needAll p1)
        (needAll p2)
        (needAll p3)
    )

    (:goal (and
        (has p1 food)
        (has p1 medicine)
        (has p2 medicine)
        (has p3 food))
      )
)



