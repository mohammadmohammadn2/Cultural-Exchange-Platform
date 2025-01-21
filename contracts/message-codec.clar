;; Message Encoding and Decoding Contract

(define-data-var message-counter uint u0)

(define-map encoded-messages uint {
    sender: principal,
    recipient: (string-ascii 50),
    encoded-data: (buff 1024),
    timestamp: uint,
    status: (string-ascii 20)
})

(define-public (encode-message (recipient (string-ascii 50)) (message (string-utf8 1000)))
    (let
        ((new-id (+ (var-get message-counter) u1))
         (encoded (hash message)))
        (map-set encoded-messages new-id {
            sender: tx-sender,
            recipient: recipient,
            encoded-data: encoded,
            timestamp: block-height,
            status: "encoded"
        })
        (var-set message-counter new-id)
        (ok new-id)
    )
)

(define-public (update-message-status (message-id uint) (new-status (string-ascii 20)))
    (let
        ((message (unwrap! (map-get? encoded-messages message-id) (err u404))))
        (asserts! (or (is-eq tx-sender (get sender message)) (is-eq tx-sender (principal (get recipient message)))) (err u403))
        (ok (map-set encoded-messages message-id
            (merge message { status: new-status })))
    )
)

(define-read-only (get-encoded-message (message-id uint))
    (map-get? encoded-messages message-id)
)

(define-read-only (get-message-count)
    (var-get message-counter)
)
