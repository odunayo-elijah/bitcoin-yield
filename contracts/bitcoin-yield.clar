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