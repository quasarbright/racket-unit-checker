#lang turnstile

(provide #%datum m kg s Real)

(define-base-type m)
(define-base-type kg)
(define-base-type s)
(define-base-type Real)

(define-type-constructor ** #:arity = 2)

; [PLUS]
(define-typed-syntax (+ e1 e2) ≫
   [⊢ e1 ≫ e1- ⇒ t]
   [⊢ e2 ≫ e2- ⇐ t]
   --------
   [⊢ (+- e1- e2-) ⇒ t])

; [TIMES]
(define-typed-syntax (* e1 e2) ≫
  [⊢ e1 ≫ e1- ⇒ t1]
  [⊢ e2 ≫ e2- ⇒ t2]
  --------
  [⊢ (*- e1- e2-) ⇒ (** t1 t2)])

; [ANN]
(define-typed-syntax (: n t:type) ≫
  [⊢ n ≫ n- ⇒ Real]
  --------
  [⊢ n- ⇒ t.norm])

; [DATUM]
(define-typed-syntax #%datum
  [(_ . n:number) ≫
   --------
   [⊢ (#%datum- . n) ⇒ Real]]
  [(_ . x) ≫
   --------
   [#:error (type-error #:src #'x
                        #:msg "Unsupported literal ~v" #'x)]])
(begin-for-syntax
  (define (combine-hash h1 h2 [op +])
    (for/fold ([h h1])
              ([(base pow2) h2])
      ; add each exponent from 2 to 1
      (define pow1 (hash-ref h base 0))
      (define pow (op pow1 pow2))
      (hash-set h base pow)))
  (define (unit->hash u)
    (define t ((current-type-eval) u))
    (define combined
      (syntax-parse t
        [(~** t1 t2) (combine-hash (unit->hash #'t1) (unit->hash #'t2) +)]
        [~Real (hash)]
        [_ (hash t 1)]))
    ; should only do this once at the very end
    (define filtered
      (for/hash ([(base pow) combined]
                 #:when (not (zero? pow)))
        (values base pow)))
    filtered)
  (define (unit=? u1 u2)
    (equal? (unit->hash u1) (unit->hash u2)))
  (current-type=? unit=?))