#lang racket/base

(require rackunit
         "paca.rkt")


;;; Request Clock
(response-json paca/get-clock)

;;; Test: Request Buy Apple
(define aapl
  (paca/create-order-req-body
                     #:ticker "AAPL"
                     #:qty "10"
                     #:side "buy"
                     #:type "market"
                     #:time_in_force "day"
                     ))

(define buy/apple (paca/order aapl))
(response-json buy/apple)

