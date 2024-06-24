(define
    (problem problem2)
    (:domain emergency)

  (:objects
       a1 a2 - agent
       c1 c2 - carrier
       depot l1 l2 l3 l4 l5 - location
       food medicine tools - content
       place1 place2 place3 place4 - carrierplace
       b1 b2 b3 - box
       p1 p2 p3 p4 p5 p6 - person
  )

  (:init
       (empty b1)
       (empty b2)
       (empty b3)

       (availablePlace place1)
       (availablePlace place2)
       (availablePlace place3)
       (availablePlace place4)

       (at a1 depot)
       (at a2 depot)
       (at c1 depot)
       (at c2 depot)
       (at b1 depot)
       (at b2 depot)
       (at b3 depot)
       (at food depot)
       (at medicine depot)
       (at tools depot)
       (at p1 l1) ;ci serve garantire che p1 e p2 siano nello stesso luogo e che gli altri siano in luoghi diversi
       (at p2 l1)
       (at p3 l2)
       (at p4 l3)
       (at p5 l4)
       (at p6 l5)

       (carrierPlace place1 c1) ;le capacità dei carrier sono di 2
       (carrierPlace place2 c1)
       (carrierPlace place3 c2)
       (carrierPlace place4 c2)

       (need p1 food)  ;p1 needs food or tools
       (need p1 tools)
       (need p2 medicine) ;p2 needs medicine
       (need p3 medicine) ;p3 needs medicine
       (need p4 medicine) ;p4 need medicine and food
       (need p4 food)
       (need p5 medicine) ;p5 and p6 needs everything.
       (need p5 food)
       (need p5 tools)
       (need p6 medicine)
       (need p6 food)
       (need p6 tools)

       (needSomething p1) ;ci basta che abbia uno tra food e tools
       (needAll p2)
       (needAll p3)
       (needAll p4)
       (needAll p5)
       (needAll p6)
)

  (:goal (and
    (hasSomething p1)
    (has p2 medicine)

    (has p3 medicine)

    (has p4 medicine)
    (has p4 food)

    (has p5 food)
    (has p5 medicine)
    (has p5 tools)

    (has p6 food)
    (has p6 medicine)
    (has p6 tools))
  )

)