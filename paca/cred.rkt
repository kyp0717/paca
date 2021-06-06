#lang racket/base

;;; import dependencies
(require yaml)

;;; yaml
(define paper (file->yaml "/home/emacs/rack/paca/paper.yml"))

;;; credential
(define key (hash-ref paper "key"))
(define secret (hash-ref paper "secret"))
(define cred (hasheq 'APCA-API-KEY-ID key
                     'APCA-API-SECRET-KEY secret))

;;; url
(define url-clock  (hash-ref paper "clock"))
(define url-orders  (hash-ref paper "orders"))
(define urliex  (hash-ref paper "urliex"))


;;; export bindings
(provide key secret cred url-clock url-orders urliex)
