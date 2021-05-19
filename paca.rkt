#lang racket


(require yaml
         net/http-easy)
(define paper (file->yaml "/home/emacs/tmp/rkt-paca/paper.yml"))
(define key (hash-ref paper "key"))
(define secret (hash-ref paper "secret"))
(define clock-url  (hash-ref paper "clock"))

(define cred (hasheq 'APCA-API-KEY-ID key
                     'APCA-API-SECRET-KEY secret))

(response-json (get clock-url
                    #:headers cred))

(define req (get post url)
  (
