; (write (+ 1 (+ 2 3)))
;(begin
;   (define a '(1 . 3))
;   (write (cdr a)))

;(begin
;  (define p (lambda (a b) (+ a b)))
;  (write (p (p 1 2) 3)))

(begin
  (define factorial
    (lambda (x)
      (if (== x 1)
	  1
	  (* x (factorial (- x 1))))))
  (write (factorial 10)))



