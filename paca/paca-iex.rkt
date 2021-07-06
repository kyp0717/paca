#lang racket/base

;;; import dependencies
(require "cred.rkt"
         net/http-easy
         net/url
         json
         net/rfc6455)

;; {"action": "auth", "key": "{APCA-API-KEY-ID}", "secret": "{APCA-API-SECRET-KEY}"}
(define iex/auth
  (jsexpr->string  (hasheq 'action "auth" 'key key 'secret secret)))
(define protocol 'rfc6455)
urliex
(define iex/conn (ws-connect (string->url urliex) #:protocol protocol))
(ws-conn? iex/conn)
(ws-conn-closed? iex/conn)

(define iex/send (msg)


(recv/print c)

(ws-send! c iex/auth)

(for ((i 5)) (recv/print c))
(recv/print c)
(ws-close! iex/conn)


(define c (ws-connect (string->url urliex) #:protocol protocol))

(handle-evt c
   (lambda (m)
      (printf "Got message: ~a\n" m)))

(ws-conn-closed? c)
(ws-close! c)
