; (display (+ 1 (+ 2 3)))
;(begin
;   (define a '(1 . 3))
;   (display (cdr a)))

;(begin
;  (define p (lambda (a b) (+ a b)))
;  (display (p (p 1 2) 3)))

;(begin
;  (define factorial
;    (lambda (x)
;      (if (= x 1)
;	  1
;	  (* x (factorial (- x 1))))))
;  (display (factorial 575)))

;(begin
;  (define plus
;    (lambda (num . rest)
;      (eval (cons '+ (cons num rest)))))
;  (display (plus 1 2 3)))


;(begin
;  (define-macro mygod
;    (lambda (head . body)
;      (display (list head body))))
;  (mygod (1 2 3) (4 5 6) 7 8 9))

;(let ((x 1)) (display x))


;(unless (= 1 1)
;	(display "hello ")
;	(display "world"))

;(display (!= 1 2))

;(for-each (lambda (x y) (display (+ x y)) (newline))
;	  '(1 2 3) '(4 5 6))
(begin
  (define x 20)
  (display (let ((x 1)
		 (y x))
	     (+ x y)))
  (newline))



