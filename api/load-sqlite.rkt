#lang racket/base

;;; import
(require (prefix-in iex: "iex.rkt")
         db)

;;; export
(provide get-batch-number get-count-raw get-count sqlite insert-test! insert-price!)

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
            "create table test_tbl
             (ticker text not null );")

;;; load test data 
(define (insert-test! sqlconn)
  (query-exec sqlconn 
   "insert into test_tbl (ticker) values ('test') "))

;;; check data in test_tbl
(define (get-count sqlconn)
  (define b (query-value sqlconn "select count(*) from test_tbl"))
  b)

;;; Load data
;; get batch number
(define (get-batch-number sqlconn)
  (define b (query-value sqlconn "select count(*) from raw_quotes"))
  (if (= b 0)
      (values 0)
      (+ b 1)))
  

;; insert-stock!: database-connection string number -> void
;; Inserts an element into the stock table.

;; insert 1 record 
(define (insert-price! sqlconn iexconn)
  (define b (get-batch-number sqlconn))
  (define stklist (iex:get-price iexconn))
  (define ticker (car stklist))
  (define price (car (cdr stklist)))
  (define ts (car (cdr (cdr stklist))))
  (query-exec sqlconn
      "insert into raw_quotes
      (batch, ticker, iex_timestamp, price)
       values ($1, $2, $3, $4)" 
   b ticker ts price ))



;;; check data in raw_quotes
(define (get-count-raw sqlconn)
  (define b (query-value sqlconn "select count(*) from raw_quotes"))
  b)


;; insert-stock!: database-connection string number -> void
;; Inserts an element into the stock table.
;; (define (insert-batch! )
;;   (define stk (iex:extract-quote))
;;   (define tk (car stk))
;;   (query-exec conn
;;               "insert into test (ticker) values ($1)" 
;;               tk  ))
