#lang racket/base

;;; import dependencies
(require (prefix-in cr: (submod "credentials.rkt" cred))
         (prefix-in u: (submod "credentials.rkt" urls))
         (prefix-in net: net/http-easy ))

(define ky:get
  (net:get (curr-clock) #:headers (auth:api))

;;; import dependencies
(require (submod "credentials.rkt" urls))

(u:curr-clock)
;;; Paca Clock

(define make-clock
  (lambda (auth url)
    (net:get url #:headers auth)))

(define ky:get
  (net:get (curr-clock) #:headers (curr-auth:api))p

(define get-clock (make-clock cr:auth:api urls:url-clock))
(define get-clock (make-clock cred:auth:api cred:url-clock))

(get-clock)
;;; Order
(define (order-req
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

(define (order auth url)
 (lambda (ord)
    (post url
          #:headers auth
          #:json ord)))

(define paca/order (paca/make-order cred url-orders))

;;; Position 
(define (paca/create-order-req-body
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

(define (paca/make-order auth url)
 (lambda (ord)
    (post url
          #:headers auth
          #:json ord)))

(define paca/order (paca/make-order cred url-orders))






