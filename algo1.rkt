#lang racket

;;; import dependencies
(require (prefix-in iex (submod "./paca-iex.rkt"))
         (prefix-in pc: (submod "./paca.rkt"))
         relation/function
         racket/hash
         racket/set
         racket/match)

(define mkt:status )
(define algo (mkt:status pos:status)
  ;; if position greater than 5% loss, than close position
  ;; if mkt status is selloff or rally do this and position is trending with market (hold)
  ;; if mkt status is random and position is profitable, sell when gain is $100
  )

(module+ main
  (run-algo)
 )
