;; Quantum Channel NFT Contract

(define-non-fungible-token quantum-channel uint)

(define-data-var last-token-id uint u0)

(define-map token-metadata uint {
    name: (string-ascii 100),
    description: (string-utf8 500),
    creator: principal,
    entangled-pair-id: uint,
    creation-date: uint
})

(define-public (mint-quantum-channel (name (string-ascii 100)) (description (string-utf8 500)) (entangled-pair-id uint))
    (let
        ((token-id (+ (var-get last-token-id) u1)))
        (try! (nft-mint? quantum-channel token-id tx-sender))
        (map-set token-metadata token-id {
            name: name,
            description: description,
            creator: tx-sender,
            entangled-pair-id: entangled-pair-id,
            creation-date: block-height
        })
        (var-set last-token-id token-id)
        (ok token-id)
    )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (nft-transfer? quantum-channel token-id sender recipient)
)

(define-read-only (get-token-metadata (token-id uint))
    (map-get? token-metadata token-id)
)

(define-read-only (get-last-token-id)
    (var-get last-token-id)
)
