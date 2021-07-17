#lang racket/base

;;; import
(require (prefix-in iex: "iex.rkt")
         db)

;;; create database
(define db-file "/home/phage/sqlite/iex.db")
(define sqlite (sqlite3-connect #:database db-file #:mode 'create))

;;; Create tables
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

;;; Load data
;; insert-stock!: database-connection string number -> void
;; Inserts an element into the stock table.
(define (insert-price! conn)
  (define stk (iex:get-price))
  (define tk (hash-ref stk ) )
  (query-exec conn
              "insert into raw_quotes (ticker, iex_timestamp, price) values ($1, $2, $3)" 
              tk tm pr ))


;; insert-stock!: database-connection string number -> void
;; Inserts an element into the stock table.
(define (insert-batch! )
  (define stk (iex:extract-quote))
  (define tk (car stk))
  (query-exec conn
              "insert into test (ticker) values ($1)" 
              tk  ))
