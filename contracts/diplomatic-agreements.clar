;; Diplomatic Agreements Contract

(define-data-var agreement-counter uint u0)

(define-map diplomatic-agreements uint {
    party-a: principal,
    party-b: principal,
    agreement-text: (string-utf8 1000),
    status: (string-ascii 20),
    created-at: uint,
    last-updated: uint
})

(define-public (create-agreement (party-b principal) (agreement-text (string-utf8 1000)))
    (let
        ((new-id (+ (var-get agreement-counter) u1)))
        (map-set diplomatic-agreements new-id {
            party-a: tx-sender,
            party-b: party-b,
            agreement-text: agreement-text,
            status: "proposed",
            created-at: block-height,
            last-updated: block-height
        })
        (var-set agreement-counter new-id)
        (ok new-id)
    )
)

(define-public (update-agreement-status (agreement-id uint) (new-status (string-ascii 20)))
    (let
        ((agreement (unwrap! (map-get? diplomatic-agreements agreement-id) (err u404))))
        (asserts! (or (is-eq tx-sender (get party-a agreement)) (is-eq tx-sender (get party-b agreement))) (err u403))
        (ok (map-set diplomatic-agreements agreement-id
            (merge agreement {
                status: new-status,
                last-updated: block-height
            })))
    )
)

(define-read-only (get-agreement (agreement-id uint))
    (map-get? diplomatic-agreements agreement-id)
)

(define-read-only (get-agreement-count)
    (var-get agreement-counter)
)

