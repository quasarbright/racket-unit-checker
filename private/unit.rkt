#lang racket

(module+ example
  (provide empty-unit
           unit-kg
           unit-density
           unit-speed
           unit-force))
(module+ test (require rackunit) (require (submod ".." example)))
(provide
 unit?
 empty-unit
 make-unit)



(require racket/hash)



(define unit? (hash/c symbol? rational?))

(module+ example
  (define unit-kg (hasheq 'kg 1))
  (define unit-density (hasheq 'kg 1 'm -3))
  (define unit-speed (hasheq 'm 1 's -1))
  (define unit-force (hasheq 'kg 1 'm 1 's -2)))



(define empty-unit (hasheq))

(define (make-unit assocs) (clean-unit (make-immutable-hasheq (map (λ (assoc)
                                                                   (match assoc
                                                                     [(list bu p) (cons bu p)]
                                                                     [(list bu) (cons bu 1)]
                                                                     [(? symbol? bu) (cons bu 1)]))
                                                                 assocs))))

(module+ test
  (test-equal? "basic make-unit creation"
               (make-unit '((kg 1) (m 1) (s -2)))
               (hasheq 'kg 1 'm 1 's -2))
  (test-equal? "defaults power to 1"
               (make-unit '(kg (m)))
               (hasheq 'kg 1 'm 1))
  (test-equal? "removes powers of 0"
               (make-unit '((kg 1) (m 0)))
               (hasheq 'kg 1)))

(define (clean-unit u)
  (for/hasheq ([(bu p) (in-hash u)]
             #:unless (= p 0))
    (values bu p)))

(module+ test
  (test-equal? "removes powers of 0"
               (clean-unit (hasheq 'kg 0 'm 0 's 1 'K 0))
               (hasheq 's 1)))

(define (unit-* . units)
  (clean-unit (apply hash-union units #:combine +)))
