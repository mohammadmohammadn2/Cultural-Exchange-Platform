;; Cultural Artifact Exchange Contract

(define-non-fungible-token cultural-artifact uint)

(define-data-var artifact-counter uint u0)

(define-map artifact-details uint {
    name: (string-ascii 100),
    description: (string-utf8 500),
    origin: principal,
    current-owner: principal,
    creation-date: uint,
    last-transferred: uint
})

(define-public (mint-artifact (name (string-ascii 100)) (description (string-utf8 500)))
    (let
        ((new-id (+ (var-get artifact-counter) u1)))
        (try! (nft-mint? cultural-artifact new-id tx-sender))
        (map-set artifact-details new-id {
            name: name,
            description: description,
            origin: tx-sender,
            current-owner: tx-sender,
            creation-date: block-height,
            last-transferred: block-height
        })
        (var-set artifact-counter new-id)
        (ok new-id)
    )
)

(define-public (transfer-artifact (artifact-id uint) (recipient principal))
    (let
        ((owner (unwrap! (nft-get-owner? cultural-artifact artifact-id) (err u404))))
        (asserts! (is-eq tx-sender owner) (err u403))
        (try! (nft-transfer? cultural-artifact artifact-id tx-sender recipient))
        (map-set artifact-details artifact-id
            (merge (unwrap! (map-get? artifact-details artifact-id) (err u404))
                { current-owner: recipient, last-transferred: block-height }))
        (ok true)
    )
)

(define-read-only (get-artifact-details (artifact-id uint))
    (map-get? artifact-details artifact-id)
)

(define-read-only (get-artifact-count)
    (var-get artifact-counter)
)

