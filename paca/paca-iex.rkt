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
(define stklist '("AMD" "MSFT"))
(define curr:stklist (make-parameter (map string->symbol stklist)))
(define subscribe:quotes 
  (jsexpr->string (hasheq 'action "subscribe" 'quotes stklist)))

;;; subscribe to market data stream for stock quotes
(ws-send! iex:con subscribe:quotes)
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
(define (get-stk-price ticker)
  (let* ([stock-quote (extract-quote)]
         [key (car (hash-keys stock-quote))] )
         (cond
           [(eq? ticker key) stock-quote]
           [else (get-stock-price ticker)])))

(get-stk-price 'MSFT)
(get-stk-price 'AMD)

                           

;;; todo:  build stock table
;;;; extract and dump quotes to table
(define curr:stkdata (make-parameter (make-hasheq)))
;; initialize stocktable
;; todo: initialize date/time and price to yesterday close
(for ([k1 stklist])
  (let ([k (string->symbol k1)])
    (hash-set! (curr:stkdata) k (list '("000" 111 )))))

(define (add-price hash key item)
  (hash-update hash key (curry cons item) '()))

;;;; append stock data to table
(define (add-stk)   
  (for ([ticker (curr:stklist)])
    (let ([price (get-stk-price ticker)])
      (add-price (curr:stkdata) key price))))

(define (extend-stkdata n)
  (define ticker (car (curr:stkdata)))
  ()
  (if )
  (thread let loop ()
    ))


;;; close conn
(ws-conn-closed? iex:con)
(ws-close! iex:con)

