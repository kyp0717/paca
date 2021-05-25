#lang rack

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
(define (paca/get url)
  (get url #:headers cred))

;;; Paca Buy 
(define (paca/create-order
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


(define (paca/buy-order order)
  (post url-orders
        #:headers cred
        #:json order))

;;; Request Clock
(response-json (get clock-url #:headers cred)

(response-json (paca/get clock-url))

;;; Request Buy Apple
(define aapl
  (paca/create-order #:ticker "AAPL"
                     #:qty "10"
                     #:side "buy"
                     #:type "market"
                     #:time_in_force "day"
                     ))

(response-json (paca/buy-order aapl))

