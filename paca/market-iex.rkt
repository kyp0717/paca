
#lang racket/base

;;; import dependencies
(require "credentials.rkt"
         racket/match
         net/http-easy
         net/url
         json
         net/rfc6455)

;;; parameters for authenticate
(define auth
  (jsexpr->string  (hasheq 'action "auth" 'key key 'secret secret)))

(ws-conn-closed? iex)
(ws-close! iex)


;;; connect and authenticate
;; the connection "iex" will be come live after authenticate
(define protocol 'rfc6455)
;; connect
(define iex (ws-connect (string->url urliex) #:protocol protocol))
(ws-recv iex)

;; authenticate
(ws-send! iex auth)
(ws-recv iex)

;;; build request list of tickers
(define tickers '("AMD" "MSFT"))
(define quotes 
  (jsexpr->string (hasheq 'action "subscribe" 'quotes tickers)))

;;; subscribe market data stream for quotes
(ws-send! iex quotes)
(ws-recv iex)

;;; build table from stream
(define stocktable (make-hasheq))

(define (extract conn)
  (let* ([q (ws-recv conn )] ;; a string is returned
         [q/heq (car (string->jsexpr q))]
         [heq (make-hasheq)]
         [ticker (string->symbol (hash-ref q/heq 'S))] 
         [price (hash-ref q/heq 'ap)]
         [timestamp (hash-ref q/heq 't)])
    (hash-set! heq ticker (list timestamp price))
    heq))
  
(extract iex)

(define (get-stock conn s)
  (let* ([q (extract conn)]
         [k (car (hash-keys q))]
         [ticker (string->symbol s)])
         (cond
           [(eq? ticker k) q]
           [else (get-stock conn s)])))

(get-stock iex "MSFT")

                           
(define (make-stk-tbl conn stk-list)
  (define heq (make-hasheq))
  (for/list ([s stk-list])
    (define stk (get-stock conn s))
    (hash-set! heq
                  (car (hash-keys stk))
                  (car (hash-values stk))))
  heq)

(make-stk-tbl iex tickers)

    
     

     
    
  

