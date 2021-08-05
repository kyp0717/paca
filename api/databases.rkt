#lang racket/base

;;; import dependencies
(require db)


;;; export
(provide pgc-close! pgc-connect! pgc-build-db!)

;;; SQLite - create sql database
;;;; connection
(define db-file "/home/phage/projects/sqlite/iex.db")
(define sqlite (sqlite3-connect #:database db-file #:mode 'create))
;; (define curr:sqlite (make-parameter sqlite))

;;; Sqlite Create tables
(query-exec sqlite "drop table if exists stg_mkt_data")
(query-exec sqlite "drop table if exists test_tbl")

(query-exec sqlite
            "create table stg_mkt_data 
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
            "create view vw_mkt_data_latest if not exists as
             select * from raw_quotes
             where batch in (
             select top 5 distinct batch
             from raw_quotes
             order by batch desc);")



;;; Postgres 
;; connection
(define (pgc-connect!)
   (postgresql-connect #:user "postgres" 
                        #:database"postgres" 
                        #:password "postgres"))


;;; Postgres Create Database
(define (create-db! pgc)
  (query-exec pgc "create database iex_db"))

(define (create-user! pgc)
  (query-exec pgc "create user iex_user with encrypted password 'iex_user"))

;;; Postgres Create tables

(define (build-stage-tbl! pgc)
  (query-exec pgc 
              "create table stg_mkt_data 
             (batch integer not null,
              ticker text not null,
              iex_timestamp text not null,
              price text not null) ;"))

(define (build-trend-tbl! pgc)
  (query-exec pgc 
              "create table trend_tbl
             (insert_dtm integer not null,
              ticker text not null,
              slope number not null );"))

;; (query-exec pgc 
;;             "create table test_tbl
;;              (ticker text not null );")

(define (build-latest-vw! pgc)
  (query-exec pgc 
              "create or replace view vw_mkt_data_latest as
             select * from raw_quotes
             where batch in (
             select top 5 distinct batch
             from raw_quotes
             order by batch desc);"))

(define (pgc-build-db! pgc)
         (query-exec pgc "drop table if exists trend_tbl, stg_mkt_data")
         (build-stage-tbl! pgc)
         (build-trend-tbl! pgc)
         (build-latest-vw! pgc))




;;; Posgres close connection
(define (pgc-close! dbconn) (disconnect dbconn))
