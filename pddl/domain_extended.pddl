(define
    (domain emergency)
    (:requirements :strips :typing :durative-actions :fluents)

    (:types
            location - object           ;luoghi in cui possono trovarsi persone box ecc
            box - movable               ;cassette da riempire con gli oggetti da trasportare
            person - fixed              ;persone a cui consegnare oggetti
            carrier - movable           ;vettori su cui i robot caricano le cassette
            agent - movable             ;robot che eseguono le azioni
            content - movable           ;il contenuto inseribile nelle box
            carrierplace - object       ;per modellare i posti disponibili sui carriers
            movable - locatable         ;per modellare oggetti che si muovono
            fixed - locatable           ;per modellare oggetti fissati ovvero non possono muoversi dalla loro posizione
    )

    (:predicates
        (empty ?b - box)                                ;la scatola è vuota o meno
        (carrierPlace ?p - carrierplace ?c - carrier)   ;posto appartiene al vettore o meno
        (availablePlace ?p - carrierplace)              ;posto libero o meno
        (boxOnPlace ?b - box ?p - carrierplace)         ;box sul carrier o meno
        (at ?o - locatable ?l - location)               ;un oggetto si trova in una location o meno
        (has ?p - person ?c - content)                  ;la persona possiede il content o meno
        (need  ?p - person ?c - content)                ;la persona ha bisogno del content o meno
        (inBox ?b - box ?c - content)                   ;la box contiene il content o meno
        (hasSomething ?p - person)                      ;la persona possiede almeno una risorsa tra quelle di cui ha bisogno o meno
        (needAll ?p - person)                           ;la persona ha bisogno di tutte le risorse recapitate per ritenersi soddisfatta o meno
        (needSomething ?p - person)                     ;la persona ha bisogno di almeno una risorsa recapitata tra quelle di cui ha bisogno per ritenersi soddisfatta o meno
        (fullPlace ?p - carrierplace)                   ;il posto è occupato o meno
        (freeAgent ?g - agent)                          ;indica se l'agent g è libero
    )

    (:functions
        (content_weight ?c - content)
        (fill_duration)
        (move_duration)
        (empty_duration)
        (load_duration)
    )


    (:durative-action fill
        :parameters (?a - agent ?b - box ?c - content ?l - location)
        :duration (= ?duration (* (content_weight ?c) (fill_duration)))
        :condition (and
                        (at start (freeAgent ?a))
                        (at start (empty ?b))
                        (over all (at ?a ?l))
                        (over all (at ?b ?l))
                        (over all (at ?c ?l))
                   )
        :effect    (and
                        (at start (not(freeAgent ?a)))
                        (at start (not(empty ?b)))
                        (at end (inBox ?b ?c))
                        (at end (freeAgent ?a))
                   )
    )


    (:durative-action move
        :parameters (?a - agent ?c - carrier ?from ?to - location)
        :duration (= ?duration (move_duration))
        :condition (and
                        (at start (freeAgent ?a))
                        (at start (at ?a ?from))
                        (at start (at ?c ?from))
                   )
        :effect    (and
                        (at start (not(freeAgent ?a)))
                        (at start (not(at ?a ?from)))
                        (at start (not(at ?c ?from)))
                        (at end (at ?a ?to)))
                        (at end (at ?c ?to)))
                        (at end (freeAgent ?a))
                   )

    )

    (:durative-action empty
        :parameters (?a - agent ?b - box ?c - content ?p - person ?l - location)
        :duration (= ?duration (* (content_weight ?c) (empty_duration)))
        :condition (and
                        (at start (freeAgent ?a))
                        (at start (inBox ?b ?c))
                        (at start (need ?p ?c))
                        (over all (at ?a ?l))
                        (over all (at ?b ?l))
                        (over all (at ?p ?l))
                        (over all (needAll ?p))
                   )
        :effect    (and
                        (at start (not(freeAgent ?a)))
                        (at start (empty ?b))
                        (at start (not (need ?p ?c)))
                        (at end (not(inBox ?b ?c)))
                        (at end (has ?p ?c))
                        (at end (freeAgent ?a))
                   )
    )

    (:durative-action empty
                :parameters (?a - agent ?b - box ?c - content ?p - person ?l - location)
                :duration (= ?duration (* (content_weight ?c) (empty_duration)))
                :condition (and
                                (at start (freeAgent ?a))
                                (at start (inBox ?b ?c))
                                (at start (need ?p ?c))
                                (over all (at ?a ?l))
                                (over all (at ?b ?l))
                                (over all (at ?p ?l))
                                (over all (needSomething ?p))
                           )
                :effect    (and
                                (at start (not(freeAgent ?a)))
                                (at start (empty ?b))
                                (at start (not (need ?p ?c)))
                                (at start (not (needSomething ?p)))
                                (at end (not(inBox ?b ?c)))
                                (at end (hasSomething ?p))
                                (at end (freeAgent ?a))
                           )
    )

    (:durative-action load
            :parameters (?a - agent ?c - carrier ?p - carrierplace ?b - box ?l - location)
            :duration (= ?duration (load_duration))
            :condition (and
                            (at start (freeAgent ?a))
                            (over all (at ?a ?l))
                            (over all (at ?c ?l))
                            (over all (at ?b ?l))
                            (over all (carrierPlace ?p ?c))
                            (at start (availablePlace ?p))
                       )
            :effect    (and
                            (at start (not(freeAgent ?a)))
                            (at start (not(availablePlace ?p)))
                            (at start (fullPlace ?p))
                            (at end (not(at ?b ?l)))
                            (at end (boxOnPlace ?b ?p))
                            (at end (freeAgent ?a))
                       )

    )

    (:durative-action unload
            :parameters (?a - agent ?c - carrier ?p - carrierplace ?b - box ?l - location)
            :duration (= ?duration (load_duration))
            :condition (and
                            (at start (freeAgent ?a))
                            (at start (boxOnPlace ?b ?p)
                            (at start (fullPlace ?p))
                            (over all (at ?a ?l))
                            (over all (at ?c ?l))
                            (over all (carrierPlace ?p ?c))
                       )
            :effect    (and
                            (at start (not(freeAgent ?a)))
                            (at start (not(fullPlace ?p)))
                            (at start(at ?b ?l))
                            (at start (availablePlace))
                            (at end (not(boxOnPlace ?b ?p)))
                            (at end (freeAgent ?a))
                       )

    )

)