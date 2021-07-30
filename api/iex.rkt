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
         net/rfc6455
         db)

;;; export
(provide connect authenticate! subscribe-quotes get-quote get-list-of-quotes
          get-batch-number sqlite insert-batch! insert-prices!)

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
(define (get-quote iexconn ticker)
  (let* ([q (ws-recv iexconn)]
         [q2 (car (string->jsexpr q))]
         [price (hash-ref q2 'ap)]
         [timestamp (hash-ref q2 't)]
         [key  (hash-ref q2 'S)])
         (cond
           [(string=? ticker key) (list key price timestamp)]
           [else (get-quote iexconn ticker)])))

;; this is a recursive fn because we need to make frequent request
;; to the stream until the ticker of interest is provided
;; (define (get-quote iexconn ticker)
;;   (let* ([q (ws-recv iexconn)]
;;          [q2 (car (string->jsexpr q))]
;;          [key  (hash-ref q2 'S)])
;;          key))

(define (get-list-of-quotes iexconn stklist)
  (for/list ([tk stklist])
    (get-quote iexconn tk)))






;;; create database
(define db-file "/home/phage/projects/sqlite/iex.db")
(define sqlite (sqlite3-connect #:database db-file #:mode 'create))
;; (define curr:sqlite (make-parameter sqlite))

;;; Create tables
(query-exec sqlite "drop table if exists raw_quotes")
(query-exec sqlite "drop table if exists test_tbl")

(query-exec sqlite
            "create table raw_quotes
             (batch integer not null,
              ticker text not null,
              iex_timestamp text not null,
              price text not null) ;")

(query-exec sqlite
            "create table trend_tbl
             (insert_dtm integer not null,
              ticker text not null,
              slope number not null );")

(query-exec sqlite
            "create table test_tbl
             (ticker text not null );")

(query-exec sqlite
            "create view vw_batch_latest if not exists as
             select * from raw_quotes
             where batch in (
             select top 5 distinct batch
             from raw_quotes
             order by batch desc);")

;;; Load data
;; get batch number
(define (get-batch-number sqlconn)
  (define b (query-value sqlconn "select count(*) from raw_quotes"))
  (if (= b 0)
      (values 0)
      (+ b 1)))
  
;; insert list of quotes into sqlite 
(define (insert-prices! sqlconn iexconn stklist)
  (define batch (get-batch-number sqlconn))
  (define qlist (iex:get-list-of-quotes iexconn stklist))
  (for ([i qlist])
    (let  ([ticker (car i)]
           [price (car (cdr i))]
           [ts (car (cdr (cdr i)))])
      (query-exec sqlconn
                  "insert into raw_quotes
                   (batch, interval, ticker, iex_timestamp, price)
                   values ($1, $2, $3, $4, $5)" 
                  batch ticker ts price ))))

;; deprecated!!!
(define (insert-batch! sqlconn iexconn stklist)
  (define batch (get-batch-number sqlconn))
  (for ([interval (list 1 2 3 4 5)])
    (insert-prices! sqlconn iexconn stklist batch interval)
    (sleep 30))) 

;;; get latest batches of data
(define (get-batches)
  (define batches (query-rows "select * from vw_batches_latest")))


;;; close conn
;; (ws-conn-closed? iex:con)
;; (ws-close! iex:con)

