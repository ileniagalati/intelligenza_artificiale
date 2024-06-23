(define
    (domain emergency)
    (:requirements :strips :typing)

     (:types
        location - object           *luoghi in cui possono trovarsi persone, box ecc
        box - movable               *cassette da riempire con gli oggetti da trasportare
        person - fixed              *persone a cui consegnare oggetti
        carrier - movable           *vettori su cui i robot caricano le cassette
        agent - movable             *robot che eseguono le azioni
        content - movable           *il contenuto inseribile nelle box
        carrierplace - object       *per modellare i posti disponibili sui carriers
        movable - locatable         *per modellare oggetti che si muovono
        fixed - locatable           *per modellare oggetti fissati ovvero non possono muoversi dalla loro posizione
    )

    (:predicates
        (empty ?b - box)                            *la scatola è vuota o meno
        (carrierPlace ?p - place ?c - carrier)      *posto appartiene al vettore o meno
        (availablePlace ?p - place)                 *posto libero o meno
        (boxOnPlace ?b - box ?p - place)            *box sul carrier o meno
        (at ?o - locatable ?l - location)              *un oggetto si trova in una location o meno
        (has ?p - person ?c - content)              *la persona possiede il content o meno
        (need  ?p - person ?c - content)            *la persona ha bisogno del content o meno
        (inBox ?b - box ?c - content)               *la box contiene il content o meno
        (hasSomething ?p - person)                  *la persona possiede almeno una risorsa tra quelle di cui ha bisogno o meno
        (needAll ?p - person)                       *la persona ha bisogno di tutte le risorse recapitate per ritenersi soddisfatta o meno
        (needSomething ?p - person)                 *la persona ha bisogno di almeno una risorsa recapitata tra quelle di cui ha bisogno per ritenersi soddisfatta o meno
        (fullPlace ?p - place)                      *il posto è occupato o meno
       )

    (:action fill *riempire una empty box con un content
             :parameters (?a - agent ?b - box ?c - content ?l - location)
             :precondition (and
                (empty ?b)
                (at ?a ?l)
                (at ?b ?l)
                (at ?c ?l)
                )
             :effect (and
                 (not(empty ?b))
                 (inBox ?b ?c)
             )
        )

    (:action move *spostamento di un robot da una location a un'altra
         :parameters (?a - agent ?c - carrier ?from ?to - location)
         :precondition (and
            (at ?a ?from)
               (at ?c ?from))
         :effect (and
             (at ?a ?to)
             (at ?c ?to)
             (not (at ?a ?from))
             (not (at ?c ?from))
         )
     )

    (:action empty  *svuotare la box per consegnare le risorse a persone che richiedono la consegna di tutte le risorse che necessitano
             :parameters (?a - agent ?b - box ?c - content ?p - person ?l - location)
             :precondition (and
                (inBox ?b ?c)
                (at ?a ?l)
                (at ?b ?l)
                (at ?p ?l)
                (need ?p ?c)
                (needAll ?p) )
             :effect (and
                (not (inBox ?b ?c))
                (empty ?b)
                (not (need ?p ?c))
                (has ?p ?c))
        )

    (:action emptyAtLeastOne  *svuotare la box per consegnare le risorse a persone che richiedono la consegna di almeno una tra tutte le risorse che necessitano
             :parameters (?a - agent ?b - box ?c - content ?p - person ?l - location)
             :precondition (and (inBox ?b ?c) (in ?a ?l) (in ?b ?l) (in ?p ?l) (need ?p ?c) (needSomething ?p))
             :effect (and (not (inBox ?b ?c)) (emptyBox ?b) (not (need ?p ?c)) (not (needSomething ?p)) (hasSomething ?p) )
        )


     (:action load  *caricare la box sul carrier per trasportarla in un'altra location
         :parameters (?a - agent ?c - carrier ?p - place ?b - box ?l - location)
         :precondition (and
            (at ?a ?l)
            (at ?c ?l)
            (at ?b ?l)
            (carrierPlace ?p ?c)
            (availablePlace ?p)
        )
         :effect (and
            (boxOnPlace ?b ?p)
            (not(at ?b ?l))
            (not(availablePlace ?p))
            (fullPlace ?p)
        )
    )


    (:action unload *scaricare la box dal carrier
         :parameters (?a - agent ?c - carrier ?p - place ?b - box ?l - location)
         :precondition (and
             (at ?a ?l)
             (at ?c ?l)
             (boxOnPlace ?b ?p)
             (carrierPlace ?p ?c)
             (fullPlace ?p)
         )
         :effect (and
            (not (boxOnPlace ?b ?p))
            (at ?b ?l)
            (not (fullPlace ?p))
            (availablePlace ?p)
        )
    )






