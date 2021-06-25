
#lang racket/base

;;; import dependencies
(require "credentials.rkt"
         net/http-easy
         net/url
         json
         net/rfc6455)

(define (iex/send conn req)
  (ws-send! conn req)
  (ws-recv conn))

;;; connect to iex
(define protocol 'rfc6455)
(define iex/conn (ws-connect (string->url urliex) #:protocol protocol))

;;; authenticate
;; {"action": "auth", "key": "{APCA-API-KEY-ID}", "secret": "{APCA-API-SECRET-KEY}"}
(define iex-req/secret
  (jsexpr->string  (hasheq 'action "auth" 'key key 'secret secret)))


(define iex-resp/auth (string->jsexpr (iex/send iex/conn iex/secret)))

;;; get quotes
(define tickers '("AMD" "MSFT"))

(define iex-req/quotes 
  (jsexpr->string (hasheq 'action "subscribe" 'quotes tickers)))


(define iex-resp/quotes (iex/send iex/conn iex-req/quotes))

;;; manage and close connection
(ws-conn-closed? iex/conn)
(ws-conn-closed? iex/conn)
(ws-close! iex/conn)


