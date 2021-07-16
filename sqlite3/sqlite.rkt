#lang racket/base

(require (prefix-in iex: "paca-iex.rkt")
         db)

(define db-file "/home/phage/sqlite/iex.db")

(define sqlite (sqlite3-connect #:database db-file #:mode 'create))

(query-exec sqlite "drop table if exists raw_quotes")

(query-exec sqlite
            "create table raw_quotes
             (batch integer not null,
              ticker text not null,
              iex_timestamp text not null,
              price text not null) ;")


(query-exec sqlite
            "create table test
             (ticker text not null );")


;; insert-stock!: database-connection string number -> void
;; Inserts an element into the stock table.
(define (insert-stk! tk  tm pr)
  (define stk (iex:extract-quote))
  (query-exec conn
              "insert into raw_quotes (ticker, iex_timestamp, price) values ($1, $2, $3)" 
              tk tm pr ))


;; insert-stock!: database-connection string number -> void
;; Inserts an element into the stock table.
(define (insert-test! tk)
  (define stk (iex:extract-quote))
  (define tk (car stk))
  (query-exec conn
              "insert into test (ticker) values ($1)" 
              tk  ))
