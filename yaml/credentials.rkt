#lang racket/base

;;; credential
(module cred racket 
  (require yaml json)
  (provide key secret auth-api auth-stream )
  (define paper (file->yaml "/home/phage/projects/paca/paca/paper.yml"))
  (define key (hash-ref paper "key"))
  (define secret (hash-ref paper "secret"))
  (define auth-stream
    (make-parameter (jsexpr->string  (hasheq 'action "auth" 'key key 'secret secret))))
  (define auth-api (make-parameter (hasheq 'APCA-API-KEY-ID key
                                           'APCA-API-SECRET-KEY secret)))
  
 )

;;; url
(module urls racket
  (require yaml json)
  (provide clock orders iex positions)
  (define url (file->yaml "/home/phage/projects/paca/paca/url.yml"))
  (define clock (make-parameter (hash-ref url "clock")))
  (define orders (make-parameter (hash-ref url "orders")))
  (define iex  (make-parameter (hash-ref url "iex-stream")))
  (define positions  (make-parameter (hash-ref url "positions"))))
