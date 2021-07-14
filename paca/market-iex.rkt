#lang racket/base

;;; import dependencies
(require (prefix-in c: (submod "./credentials.rkt" cred))
         (prefix-in u: (submod "./credentials.rkt"  urls))
         relation/function
         racket/hash
         racket/set
         racket/pretty
         racket/match
         net/http-easy
         net/url
         json
         net/rfc6455)

;;; connect and authenticate
;; the connection "iex" will be come live after authenticate
(define protocol 'rfc6455)
(define iex:con (ws-connect (string->url (u:iex)) #:protocol protocol))
(define curr:con (make-parameter iex:con))
(ws-recv iex:con)

;; authenticate to stream (NOT the API)
(ws-send! iex:con (c:auth-stream))
(ws-recv iex:con)

;;; build request list of tickers
(define stocklist '("AMD" "MSFT"))
(define curr:stocklist (make-parameter (map string->symbol stocklist)))
(define subscribe/quotes 
  (jsexpr->string (hasheq 'action "subscribe" 'quotes stocklist)))

;;; subscribe market data stream for quotes
(ws-send! iex:con subscribe/quotes)
(ws-recv iex:con)

;;; helper functions: extract quotes from stream
(define (extract-quote)
  (let* ([q (ws-recv (curr:con) )] ;; a string is returned
         [q/heq (car (string->jsexpr q))]
         [heq (make-hasheq)]
         [ticker (string->symbol (hash-ref q/heq 'S))] 
         [price (hash-ref q/heq 'ap)]
         [timestamp (hash-ref q/heq 't)])
    (hash-set! heq ticker (list timestamp price))
    heq))
  
(extract-quote)

;; this is a recursive fn because we need to make frequent request
;; to the stream until the ticker of interest is provided
(define (get-stock-price ticker)
  (let* ([stock-quote (extract-quote)]
         [key (car (hash-keys stock-quote))] )
         (cond
           [(eq? ticker key) stock-quote]
           [else (get-stock-price ticker)])))

(get-stock-price 'MSFT)
(get-stock-price 'AMD)

                           

;;; helper fn: build stock table
;;;; extract and dump quotes to table
(define curr:stocktable (make-parameter (make-hasheq)))
;; initialize stocktable
;; todo: initialize date/time and price to yesterday close
(for ([k1 stocklist])
  (let ([k (string->symbol k1)])
    (hash-set! (curr:stocktable) k (list '("000" 111 )))))

(define (add-price hash key item)
  (hash-update hash key (curry cons item) '()))

;;;; append to table
(define (add-stock)   
  (for ([ticker (curr:stocklist)])
    (let ([price (get-stock-price ticker)])
      (add-price (curr:stocktable) key price))))

;;; help fn: get pnl

;;; mainloop -- algo begin
;;; close conn
(ws-conn-closed? iex:con)
(ws-close! iex:con)

