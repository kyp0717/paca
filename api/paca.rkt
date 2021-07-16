#lang racket/base

;;; import dependencies
(require (prefix-in cred: (submod "credentials.rkt" cred))
         (prefix-in u: (submod "credentials.rkt" urls))
         (prefix-in net: net/http-easy ))

(provide get-clock)
;;; Paca Clock
(define (get-clock)
  (net:get (u:clock) #:headers (cred:auth-api)))

;;; Order
(define (order:make
                  #:ticker tk
                  #:qty qt
                  #:side sd
                  #:type tp
                  #:time_in_force tif)
 (hasheq 'symbol tk
         'qty qt
         'side sd
         'type tp
         'time_in_force tif))

(define (order:send order)
  (net:post (u:orders)
          #:headers (cred:auth-api)
          #:json order))

;;; Position 
;; (define (pos:get ticker)
;;   (define u (string->append u:position ticker))
;;   (net:get u #:headers  (cred:auth-api)))

;; ;; close a position (liquidate)
;; (define (pos:delete ticker)
;;   (define u (string->append u:position ticker))
;;   (net:delete u #:headers  (cred:auth-api)))

;;; Account
;;




;;; Assets
