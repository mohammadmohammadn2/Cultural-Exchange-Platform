;; Network Node Synchronization Contract

(define-data-var node-counter uint u0)

(define-map network-nodes uint {
    node-id: (string-ascii 50),
    owner: principal,
    last-sync: uint,
    status: (string-ascii 20)
})

(define-public (register-node (node-id (string-ascii 50)))
    (let
        ((new-id (+ (var-get node-counter) u1)))
        (map-set network-nodes new-id {
            node-id: node-id,
            owner: tx-sender,
            last-sync: block-height,
            status: "active"
        })
        (var-set node-counter new-id)
        (ok new-id)
    )
)

(define-public (update-node-sync (node-id uint))
    (let
        ((node (unwrap! (map-get? network-nodes node-id) (err u404))))
        (asserts! (is-eq tx-sender (get owner node)) (err u403))
        (ok (map-set network-nodes node-id
            (merge node { last-sync: block-height })))
    )
)

(define-public (update-node-status (node-id uint) (new-status (string-ascii 20)))
    (let
        ((node (unwrap! (map-get? network-nodes node-id) (err u404))))
        (asserts! (is-eq tx-sender (get owner node)) (err u403))
        (ok (map-set network-nodes node-id
            (merge node { status: new-status })))
    )
)

(define-read-only (get-node (node-id uint))
    (map-get? network-nodes node-id)
)

(define-read-only (get-node-count)
    (var-get node-counter)
)
