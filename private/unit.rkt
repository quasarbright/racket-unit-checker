#lang racket

(module+ test (require rackunit))
(provide (struct-out base-dimension)
         M
         L
         T
         (struct-out base-unit)
         kg
         m
         s
         (struct-out dimension)
         empty-dimension
         (struct-out unit)
         empty-unit
         (struct-out measured)
         measured/c
         unit/c
         dimension/c
         (contract-out
          [measured-* (->* () #:rest (listof measured/c) measured/c)]
          [unit-* (->* () #:rest (listof unit/c) unit/c)]
          [dimension-* (->* () #:rest (listof dimension/c) dimension/c)]))

(require racket/hash)

; data definitions

; A [Product A] is a
#;(hash/c A integer?)
; Represents a product/quotient of As where keys are As and values are exponents
; CONSTRAINT: no value can be zero.
; CONSTRAINT: hasheq
(define (product/c factor/c) (hash/c factor/c (and/c integer? (not/c zero?))))

(struct base-dimension [name shortname] #:transparent)
; A BaseDimension is a
#;(base-dimension string? string?)
; Represents a (non-composite) physical dimension of measurement.
; name is the full name of the dimension, shortname is the shorter name, like what you'd write in mathematical notation
; Examples:
(define M (base-dimension "mass" "M"))
(define L (base-dimension "length" "L"))
(define T (base-dimension "time" "T"))
(define base-dimension/c (struct/c base-dimension string? string?))

(struct dimension [maybe-name maybe-shortname bases] #:transparent)
; A Dimension is a
#;(dimension (or/c #f string?) (or/c #f string?) (Product BaseDimension))
; Represents a physical dimension of measurement.
; Examples:
(define speed (dimension "speed" #f (hasheq L 1 T -1)))
(define empty-dimension (dimension #f #f (hasheq)))
(define dimension/c (struct/c dimension (or/c #f string?) (or/c #f string?) (product/c base-dimension/c)))

(struct base-unit [name shortname dimension] #:transparent)
; A BaseUnit is a
#;(base-unit string? string? Dimension)
; Represents a (non-composite) physical unit of measurement.
; name is the full name of the unit, shortname is the shorter name, liek what you'd write in mathematical notation.
; Examples:
(define kg (base-unit "kilogram" "kg" M))
(define m (base-unit "meter" "m" L))
(define s (base-unit "second" "s" T))
(define base-unit/c (struct/c base-unit string? string? dimension/c))

(struct unit [maybe-name maybe-shortname bases] #:transparent)
; A Unit is a
#;(unit (or/c #f string?) (or/c #f string?) (Product BaseUnit))
; Represents a physical unit of measurement.
; Examples:
(define m/s (unit "meters per second" #f (hasheq m 1 s -1)))
(define empty-unit (unit #f #f (hasheq)))
(define unit/c (struct/c unit (or/c #f string?) (or/c #f string?) (product/c base-unit/c)))

(struct measured [quantity unit] #:transparent)
; A Measured is a
#;(measured number? Unit)
; Represents a physical quantity with units of measurement
; Examples:
(define c (measured 299792458 m/s))
(define measured/c (struct/c measured number? unit/c))

; functionality

#;(Measured ... -> Measured)
; multiply the measured quantities.
(define (measured-* . measureds)
  (measured (apply * (map measured-quantity measureds))
            (apply unit-* (map measured-unit measureds))))

#;(Unit ... -> Unit)
; multiply the units
(define (unit-* . units)
  (unit #f #f (apply product-* (map unit-bases units))))

#;([Product A] ... -> [Product A])
; multiply the products (adds exponents and filters zeroes)
(define (product-* . products)
  (product-rm-zeroes (apply hash-union products #:combine/key (lambda (k v1 v2) (+ v1 v2)))))

#;(Dimension ... -> Dimension)
; multiply dimensions
(define (dimension-* . dims)
  (dimension #f #f (apply product-* (map dimension-bases dims))))

#;([Product A] [Product A])
; removes keys with an exponent of zero.
(define (product-rm-zeroes prod)
  (for/hasheq ([(k v) prod] #:unless (zero? v))
    (values k v)))

(module+ test)
