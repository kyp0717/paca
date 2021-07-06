#lang racket/base

;;; import dependencies


;;; credential
(module cred racket 
  (require yaml json)
  (provide key secret auth:api auth:stream)
  (define paper (file->yaml "/home/phage/tmp/rkt-paca/paca/paper.yml"))
  (define key (hash-ref paper "key"))
  (define secret (hash-ref paper "secret"))
  (define auth:stream
    (jsexpr->string  (hasheq 'action "auth" 'key key 'secret secret)))
  (define auth:api (make-parameter (hasheq 'APCA-API-KEY-ID key
                                                'APCA-API-SECRET-KEY secret)))
  ;; (define (curr-auth:api)
  ;;   (let ([k (hash-ref paper "key")]
  ;;         [v (hash-ref paper "secret")])
  ;;     (make-parameter (hasheq 'APCA-API-KEY-ID k
  ;;                             'APCA-API-SECRET-KEY v))))
 )

;;; url
(module urls racket
  (require yaml json)
  (provide clock curr-clock orders iex positions)
  (define url (file->yaml "/home/phage/tmp/rkt-paca/paca/url.yml"))
  (define clock  (hash-ref url "clock"))
  (define curr-clock (make-parameter (hash-ref url "clock")))
  (define orders  (hash-ref url "orders"))
  (define iex  (hash-ref url "iex-stream"))
  (define positions  (hash-ref url "positions")))
