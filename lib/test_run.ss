; (write (+ 1 (+ 2 3)))
;(begin
;   (define a '(1 . 3))
;   (write (cdr a)))

;(begin
;  (define p (lambda (a b) (+ a b)))
;  (write (p (p 1 2) 3)))

;(begin
;  (define factorial
;    (lambda (x)
;      (if (= x 1)
;	  1
;	  (* x (factorial (- x 1))))))
;  (write (factorial 575)))

(begin
  (define plus
    (lambda (num . rest)
      (eval (cons '+ (cons num rest)))))
  (write (plus 1 2 3)))


;(begin
;  (define-macro mygod
;    (lambda (head)
;      (write head)))
;  (mygod (1 2 3) (4 5 6) 7 8 9))



