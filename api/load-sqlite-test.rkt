#lang racket/base

;;; import
(require (prefix-in sq: "./load-sqlite.rkt")
         net/rfc6455
         (prefix-in iex: "iex.rkt")
         rackunit)

;;; connection to iex
(define iex (iex:connect))
(define-values (resp auth?) (iex:authenticate! iex))
(define stklist '("AMD" "MSFT"))
(define-values (resp-subscribe subscribe?) (iex:subscribe-quotes iex auth? stklist))
;;; test sqlite data load
(check-equal? 0 (sq:get-count sq:sqlite))
(sq:insert-test! sq:sqlite)
(check-equal? 1 (sq:get-count sq:sqlite))

;;; test sqlite batch number 
(check-equal? 0 (sq:get-batch-number sq:sqlite))
;; (sq:insert-test! sq:sqlite)
;; (check-equal? 1 (sq:get-batch-number sq:sqlite))


;;; test data load to raw table
(check-equal? 0 (sq:get-count-raw sq:sqlite))
(sq:insert-price! sq:sqlite iex)
(check-equal? 1 (sq:get-count-raw sq:sqlite))


;;; close connection
(ws-close! iex)
