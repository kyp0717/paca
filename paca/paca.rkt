#lang racket

;;; import dependencies
(require yaml
         net/http-easy)
;;; yaml
(define paper (file->yaml "/home/emacs/rkt/paper.yml"))

;;; credential
(define key (hash-ref paper "key"))
(define secret (hash-ref paper "secret"))
(define cred (hasheq 'APCA-API-KEY-ID key
                     'APCA-API-SECRET-KEY secret))

;;; url
(define url-clock  (hash-ref paper "clock"))
(define url-orders  (hash-ref paper "orders"))

;;; Paca Clock

(define make-clock
  (lambda (auth url)
    (get url #:headers auth)))

(define paca/get-clock (make-clock cred url-clock))

;;; Request Clock
(response-json (get clock-url #:headers cred))
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


