;; Entangled Particle Pair Management Contract

(define-data-var pair-counter uint u0)

(define-map entangled-pairs uint {
    creator: principal,
    node-a: (string-ascii 50),
    node-b: (string-ascii 50),
    creation-time: uint,
    status: (string-ascii 20)
})

(define-public (create-entangled-pair (node-a (string-ascii 50)) (node-b (string-ascii 50)))
    (let
        ((new-id (+ (var-get pair-counter) u1)))
        (map-set entangled-pairs new-id {
            creator: tx-sender,
            node-a: node-a,
            node-b: node-b,
            creation-time: block-height,
            status: "active"
        })
        (var-set pair-counter new-id)
        (ok new-id)
    )
)

(define-public (update-pair-status (pair-id uint) (new-status (string-ascii 20)))
    (let
        ((pair (unwrap! (map-get? entangled-pairs pair-id) (err u404))))
        (asserts! (is-eq tx-sender (get creator pair)) (err u403))
        (ok (map-set entangled-pairs pair-id
            (merge pair { status: new-status })))
    )
)

(define-read-only (get-entangled-pair (pair-id uint))
    (map-get? entangled-pairs pair-id)
)

(define-read-only (get-pair-count)
    (var-get pair-counter)
)
