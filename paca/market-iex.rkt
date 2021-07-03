#lang racket/base

;;; import dependencies
(require "credentials.rkt"
         racket/hash
         racket/set
         racket/pretty
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
(define current-conn (make-parameter iex))
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

(define (extract-quote)
  (let* ([q (ws-recv (current-conn) )] ;; a string is returned
         [q/heq (car (string->jsexpr q))]
         [heq (make-hasheq)]
         [ticker (string->symbol (hash-ref q/heq 'S))] 
         [price (hash-ref q/heq 'ap)]
         [timestamp (hash-ref q/heq 't)])
    (hash-set! heq ticker (list timestamp price))
    heq))
  
(extract-quote)


(define (get-stock s)
  (let* ([q (extract-quote)]
         [k (car (hash-keys q))]
         [ticker (string->symbol s)])
         (cond
           [(eq? ticker k) q]
           [else (get-stock s)])))

(get-stock "MSFT")

                           

(define (make-stk-tbl stk-list)
  (define heq (make-hasheq))
  (for/list ([s stk-list])
    (define stk (get-stock s))
    (hash-set! heq
                  (car (hash-keys stk))
                  (car (hash-values stk))))
  heq)



;;; test hash union
(define main-table (make-stk-tbl tickers))
(define child-table (make-stk-tbl tickers))


(hash-intersect main-table
                child-table
                #:combine/key
                (λ (k v1 v2) (list v1 v2)))


(define (update-tbl maintbl childtbl)
  (define heq (make-hasheq))
  (define ks (hash-keys maintbl))
  (for/list ([k ks])
    (define v1 (hash-ref maintbl k))
    (define v2 (hash-ref childtbl k))
    (hash-update! maintbl k
                  (set-add! (list v1 v2)))
  heq))

(define (update-tbl2 maintbl childtbl)
  (define ks (hash-keys maintbl))
  (for/list ([k ks])
    (define v1 (hash-ref maintbl k))
    (define v2 (hash-ref childtbl k))
    (cond
      [(= (length v1) 0) 
       (hash-set! maintbl k (list v2))]
      [(= (length v1) 1) 
       (hash-set! maintbl k (list v1 v2))]
      [(> (length v1) 5)
       (hash-set! maintbl k (cons (cdr v1) v2))]
      [(> (length v1) 1)
       (hash-set! maintbl k (cons v1 v2))]))
  maintbl)


(define (update-tbl2 maintbl childtbl)
  (define ks (hash-keys maintbl))
  (for/list ([k ks])
    (define v1 (hash-ref maintbl k))
    (define v2 (hash-ref childtbl k))
    (cond  
      [(= (length v1) 0) 
       (hash-set! maintbl k (list v2))]
      [(= (length v1) 1) 
       (hash-set! maintbl k (cons v1 v2))] ))
   maintbl)


(define m1 child-table)
(update-tbl2 m1 child-table)




(define m1 child-table)
(update-tbl2 m1 child-table)


(define hash1 #('A 1))(define m1 (make-hasheq))

(pretty-print main-table)

;;; example
(define mt '())
(define h1 (list 'a 111 222))
(define h2 (list 'b 444 333))

(define h1 (hash 'a  '("aa" 11)
                   'b  '("bb" 22)))

(define h2 (hash 'a  '("aa1" 11.11)
                   'b  '("bb1" 22.11)))





(define (update-tbl2 maintbl childtbl)
  (define ks (hash-keys maintbl))
  (for/list ([k ks])
    (define v1 (hash-ref maintbl k))
    (define v2 (hash-ref childtbl k))
    (cond  
      [(= (length v1) 0) 
       (hash-set! maintbl k (list v2))]
      [(= (length v1) 2) 
       (hash-set! maintbl k (cons v1 v2))] ))
  maintbl)

(update-tbl2 h1 h2)



;; use flatten function
(define (append-quote nlst qt)
  (cond
    [(= (length nlst) 0) qt]
    [(<= (length nlst) 5) (cons nlst (list qt))]
    [(> (length nlst) 5) (cons (cdr nlst) qt)])))
    
