;(display (+ 1 (+ 2 3)))
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


;(when (= 1 1)
;      (display "hello ")
;      (display "world"))

;(display (!= 1 2))

;(for-each (lambda (x y) (display (+ x y)) (newline))
;	  '(1 2 3) '(4 5 6))

;(begin
;  (define x 20)
;  (display (let ((x 1)
;		 (y x))
;	     (+ x y)))
;  (newline))

;(begin
;  (define counter 1)
;  (define bump-counter
;    (lambda ()
;      (define counter (+ counter 1))
;      counter))
;  (fluid-let ((counter 99))
;    (display (bump-counter)) (newline)
;    (display (bump-counter)) (newline)
;    (display (bump-counter)) (newline))
;  (display counter))

;(begin
;  (define x 20)
;  (define y 30)
;  (let ((x y)
;	(y x))
;    (display (+ x y)))
;  (newline)
;  (let* ((x y)
;	 (y x))
;    (display (+ x y)))
;  (newline)
;  (letrec ((local-even? (lambda (n)
;			  (if (= n 0) #t
;			      (local-odd? (- n 1)))))
;	   (local-odd? (lambda (n)
;			 (if (= n 0) #f
;			     (local-even? (- n 1))))))
;    (display (list (local-even? 23) (local-odd? 23))))
;  (newline)
;  (display (let countdown ((i 10))
;	     (if (= i 0) 'liftoff
;		 (begin
;		   (display i)
;		   (newline)
;		   (countdown (- i 1))))))
;  (newline))

;(display (reverse '(1 2 (3 4))))

;(for-each (lambda (x)
;	    (display (debug-format x))
;	    (display "  --  ")
;	    (display (type-of x))
;	    (newline))
;	  '('a 2 "3" '(4) '() #t (lambda (x) (x))))

;(display (fold-right + 0 '(1 2 3)))
;(display (fold-left + 0 '(1 2 3)))
;(display (debug-format (lambda (x) (x))))

;(begin
;  (define x '(1 2))
;  (set-car! x "what?")
;  (set-cdr! x (cons (car x) '()))
;  (display x)
;  (newline))

(display `(1 ,@'(1 2) 3))
(newline)
(display (+ 1 1))
(newline)

