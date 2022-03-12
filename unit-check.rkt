#lang turnstile

(provide #%datum m kg s Real)

(define-base-type m)
(define-base-type kg)
(define-base-type s)
(define-base-type Real)

; [PLUS]
(define-typed-syntax (+ e1 e2) ≫
   [⊢ e1 ≫ e1- ⇒ t]
   [⊢ e2 ≫ e2- ⇐ t]
   --------
   [⊢ (+- e1- e2-) ⇒ t])

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
