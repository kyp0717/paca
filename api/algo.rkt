#lang racket/base

;;; import
(require (prefix-in iex: "iex.rkt")
         (prefix-in ds: data-science)
         db)


;;; stock list for analysis
(define stklist '("AMD" "MSFT"))

;;; connection to iex
;;;; connect
(define iex (iex:connect))
;;;;  authentication
(define-values (resp auth?) (iex:authenticate! iex))
;;;; subscription to stream of quotes
(define-values (resp-subscribe subscribe?) (iex:subscribe-quotes iex auth? stklist))


;;; algo
;;;; openning move
(define (openning-move ticker)
  ;; load batch to sqlite
  (iex:insert-prices! iex:sqlite iex stklist)
  (define batches (iex:get-batches))
  (define regress (iex:regress batches))
  (iex:regress-load regress)
  (define mkt-stat (check-mkt-status regress))
  (define pos-stat (check-position iex ticker))
  (match (list mkt:status pos:status)
    ['(mkt:random pos:none) (paca:long! ticker)]
    ['(mkt:rally pos:none _) (paca:long!ticker)]
    ['(mkt:selloff pos:none) (paca:short! ticker)] ))

(define (run-algo ticker)
  ;; load batch to sqlite
  (iex:insert-prices! iex:sqlite iex stklist)
  (define batches (iex:get-batches))
  (define regress (iex:regress batches))
  (iex:regress-load regress)
  (define mkt-stat (check-mkt-status regress))
  (define pos-stat (check-position iex ticker))
  (match (list pos:status pos:pctdelta mkt:status mkt:pctdelta )
    ['(#f _ _ _) (algo:exit)]
    ['(#t _ 'mkt:random _ ) (paca:sell! ticker)]
    ['(#t _ 'mkt:rally _) (run-algo ticker)]
    ['(#t _ 'mkt:selloff _) (run-algo ticker)]))




