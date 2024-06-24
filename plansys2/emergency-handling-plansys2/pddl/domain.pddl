(define 
	(domain emergency-handling)

	(:requirements :strips :typing :negative-preconditions :durative-actions :fluents)

	(:types place box carrier agent person content location)

	(:predicates
		(at_box ?b - box ?l - location)
		(at_carrier ?c - carrier ?l - location)
		(at_agent ?a - agent ?l - location)
		(at_content ?c - content ?l - location)
		(at_person ?p - person ?l - location)
		(empty ?b - box)
		(contains ?b - box ?c - content)
		(need ?p - person ?c - content)
		(available ?p - place ?c - carrier)
		(on ?b - box ?c - carrier)
		(of ?p - place ?c - carrier)
		(loadable ?b - box)
		(free-agent ?a - agent)
	)

	(:durative-action fill
		:parameters  (?b - box ?d - location ?c - content ?cr - carrier ?a - agent)
		:duration (= ?duration 1)
		:condition (and 
            (at start (free-agent ?a))
			(at start (empty ?b))
            (over all (loadable ?b))
			(over all (at_carrier ?cr ?d))
			(over all (at_box ?b ?d))
			(over all(at_agent ?a ?d))
		)
		:effect (and
            (at start (not(free-agent ?a)))
			(at end (contains ?b ?c))
            (at end (not (empty ?b)))
            (at end (free-agent ?a))
        )
	)

	(:durative-action empty-box
		:parameters (?b - box ?c - content ?ep - location ?p - person ?cr - carrier ?a - agent)
		:duration (= ?duration 1)
		:condition (and
		    (at start (free-agent ?a))
		    (at start (contains ?b ?c))
			(over all (at_person ?p ?ep))
			(over all (at_agent ?a ?ep))
			(over all (at_carrier ?cr ?ep))
			(over all (on ?b ?cr))
			(over all (need ?p ?c))
		)
		:effect (and 
            (at start (not(free-agent ?a)))
            (at start (not (contains ?b ?c)))
			(at end (empty ?b))
			(at end (not (need ?p ?c)))
            (at end (free-agent ?a))
        )
	)
	
	(:durative-action load-box
		:parameters (?b - box ?c - carrier ?a - agent ?p - place ?l - location)
		:duration (= ?duration 2)
		:condition (and 
            (at start (free-agent ?a))
			(over all (at_box ?b ?l))
			(over all(at_carrier ?c ?l))
			(over all (at_agent ?a ?l))
			(over all (of ?p ?c))
			(at start (available ?p ?c))
			(at start(not (on ?b ?c)))
			(at start(loadable ?b))
		)
		:effect (and
            (at start (not(free-agent ?a)))
			(at end (on ?b ?c))
			(at end (not (loadable ?b)))
			(at end (not (available ?p ?c)))
            (at end (free-agent ?a))
		)
	)

	(:durative-action unload-box
		:parameters (?b - box ?cr - carrier ?a - agent ?p - place ?ep - location)
		:duration (= ?duration  2 )
		:condition (and 
            (at start (free-agent ?a))
			(at start (on ?b ?cr))
			(at start (empty ?b))
			(at start (not (loadable ?b)))
			(over all (at_carrier ?cr ?ep))
			(over all (at_agent ?a ?ep))
			(at start (not (available ?p ?cr)))
		)
		:effect (and
            (at start (not(free-agent ?a)))
			(at end (not(on ?b ?cr)))
			(at end (loadable ?b))
			(at end (at_box ?b ?ep))
			(at end (available ?p ?cr))
            (at end (free-agent ?a))
		)
	)

	(:durative-action move-to-need
		:parameters (?p - person ?from - location ?to - location ?c - content ?b - box ?cr - carrier ?a - agent)
		:duration (= ?duration 3)
		:condition (and 
            (at start (free-agent ?a))
			(at start (at_carrier ?cr ?from))
            (at start (at_agent ?a ?from))
			(over all (on ?b ?cr))
			(over all (at_person ?p ?to))
			(over all (contains ?b ?c))
			(over all (need ?p ?c))
		)
		:effect (and 
            (at start (not(free-agent ?a)))
			(at start (not (at_carrier ?cr ?from)))
			(at start (not (at_agent ?a ?from)))
			(at end (at_agent ?a ?to))
			(at end (at_carrier ?cr ?to))
            (at end (free-agent ?a))
		)
	)

	(:durative-action move
		:parameters (?from - location ?to - location ?a - agent ?cr - carrier)
		:duration (= ?duration 3)
		:condition (and
            (at start (free-agent ?a))
			(at start (at_agent ?a ?from))
			(at start (at_carrier ?cr ?from))
		)
		:effect (and
            (at start (not (free-agent ?a)))
			(at start (not (at_agent ?a ?from)))
			(at start (not (at_carrier ?cr ?from)))
			(at end (at_agent ?a ?to))
			(at end (at_carrier ?cr ?to))
            (at end (free-agent ?a))
		)
	)	

	(:durative-action move-agent
		:parameters (?from - location ?to - location ?a - agent)
		:duration (= ?duration 3)
		:condition (and
            (at start (free-agent ?a))
			(at start (at ?a ?from))
		)
		:effect (and
            (at start (not(free-agent ?a)))
			(at start (not (at ?a ?from)))
			(at start (increase path-cost  15))
			(at end (at ?a ?to))
            (at end (free-agent ?a))
		)
	)
)
