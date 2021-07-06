#lang racket/base

;;; import dependencies
(require "credentials.rkt"
         relation/function
         racket/hash
         racket/set
         racket/pretty
         racket/match
         net/http-easy
         net/url
         json
         net/rfc6455)

(ws-conn-closed? iex)
(ws-close! iex)


;;; connect and authenticate
;; the connection "iex" will be come live after authenticate
(define protocol 'rfc6455)
;; connect
(define iex (ws-connect (string->url urliex) #:protocol protocol))
(define curr:conn (make-parameter iex))
(ws-recv iex)

;; authenticate
(ws-send! iex auth)
(ws-recv iex)

;;; build request list of tickers
(define stocklist '("AMD" "MSFT"))
(define current-stocklist (make-parameter (map string->symbol stocklist)))
(define subscribe/quotes 
  (jsexpr->string (hasheq 'action "subscribe" 'quotes stocklist)))

;;; subscribe market data stream for quotes
(ws-send! iex subscribe/quotes)
(ws-recv iex)

;;; helper functions: extract quotes from stream
(define (extract-quote)
  (let* ([q (ws-recv (curr:conn) )] ;; a string is returned
         [q/heq (car (string->jsexpr q))]
         [heq (make-hasheq)]
         [ticker (string->symbol (hash-ref q/heq 'S))] 
         [price (hash-ref q/heq 'ap)]
         [timestamp (hash-ref q/heq 't)])
    (hash-set! heq ticker (list timestamp price))
    heq))
  
;;(extract-quote)

;; this is a recursive fn because we need to make frequent request
;; to the stream until the ticker of interest is provided
(define (get-stock-price ticker)
  (let* ([stock-quote (extract-quote)]
         [key (car (hash-keys stock-quote))] )
         (cond
           [(eq? sym key) stock-quote]
           [else (get-stock sym)])))
;;(get-stock "MSFT")

                           
;;; helper fn: build stock table
;;;; extract and dump quotes to table
(define curr:stocktable (make-parameter (make-hasheq)))
;; initialize stocktable
;; todo: initialize date/time and price to yesterday close
(for/list (key (curr:stocklist))
  (hash-set! curr:stocklist key (list (list ("000" 111 )))))

(define (add-price hash key item)
  (hash-update hash key (curry cons item) '()))

;;;; append to table
(define (add-pricelist)   
  (for/list (ticker (curr:stocklist))
    (let [price (get-stock-price ticker)]
      (add-price (curr:stocktable) key price))))

;;; help fn: get pnl

;;; mainloop -- algo begin




