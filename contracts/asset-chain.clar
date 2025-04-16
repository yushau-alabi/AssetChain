;; Title: AssetChain - Tokenized Real-World Asset Platform
;; 
;; Summary:
;; A comprehensive smart contract platform for fractionalized ownership of real-world assets 
;; on Bitcoin L2, with dividend distribution, governance proposals, and KYC compliance.
;;
;; Description:
;; AssetChain enables the tokenization of high-value assets into semi-fungible tokens,
;; allowing for fractional ownership, governance voting, and dividend distribution.
;; The platform incorporates regulatory compliance through configurable KYC requirements,
;; price oracles for accurate valuations, and an on-chain governance system that
;; empowers token holders to participate in key decisions about the underlying assets.
;; Built on Stacks for Bitcoin L2 compatibility and security.

;; Constants

;; Administrative
(define-constant contract-owner tx-sender)

;; Error codes
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-listed (err u102))
(define-constant err-invalid-amount (err u103))
(define-constant err-not-authorized (err u104))
(define-constant err-kyc-required (err u105))
(define-constant err-vote-exists (err u106))
(define-constant err-vote-ended (err u107))
(define-constant err-price-expired (err u108))
(define-constant err-invalid-uri (err u110))
(define-constant err-invalid-value (err u111))
(define-constant err-invalid-duration (err u112))
(define-constant err-invalid-kyc-level (err u113))
(define-constant err-invalid-expiry (err u114))
(define-constant err-invalid-votes (err u115))
(define-constant err-invalid-address (err u116))
(define-constant err-invalid-title (err u117))

;; Configuration limits
(define-constant MAX-ASSET-VALUE u1000000000000) ;; 1 trillion
(define-constant MIN-ASSET-VALUE u1000) ;; 1 thousand
(define-constant MAX-DURATION u144) ;; ~1 day in blocks
(define-constant MIN-DURATION u12) ;; ~1 hour in blocks
(define-constant MAX-KYC-LEVEL u5)
(define-constant MAX-EXPIRY u52560) ;; ~1 year in blocks

;; SFTs per asset
(define-constant tokens-per-asset u100000)

;; Data Maps

;; Asset registry
(define-map assets 
    { asset-id: uint }
    {
        owner: principal,
        metadata-uri: (string-ascii 256),
        asset-value: uint,
        is-locked: bool,
        creation-height: uint,
        last-price-update: uint,
        total-dividends: uint
    }
)

;; Token ownership records
(define-map token-balances
    { owner: principal, asset-id: uint }
    { balance: uint }
)

;; KYC compliance registry
(define-map kyc-status
    { address: principal }
    { 
        is-approved: bool,
        level: uint,
        expiry: uint 
    }
)

;; Governance proposals
(define-map proposals
    { proposal-id: uint }
    {
        title: (string-ascii 256),
        asset-id: uint,
        start-height: uint,
        end-height: uint,
        executed: bool,
        votes-for: uint,
        votes-against: uint,
        minimum-votes: uint
    }
)

;; Voting registry
(define-map votes
    { proposal-id: uint, voter: principal }
    { vote-amount: uint }
)

;; Dividend claim tracker
(define-map dividend-claims
    { asset-id: uint, claimer: principal }
    { last-claimed-amount: uint }
)

;; Oracle price feeds
(define-map price-feeds
    { asset-id: uint }
    {
        price: uint,
        decimals: uint,
        last-updated: uint,
        oracle: principal
    }
)

;; Input Validation Functions

(define-private (validate-asset-value (value uint))
    (and 
        (>= value MIN-ASSET-VALUE)
        (<= value MAX-ASSET-VALUE)
    )
)

(define-private (validate-duration (duration uint))
    (and 
        (>= duration MIN-DURATION)
        (<= duration MAX-DURATION)
    )
)

(define-private (validate-kyc-level (level uint))
    (<= level MAX-KYC-LEVEL)
)

(define-private (validate-expiry (expiry uint))
    (and 
        (> expiry stacks-block-height)
        (<= (- expiry stacks-block-height) MAX-EXPIRY)
    )
)

(define-private (validate-minimum-votes (vote-count uint))
    (and 
        (> vote-count u0)
        (<= vote-count tokens-per-asset)
    )
)

(define-private (validate-metadata-uri (uri (string-ascii 256)))
    (and 
        (> (len uri) u0)
        (<= (len uri) u256)
    )
)

;; Helper Functions

(define-private (get-next-asset-id)
    (default-to u1
        (get-last-asset-id)
    )
)

(define-private (get-next-proposal-id)
    (default-to u1
        (get-last-proposal-id)
    )
)

(define-private (get-last-asset-id)
    none
)

(define-private (get-last-proposal-id)
    none
)

;; Asset Management Functions

(define-public (register-asset 
    (metadata-uri (string-ascii 256)) 
    (asset-value uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (validate-metadata-uri metadata-uri) err-invalid-uri)
        (asserts! (validate-asset-value asset-value) err-invalid-value)

        (let 
            ((asset-id (get-next-asset-id)))
            (map-set assets
                { asset-id: asset-id }
                {
                    owner: contract-owner,
                    metadata-uri: metadata-uri,
                    asset-value: asset-value,
                    is-locked: false,
                    creation-height: stacks-block-height,
                    last-price-update: stacks-block-height,
                    total-dividends: u0
                }
            )
            (map-set token-balances
                { owner: contract-owner, asset-id: asset-id }
                { balance: tokens-per-asset }
            )
            (ok asset-id)
        )
    )
)

;; Dividend Functions

(define-public (claim-dividends (asset-id uint))
    (let
        (
            (asset (unwrap! (get-asset-info asset-id) err-not-found))
            (balance (get-balance tx-sender asset-id))
            (last-claim (get-last-claim asset-id tx-sender))
            (total-dividends (get total-dividends asset))
            (claimable-amount (/ (* balance (- total-dividends last-claim)) tokens-per-asset))
        )
        (asserts! (> claimable-amount u0) err-invalid-amount)
        (ok (map-set dividend-claims
            { asset-id: asset-id, claimer: tx-sender }
            { last-claimed-amount: total-dividends }
        ))
    )
)