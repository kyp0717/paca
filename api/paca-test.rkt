#lang racket/base

(require rackunit
         net/http-easy
         "paca.rkt")


;;; Request Clock
(define clock 
  (response-json (get-clock)))
(check-pred hash? clock)  

;;; Test: Request Buy Apple
;; (define aapl
;;   (paca/create-order-req-body
;;                      #:ticker "AAPL"
;;                      #:qty "10"
;;                      #:side "buy"
;;                      #:type "market"
;;                      #:time_in_force "day"
;;                      ))

;; (define buy/apple (paca/order aapl))
;; (response-json buy/apple)

