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

;;; Generic request
(define (paca/get url)
  (get url
       #:headers cred))

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


(define (buy url 
             cred
             order)
  (post url
        #:headers cred
        #:json order))


;;; Paca Clock
(define req (get post url)


;;; test
(response-json (get clock-url
                    #:headers cred))

(define aapl
  (paca/create-order #:ticker "AAPL"
                     #:qty "10"
                     #:side "buy"
                     #:type "market"
                     #:time_in_force "day"
                     ))

(define order
  '((symbol . "AAPL")
    (qty . "10")
    (side . "buy")
    (type . "market")
    (time_in_force . "day")))

(response-json (buy url-orders cred aapl))

