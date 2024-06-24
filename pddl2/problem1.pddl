(define
	(problem instance1)
	(:domain emergency-handling)
	(:objects
		b1 b2 b3 b4 b5 - box
		place1 place2 place3 place4 - place
		depot - depot
		l1 l2 - emergencyposition
		p1 p2 p3 - person
		a - agent
		c - carrier
		medicine food - content
	)
	(:init
		(empty b1)
		(empty b2)
		(empty b3)
		(empty b4)
		(empty b5)
		(loadable b1)
		(loadable b2)
		(loadable b3)
		(loadable b4)
		(loadable b5)
		(of place1 c)
		(of place2 c)
		(of place3 c)
		(of place4 c)
		(available place1 c)
		(available place2 c)
		(available place3 c)
		(available place4 c)
		(at c depot)
		(at a depot)
		(at b1 depot)
		(at b2 depot)
		(at b3 depot)
		(at b4 depot)
		(at b5 depot)
		(at p1 l1)
		(at p2 l1)
		(at p3 l2)
		(need p1 food)
		(need p1 medicine)
		(need p2 medicine)
		(need p3 food)
		(= (weight food) 5)
		(= (weight medicine) 3)
		(= (box-weight b1) 0)
		(= (box-weight b2) 0)
		(= (box-weight b3) 0)
		(= (box-weight b4) 0)
		(= (box-weight b5) 0)
		(= (carrier-weight c) 0)
        (= (path-cost) 0)
		
	)
	(:goal (and (not (need p1 food)) (not (need p1 medicine))(not (need p2 medicine)) (not (need p3 food))))

	(:metric minimize (path-cost)
    )
)