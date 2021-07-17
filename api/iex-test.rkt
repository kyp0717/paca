#lang racket/base


(require rackunit
         net/rfc6455
         (prefix-in iex: "./iex.rkt"))


;;; test connection to iex
(define iex (iex:connect))
(check-false (ws-conn-closed? iex)
             "IEX conn still open?")

;;; test authentication
(define-values (resp auth?) (iex:authenticate! iex))
(check-equal? "authenticated" resp)

;;; test subscription to stream of quotes
(define stklist '("AMD" "MSFT"))
(iex:sub-quotes iex auth? stklist)
(ws-recv iex)
;;; todo: test functions 


;;; close connection
(ws-close! iex)
