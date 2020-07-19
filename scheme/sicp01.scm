;; EXERCISE 2
(define ans (/ (+ 5 4 (- 2 (- 3 (+ 6 (/ 4 5))))) (* 3 (- 6 2) (- 2 7))))

;; test
(= (/ -37 150) ans)

;; EXERCISE 3
(define (square x)
  (* x x))

(define (sum a b c)
  (if (>= a b)
      (if (>= b c)
          (+ (square a) (square b))
          (+ (square a) (square c)))
      (if (>= a c)
          (+ (square b) (square a))
          (+ (square b) (square c)))))

;; tests
(= 0 (sum 0 0 0))
(= 13 (sum 1 2 3))
(= 41 (sum 3 4 5))
(= 1 (sum -1 0 1))
(= 5 (sum -1 -2 -3))
(= 25 (sum -3 -4 -5))

;; EXERCISE 5
;; - Applicative-order evaluation => eager evaluation, viz. arguments are
;;   evaluated prior to being passed into a function, whereas normal-order
;;   evaluation => lazy evaluation, viz. an argument is not evaluated until
;;   the interpreter knows it will need the value of that argument
;; - For a lazy interpreter, the expression will terminate with result 0. For
;;   an eager interpeter, the expression will never terminate because the
;;   'p' function is a recursive call to itself with no base case.

;; EXERCISE 6
;;   ==> (sqrt-iter 1 2)
;;
;; - An infinite loop occurs in sqrt-iter with eager-racket because 'new-if'
;;   is a procedure where the type of evaluation is left up to the
;;   interpreter, in this case eager. Special forms seem to choose lazy/eager
;;   evaluation on a case-by-case basis.
;; - N.B. Switching to lazy racket will evaluate this expression just fine.

;; EXERCISE 7
(define (good-enough? guess x)
  (< (abs (- (square guess) x)) 0.001))

(define (average x y)
  (/ (+ x y) 2))

(define (improve guess x)
  (average guess (/ x guess)))

(define (sqrt-iter guess x)
  (if (good-enough? guess x)
      guess
      (sqrt-iter (improve guess x)
         x)))

(define (sqrt x) (sqrt-iter 1.0 x))

(define (new-good-enough? last-guess guess)
  (< (abs (- last-guess guess)) (* 0.001 guess)))

(define (new-sqrt-iter last-guess guess x)
  (if (new-good-enough? last-guess guess)
      guess
      (new-sqrt-iter guess (improve guess x) x)))

(define (new-sqrt x) (new-sqrt-iter 0.0 1.0 x))

;; The sqrt function returns inaccurate values on small numbers because of
;; its relatively high tolerance.
(sqrt 0.01)        ; Accurate
(new-sqrt 0.01)    ; Accurate
(sqrt 0.05)        ; Close
(new-sqrt 0.05)    ; Accurate
(sqrt 0.001)       ; Inaccurate
(new-sqrt 0.001)   ; Accurate

;; The sqrt function is accurate for large numbers until it hits a point
;; where what seems like an overflow occurs...the machine can't accurately
;; represent the floating point number. Though I'm not clear why I can
;; type a large number but not get the square of its square-root accurately.
(sqrt 1e30)        ; Accurate
(new-sqrt 1e30)    ; Accurate
(sqrt 16e64)       ; Infinite Loop!
(square 4.0e32)    ; Accurate
(new-sqrt 16e64)   ; Accurate

;; EXERCISE 8
(define (cube x) (* x x x))

(define (improve guess x)
  (/ (+ (/ x (* guess guess)) (* 2 guess)) 3))

(define (good-enough? guess x)
  (< (abs (- (cube guess) x)) 0.001))

(define (cbrt-iter guess x)
  (if (good-enough? guess x)
      guess
      (cbrt-iter (improve guess x) x)))

(define (cbrt x)
  (cbrt-iter 1.0 x))

;; EXERCISE 9
;; - (+ 4 5) = (inc (+ 3 5)) = (inc (inc (+ 2 5))) = (inc (inc (inc (+ 1 5))))
;;           = (inc (inc (inc (inc (+ 0 5))))) = (inc (inc (inc (inc 5)))) = 9
;;
;; - (+ 4 5) = (+ 3 6) = (+ 2 7) = (+ 1 8) = (+ 0 9) = 9

;; EXERCISE 11
(define (f n)
  (if (< n 3)
      n
      (+ (f (- n 1)) (* 2 (f (- n 2))) (* 3 (f (- n 3))))))

(define (f-iter a b c count)
  (if (= count 0)
      a
      (f-iter b c (+ c (* 2 b) (* 3 a)) (- count 1))))
(define (f n)
  (f-iter 0 1 2 n))

;; EXERCISE 12
(define (pascal n m)
  (cond ((or (< n 0) (< m 0) (> m n)) 0)
    ((= 0 n m) 1)
    (else (+ (pascal (- n 1) m) (pascal (- n 1) (- m 1))))))

;; EXERCISE 16
(define (expt b n)
  (define (even? n) (= (remainder n 2) 0))
  (define (iter accum count)
    (cond ((= count 0) accum)
      ((even? count) (iter (square accum) (/ count 2)))
      (else (iter (* b accum) (- count 1)))))
  (iter 1 n))

;; EXERCISE 17
(define (fast-mult a b)
  ;; N.B. This only works on small negative numbers because of the bit ops
  (define (even? n) (= (bitwise-and n 1) 0))
  (define (double x) (arithmetic-shift x 1))
  (define (halve x) (arithmetic-shift x -1))
  (cond ((= 0 b) 0)
    ((even? b) (fast-mult (double a) (halve b)))
    (else (+ a (fast-mult a (- b 1))))))

;; EXERCISE 18
(define (fast-mult a b)
  ;; N.B. This only works on small negative numbers because of the bit ops
  (define (even? n) (= (bitwise-and n 1) 0))
  (define (double x) (arithmetic-shift x 1))
  (define (halve x) (arithmetic-shift x -1))
  (define (iter aa bb s)
    (cond ((= 0 bb) s)
      ((even? bb) (iter (double aa) (halve bb) s))
      (else (iter aa (- bb 1) (+ aa s)))))
  (iter a b 0))

;; EXERCISE 20
;; Normal-Order Eval (Lazy) [remainder is evaluated when 'if (= b 0)' is hit]
;; (gcd 206 40)
;; =>if (= 40 0)
;;      206
;;      (gcd 40 (remainder 206 40))
;; (gcd 40 (remainder 206 40))
;; =>if (= (remainder 206 40) 0)
;;      40
;;      (gcd (remainder 206 40) (remainder 40 (remainder 206 40)))
;; =>if (= 6 0)
;;      40
;;      (gcd (remainder 206 40) (remainder 40 (remainder 206 40)))
;; (gcd (remainder 206 40) (remainder 40 (remainder 206 40)))
;; =>if (= (remainder 40 (remainder 206 40)) 0)
;;      (remainder 206 40)
;;      (gcd (remainder 40 (remainder 206 40))
;;           (remainder (remainder 206 40)
;;                      (remainder 40 (remainder 206 40))))
;; =>if (= 4 0)
;;      (remainder 206 40)
;;      (gcd (remainder 40 (remainder 206 40))
;;           (remainder (remainder 206 40)
;;                      (remainder 40 (remainder 206 40))))
;; (gcd (remainder 40 (remainder 206 40))
;;      (remainder (remainder 206 40) (remainder 40 (remainder 206 40))))
;; =>if (= (remainder (remainder 206 40) (remainder 40 (remainder 206 40))) 0)
;;      (remainder 40 (remainder 206 40))
;;      (gcd (remainder (remainder 206 40) (remainder 40 (remainder 206 40)))
;;           (remainder (remainder 40 (remainder 206 40))
;;                      (remainder (remainder 206 40)
;;                                 (remainder 40 (remainder 206 40)))))
;; =>if (= 2 0)
;;      (remainder 40 (remainder 206 40))
;;      (gcd (remainder (remainder 206 40) (remainder 40 (remainder 206 40)))
;;           (remainder (remainder 40 (remainder 206 40))
;;                      (remainder (remainder 206 40)
;;                                 (remainder 40 (remainder 206 40)))))
;; (gcd (remainder (remainder 206 40) (remainder 40 (remainder 206 40)))
;;      (remainder (remainder 40 (remainder 206 40))
;;                 (remainder (remainder 206 40)
;;                            (remainder 40 (remainder 206 40)))))
;; =>if (= (remainder (remainder 40 (remainder 206 40))
;;                    (remainder (remainder 206 40)
;;                               (remainder 40 (remainder 206 40)))))
;;         0)
;;      (remainder (remainder 206 40) (remainder 40 (remainder 206 40)))
;;      (remainder (remainder (remainder 206 40) (remainder
;;                                                 40
;;                                                 (remainder 206 40)))
;;                 (remainder (remainder 40 (remainder 206 40))
;;                            (remainder (remainder 206 40)
;;                                       (remainder 40 (remainder 206 40))))))
;; =>if (= 0 0)
;;      (remainder (remainder 206 40) (remainder 40 (remainder 206 40)))
;;      (remainder (remainder (remainder 206 40) (remainder
;;                                                 40
;;                                                 (remainder 206 40)))
;;                 (remainder (remainder 40 (remainder 206 40))
;;                            (remainder (remainder 206 40)
;;                                       (remainder 40 (remainder 206 40))))))
;; =>(remainder (remainder 206 40) (remainder 40 (remainder 206 40)))
;; =>2 [requires 17 calls to remainder]

;; Applicative-Order (Eager) [remainder is evaluated prior to 'gcd' call]
;; (gcd 206 40) = (gcd 40 (remainder 206 40)) = (gcd 40 6)
;;              = (gcd 6 (remainder 40 6)) = (gcd 6 4)
;;              = (gcd 4 (remainder 6 4)) = (gcd 4 2)
;;              = (gcd 2 (remainder 4 2)) = (gcd 2 0)
;;              = 2 [requires 4 calls to remainder]

;; EXERCISE 21
(define (smallest-divisor n)
  (define (divides? a b)
    (= (remainder b a) 0))
  (define (find test)
    (cond ((> (square test) n) n)
      ((divides? test n) test)
      (else (find (+ test 1)))))
  (find 2))

(smallest-divisor 199)
(smallest-divisor 1999)
(smallest-divisor 19999)

;; EXERCISE 30
(define (sum term a next b)
  (define (iter a result)
    (if (> a b)
    result
    (iter (next a) (+ (term a) result))))
  (iter a 0))

;; EXERCISE 42
(define (compose f g)
  (lambda (x) (f (g x))))
