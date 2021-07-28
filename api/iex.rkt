#lang racket/base

;;; import dependencies
(require (prefix-in cd: (submod "../yaml/credentials.rkt" cred))
         (prefix-in url: (submod "../yaml/credentials.rkt"  urls))
         relation/function
         racket/hash
         racket/set
         racket/pretty
         racket/match
         net/http-easy
         net/url
         json
         net/rfc6455)

;;; export
(provide connect authenticate! subscribe-quotes get-price)

;;; connect and authenticate
;; the connection "iex" will be come live after authenticate
(define (connect)
  (define conn (ws-connect (string->url (url:iex)) #:protocol 'rfc6455))
  (ws-recv conn)
  conn)

;;; authenticate to stream (NOT the API)
(define (authenticate! conn)
  (unless (ws-conn-closed? conn)
    (ws-send! conn (cd:auth-stream)))
  (let* ([resp (ws-recv conn)]
         [js (car (string->jsexpr resp))]
         [T-msg (hash-ref js 'T)]
         [msg (hash-ref js 'msg)])
    (if (string=? msg "authenticated")
        (values msg (λ () #t))
        (values msg (λ () #f)))))


;; ;;; subscribe to market data stream for stock quotes
;; (define (sub-quotes conn auth stklist)
;;   (define subscription 
;;     (jsexpr->string (hasheq 'action "subscribe" 'quotes stklist)))
;;   (when (auth)
;;     (ws-send! conn subscription)
;;     (ws-recv conn)))

;;; subscribe to market data stream for stock quotes
(define (subscribe-quotes conn au ls)
  (define subs-json
    (jsexpr->string (hasheq 'action "subscribe" 'quotes ls)))
  (when (au)
    (ws-send! conn subs-json))
  (let* ([resp (ws-recv conn)]
         [js (car (string->jsexpr resp))]
         [msg (hash-ref js 'T)])
    (if (string=? msg "subscription")
        (values msg (λ () #t))
        (values msg (λ () #f)))))




;;; get price (use only after stream is live)
;; this function assume that there is subscription to stream
;; load data into sqlite
(define (get-price conn)
  (define q (ws-recv conn))
  (define q2 (car (string->jsexpr q)))
  (define ticker  (hash-ref q2 'S))
  (define price (hash-ref q2 'ap))
  (define timestamp (hash-ref q2 't))
  (list ticker price timestamp))




;; this is a recursive fn because we need to make frequent request
;; to the stream until the ticker of interest is provided
(define (get-price-list ticker)
  (let* ([stk-quote (extract-quote)]
         [key (car (hash-keys stk-quote))] )
         (cond
           [(eq? ticker key) stk-quote]
           [else (get-stk-price ticker)])))

;; (define lived? (ws-conn-closed? iex:con))
;; (provide get-stk-price lived?)

;; ;; (get-stk-price 'MSFT)
;; ;; (get-stk-price 'AMD)

;;; close conn
;; (ws-conn-closed? iex:con)
;; (ws-close! iex:con)

;;; ** DEPRECATED ** todo:  build stock table
;;;; extract and dump quotes to table
;; (define curr:stkdata (make-parameter (make-hasheq)))
;; ;; initialize stocktable
;; ;; todo: initialize date/time and price to yesterday close
;; (for ([k1 stklist])
;;   (let ([k (string->symbol k1)])
;;     (hash-set! (curr:stkdata) k (list '("000" 111 )))))

;; (define (add-price hash key item)
;;   (hash-update hash key (curry cons item) '()))

;; ;;;; append stock data to table
;; (define (add-stk)   
;;   (for ([ticker (curr:stklist)])
;;     (let ([price (get-stk-price ticker)])
;;       (add-price (curr:stkdata) key price))))

;; (define (extend-stkdata n)
;;   (define ticker (car (curr:stkdata)))
;;   ()
;;   (if )
;;   (thread let loop ()
;;     ))


