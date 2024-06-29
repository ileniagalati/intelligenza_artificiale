(define
    (domain temporal_emergency)
    (:requirements :strips :typing :durative-actions :fluents)

    (:types
            location - object           ;luoghi in cui possono trovarsi i vari elementi del problema
            carrierplace - object       ;posti disponibili sui carriers
            locatable - object          ;per modellare gli oggetti localizzabili
            box - locatable             ;scatole da riempire con gli oggetti da trasportare
            agent - locatable           ;robot che eseguono le azioni
            content - locatable         ;il contenuto inseribile nelle scatole
            carrier - locatable         ;carrelli su cui i robot caricano le scatole
            person - locatable          ;persone a cui consegnare gli oggetti
    )

    (:predicates
        (at ?o - locatable ?l - location)               ;indica se un oggetto si trova in una location o meno
        (empty ?b - box)                                ;indica se la scatola è vuota o meno
        (inBox ?b - box ?c - content)                   ;indica se la scatola contiene il content o meno
        (boxOnPlace ?b - box ?p - carrierplace)         ;indica se la scatola è sul carrier o meno
        (carrierPlace ?p - carrierplace ?c - carrier)   ;indica se il posto appartiene al carrier o meno
        (availablePlace ?p - carrierplace)              ;indica se il posto è libero o meno
        (has ?p - person ?c - content)                  ;indica se la persona possiede il content o meno
        (hasSomething ?p - person)                      ;indica se la persona possiede almeno una risorsa tra quelle di cui ha bisogno o meno
        (need  ?p - person ?c - content)                ;indica se la persona ha bisogno del content o meno
        (needAll ?p - person)                           ;indica se la persona ha bisogno di tutte le risorse recapitate per ritenersi soddisfatta o meno
        (needSomething ?p - person)                     ;indica se la persona ha bisogno di almeno una risorsa recapitata tra quelle di cui ha bisogno per ritenersi soddisfatta o meno
        (freeAgent ?g - agent)                          ;indica se l'agente è libero o meno
    )

    (:functions
        (content_weight ?c - content)
        (box_weight ?b - box)
        (carrier_weight ?c - carrier)
        (fill_duration)
        (move_duration)
        (load_duration)
        (empty_duration)
    )


    ; nella location l, l'agente a riempie la box b con il contenuto c
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
                        (at end (increase (box_weight ?b) (content_weight ?c)))
                   )
    )


    ; l'agente a si sposta dalla location from alla location to con il carrier c
    (:durative-action move
        :parameters (?a - agent ?c - carrier ?from ?to - location)
        :duration (= ?duration (* (carrier_weight ?c) (move_duration)))
        :condition (and
                        (at start (freeAgent ?a))
                        (at start (at ?a ?from))
                        (at start (at ?c ?from))
                   )
        :effect    (and
                        (at start (not(freeAgent ?a)))
                        (at start (not(at ?a ?from)))
                        (at start (not(at ?c ?from)))
                        (at end (at ?a ?to))
                        (at end (at ?c ?to))
                        (at end (freeAgent ?a))
                   )

    )


    ; Nella location l, l'agente a carica la box b nel posto p del carrello c
    (:durative-action load
            :parameters (?a - agent ?c - carrier ?p - carrierplace ?b - box ?l - location)
            :duration (= ?duration (* (box_weight ?b) (load_duration)))
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
                            (at end (not(at ?b ?l)))
                            (at end (boxOnPlace ?b ?p))
                            (at end (freeAgent ?a))
                            (at end (increase (carrier_weight ?c) (box_weight ?b)))
                       )

    )


    ; Nella location l, l'agente a scarica la box b nel posto p dal carrello c
    (:durative-action unload
            :parameters (?a - agent ?c - carrier ?p - carrierplace ?b - box ?l - location)
            :duration (= ?duration (* (box_weight ?b) (load_duration)))
            :condition (and
                            (at start (freeAgent ?a))
                            (at start (boxOnPlace ?b ?p))
                            (at start (not(availablePlace ?p)))
                            (over all (at ?a ?l))
                            (over all (at ?c ?l))
                            (over all (carrierPlace ?p ?c))
                       )
            :effect    (and
                            (at start (not(freeAgent ?a)))
                            (at start(at ?b ?l))
                            (at start (availablePlace ?p))
                            (at end (not(boxOnPlace ?b ?p)))
                            (at end (freeAgent ?a))
                            (at end(decrease (carrier_weight ?c) (box_weight ?b)))
                       )

    )


    ; Nella location l, l'agente a svuota il contenuto c della box b e lo consegna alla persona p
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
                        (at end (decrease (box_weight ?b) (content_weight ?c)))
                   )
    )


    ; Nella location l, l'agente a svuota il contenuto c della box b e lo consegna alla persona p, la quale è quindi soddisfatta perchè possiede almeno una tra le cose di cui necessitava
    (:durative-action emptyAtLeastOne
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
                                (at end (decrease (box_weight ?b) (content_weight ?c)))
                           )
    )

)