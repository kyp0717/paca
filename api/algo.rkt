#lang racket/base

;;; import
(require (prefix-in ix: "iex.rkt")
         "databases.rkt"
         (prefix-in paca: "paca.rkt")
         (prefix-in x: "analysis.rkt")
         (prefix-in ds: data-science))
         

;;; stock list for analysis
(define stk 'AMD )
(define stklist '("AMD" "MSFT"))

;;; build databases
;; connection
(define pgc-conn (pgc-connect!))

(pgc-build-db! pgc-conn)

;;; connection to iex
;;;; connect
(define iex-conn (ix:connect))
;;;;  authentication
(define-values (resp auth?) (ix:authenticate! iex-conn))
;;;; subscription to stream of quotes
(define-values (resp-subscribe subscribe?) (ix:subscribe-quotes iex-conn auth? stklist))


;;; algo
;; initial load
(define (initial-load)
  (for ([i (list 1 2 3 4 5)]) 
    (ix:insert-mkt-data! pgc-conn iex-conn stklist)
    (sleep 30))) ; sleep 30 seconds
   

;;;; openning move
;; (define (open-pos ticker)
;;   ;; load batch to sqlite
;;   (ix:insert-mkt-data! pgc-conn iex-conn stklist)
;;   (define regress-data (x:regress ))
;;   (iex:regress-load regress-data)
;;   (define mkt-stat (check-mkt-status regress))
;;   (define pos-stat (check-position iex ticker))
;;   (match (list mkt:status pos:status)
;;     ['(mkt:random pos:none) (paca:long! ticker)]
;;     ['(mkt:rally pos:none _) (paca:long!ticker)]
;;     ['(mkt:selloff pos:none) (paca:short! ticker)] ))



;; (define (run ticker)
;;   ;; load batch to sqlite
;;   (iex:insert-prices! iex:sqlite iex stklist)
;;   (define batches (iex:get-batches))
;;   (define regress (iex:regress batches))
;;   (iex:regress-load regress)
;;   (define mkt-stat (check-mkt-status regress))
;;   (define pos-stat (check-position iex ticker))
;;   (match (list pos:status pos:pctdelta mkt:status mkt:pctdelta )
;;     ['(#f _ _ _) (algo:exit)]
;;     ['(#t _ 'mkt:random _ ) (paca:sell! ticker)]
;;     ['(#t _ 'mkt:rally _) (run-algo ticker)]
;;     ['(#t _ 'mkt:selloff _) (run-algo ticker)]))

;;; main
(module+ main
  ;; (initial-load)
  (pgc-close! pgc-conn)
  (ix:close! iex-conn))




