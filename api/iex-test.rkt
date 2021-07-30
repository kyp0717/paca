#lang racket/base

;;; import
(require rackunit
         net/rfc6455
         json
         (prefix-in iex: "./iex.rkt"))


;;; test connection to iex
(define iex (iex:connect))
(check-false (ws-conn-closed? iex)
             "IEX conn still open?")

;;; test authentication
(define-values (resp auth?) (iex:authenticate! iex))
(check-equal? "authenticated" resp)
(check-equal? (auth?) #t)

;;; test subscription to stream of quotes
(define stklist '("AMD" "MSFT"))
;; (define (subscribe-json ls) 
;;     (jsexpr->string (hasheq 'action "subscribe" 'quotes ls)))
;; (define s (subscribe-json stklist))
(define-values (resp-subscribe subscribe?) (iex:subscribe-quotes iex auth? stklist))
(check-equal? "subscription" resp-subscribe)
(check-equal? (subscribe?) #t)

;;; test extract data
;; assume there is already subscription
(define q (iex:get-quote iex "AMD"))
(print q)

(define qlst (iex:get-list-of-quotes iex stklist))
(print qlst)
;; (check-match q (list _ _ _))


;;; load test data 
(define (insert-test! sqlconn)
  (query-exec sqlconn 
   "insert into test_tbl (ticker) values ('test') "))

;;; check data in test_tbl
(define (get-count sqlconn)
  (define b (query-value sqlconn "select count(*) from test_tbl"))
  b)


;;; test sqlite data load
(check-equal? 0 (get-count sq:sqlite))
(insert-test! sq:sqlite)
(check-equal? 1 (get-count sq:sqlite))

;;; test sqlite batch number 
(check-equal? 0 (sq:get-batch-number sq:sqlite))
;; (sq:insert-test! sq:sqlite)
;; (check-equal? 1 (sq:get-batch-number sq:sqlite))


;;; check data in raw_quotes
(define (get-count-raw sqlconn)
  (define b (query-value sqlconn "select count(*) from raw_quotes"))
  b)


;;; test data load to raw table
(check-equal? 0 (get-count-raw sq:sqlite))
(insert-batch! sq:sqlite iex stklist)
;; (check- (get-count-raw sq:sqlite))


;;; close connection
(ws-close! iex)
