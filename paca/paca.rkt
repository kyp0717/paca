#lang racket/base

;;; import dependencies
(require "cred.rkt"
         net/http-easy)

;;; Paca Clock

(define make-clock
  (lambda (auth url)
    (get url #:headers auth)))

(define paca/get-clock (make-clock cred url-clock))

;;; Request Clock	
(response-json paca/get-clock)

;;; Paca Buy
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

;;; Request Buy Apple
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


