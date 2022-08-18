# Unit Checker rules
```
<base-dimension> := T | L | M | ...
bd
<dimension> := 1 | <base-dimension> * <rational> * <dimension>
d
<base-unit> := s | m | kg | ...
bu
<unit> := 1 | <base-unit> * <rational> * <unit>
u
<type> := <unit> | <type> -> <type>
t
<env> := nil | (<identifier> : <type>),<env> | (<base-unit> : <base-dimension>),<env>
R

DECLARATIVE RULES
R |- e : u means that in environment R, the expresson e evaluates to a value with units u. In other words,
R |- e == n * u where n is a real number
R |- u : d means that in environment R, the unit u has dimension d. dimensions are to units as kinds are to types.



n is a number literal
R |- u1 is a unit
R |- u1 == u2
---LIT
R |- n * u1 : u2

R |- e1 : u1
R |- e2 : u2
R |- u1 == u2 == u
---ADD
R |- e1 + e2 : u

R |- e1 : u1
R |- e1 : u2
R |- u == u1 * u2
---MUL
R |- e1 * e2 : u

R |- e1 : u1
n is a rational number
R |- u == u1 ^ p
---EXP
R |- e1 ^ n : u

R |- e1 : 1
R |- e2 : 1
---EXP1
R |- e1 ^ e2 : 1

x : t in R
---VAR
R |- x : t

(x : t1),R |- e : t2
---ABS
R |- (lambda (x) e) : t1 -> t2

R |- e1 : t1 -> t2
R |- e2 : t1
t2 == t
---APP
R |- (e1 e2) : t

R |- u == (bu ^ pu) ...
R |- d == (bd ^ pd) ...
R |- bu : bd ...
R |- pu == pd ...
---DIM
R |- u : d

bu : bd in R
---DIMb
R |- bu : bd

n is a real number
(x : bu1 / bu2),R |- e : u
---CNV
R |- (let-conversion ([x (n * bu1 / bu2)]) e) : u
```
It makes the most sense to treat a unit as an algebraic variable, or like sqrt(-1). it is something that can be multiplied with a constant, but you only add like terms and you don't raise things to the power of a unit. It may not make sense to say that an expression : a unit, but idk how else to write it down to make sure the restrictions are followed. It also may not make sense to treat it as something that has to be "attached to" a number since it's its own thing.

Conversion is done by storing variables in the environment. For example, R could contain (feet/meter : feet * meter^-1).
