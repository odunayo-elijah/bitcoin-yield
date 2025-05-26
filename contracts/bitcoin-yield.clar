;; Title: Bitcoin Layer-2 Yield Aggregator Protocol
;; Summary: A decentralized yield optimization protocol for Bitcoin-native DeFi
;; Description: Aggregates yield opportunities across Bitcoin Layer-2 protocols,
;;              enabling users to maximize returns while maintaining Bitcoin's 
;;              security guarantees. Supports multi-protocol risk distribution 
;;              and automated yield compounding for optimal capital efficiency.

;; ERROR CONSTANTS

(define-constant ERR-UNAUTHORIZED (err u1))
(define-constant ERR-INSUFFICIENT-FUNDS (err u2))
(define-constant ERR-INVALID-PROTOCOL (err u3))
(define-constant ERR-WITHDRAWAL-FAILED (err u4))
(define-constant ERR-DEPOSIT-FAILED (err u5))
(define-constant ERR-PROTOCOL-LIMIT-REACHED (err u6))
(define-constant ERR-INVALID-INPUT (err u7))

;; PROTOCOL STORAGE

;; Maps protocol identifiers to their configuration and status
(define-map supported-protocols
  { protocol-id: uint }
  {
    name: (string-ascii 50),
    base-apy: uint,
    max-allocation-percentage: uint,
    active: bool,
  }
)

;; Tracks individual user deposits per protocol
(define-map user-deposits
  {
    user: principal,
    protocol-id: uint,
  }
  {
    amount: uint,
    deposit-time: uint,
  }
)

;; Aggregates total deposits per protocol for risk management
(define-map protocol-total-deposits
  { protocol-id: uint }
  { total-deposit: uint }
)

;; GLOBAL VARIABLES

(define-data-var total-protocols uint u0)

;; CONSTANTS

(define-constant CONTRACT-OWNER tx-sender)
(define-constant MAX-PROTOCOLS u5)
(define-constant MAX-ALLOCATION-PERCENTAGE u100)
(define-constant BASE-DENOMINATION u1000000)
(define-constant MAX-PROTOCOL-NAME-LENGTH u50)
(define-constant MAX-BASE-APY u10000) ;; 100% maximum APY
(define-constant MAX-DEPOSIT-AMOUNT u1000000000) ;; 1 billion base units
(define-constant BLOCKS-PER-YEAR u52596) ;; Approximate Stacks blocks per year

;; VALIDATION FUNCTIONS

(define-private (is-valid-protocol-id (protocol-id uint))
  (and (> protocol-id u0) (<= protocol-id MAX-PROTOCOLS))
)

(define-private (is-valid-protocol-name (name (string-ascii 50)))
  (and
    (> (len name) u0)
    (<= (len name) MAX-PROTOCOL-NAME-LENGTH)
  )
)

(define-private (is-valid-base-apy (base-apy uint))
  (<= base-apy MAX-BASE-APY)
)

(define-private (is-valid-allocation-percentage (percentage uint))
  (and (> percentage u0) (<= percentage MAX-ALLOCATION-PERCENTAGE))
)

(define-private (is-valid-deposit-amount (amount uint))
  (and (> amount u0) (<= amount MAX-DEPOSIT-AMOUNT))
)

(define-private (is-contract-owner (sender principal))
  (is-eq sender CONTRACT-OWNER)
)

;; PROTOCOL MANAGEMENT

;; Adds a new yield protocol to the aggregator
;; Only contract owner can add protocols to maintain security
(define-public (add-protocol
    (protocol-id uint)
    (name (string-ascii 50))
    (base-apy uint)
    (max-allocation-percentage uint)
  )
  (begin
    (asserts! (is-contract-owner tx-sender) ERR-UNAUTHORIZED)
    (asserts! (is-valid-protocol-id protocol-id) ERR-INVALID-INPUT)
    (asserts! (is-valid-protocol-name name) ERR-INVALID-INPUT)
    (asserts! (is-valid-base-apy base-apy) ERR-INVALID-INPUT)
    (asserts! (is-valid-allocation-percentage max-allocation-percentage)
      ERR-INVALID-INPUT
    )
    (asserts! (< (var-get total-protocols) MAX-PROTOCOLS)
      ERR-PROTOCOL-LIMIT-REACHED
    )
    (map-set supported-protocols { protocol-id: protocol-id } {
      name: name,
      base-apy: base-apy,
      max-allocation-percentage: max-allocation-percentage,
      active: true,
    })
    (var-set total-protocols (+ (var-get total-protocols) u1))
    (ok true)
  )
)

;; Deactivates a protocol for risk management purposes
(define-public (deactivate-protocol (protocol-id uint))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR-UNAUTHORIZED)
    (asserts! (is-valid-protocol-id protocol-id) ERR-INVALID-INPUT)
    (map-set supported-protocols { protocol-id: protocol-id }
      (merge
        (unwrap! (map-get? supported-protocols { protocol-id: protocol-id })
          ERR-INVALID-PROTOCOL
        ) { active: false }
      ))
    (var-set total-protocols (- (var-get total-protocols) u1))
    (ok true)
  )
)

;; DEPOSIT MANAGEMENT

;; Deposits funds into a specified yield protocol
;; Enforces allocation limits to maintain risk distribution
(define-public (deposit
    (protocol-id uint)
    (amount uint)
  )
  (let (
      (protocol (unwrap! (map-get? supported-protocols { protocol-id: protocol-id })
        ERR-INVALID-PROTOCOL
      ))
      (current-total-deposits (default-to { total-deposit: u0 }
        (map-get? protocol-total-deposits { protocol-id: protocol-id })
      ))
      (max-protocol-deposit (/ (* (get max-allocation-percentage protocol) BASE-DENOMINATION) u100))
    )
    (asserts! (is-valid-protocol-id protocol-id) ERR-INVALID-INPUT)
    (asserts! (is-valid-deposit-amount amount) ERR-INVALID-INPUT)
    (asserts! (get active protocol) ERR-INVALID-PROTOCOL)
    (asserts!
      (<= (+ (get total-deposit current-total-deposits) amount)
        max-protocol-deposit
      )
      ERR-PROTOCOL-LIMIT-REACHED
    )
    (map-set user-deposits {
      user: tx-sender,
      protocol-id: protocol-id,
    } {
      amount: amount,
      deposit-time: stacks-block-height,
    })
    (map-set protocol-total-deposits { protocol-id: protocol-id } { total-deposit: (+ (get total-deposit current-total-deposits) amount) })
    (ok true)
  )
)