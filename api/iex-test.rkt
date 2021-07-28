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
(define q (iex:get-price iex))
(check-match q (list _ _ _))

;;; close connection
(ws-close! iex)
