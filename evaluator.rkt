#lang racket
(require rackunit)
(require "parser.rkt")

#|
check-equal?
check-exn
check-not-exn)))
|#


(parse "(+ 5 5)")

;; atom

(define (eval-name tree)
  (case (second tree)
    ['+ +]
    ['- -]
    ['* *]
    ['/ /]
    ['string-append string-append]
    ['string<? string<?]
    ['string=? string=?]
    ['not not]
    ['= =]
    ['< <]
    [else (error "eval-name")]))
(check-equal? (eval-name '(NAME +)) +)

(define (eval-string tree)
  (second tree))
(check-equal? (eval-string '(STRING "5")) "5")

(define (eval-number tree)
  (second (second tree)))
(check-equal? (eval-number '(number (INT 5))) 5)

(define (eval-atom tree)
  (let ([type (first (second tree))]
        [sub-tree (second tree)])
    (case type
      ['NAME   (eval-name   sub-tree)]
      ['STRING (eval-string sub-tree)]
      ['number (eval-number sub-tree)]
      [else (error "eval-atom")])))
(check-equal? (eval-atom '(atom (NAME +))) +)
(check-equal? (eval-atom '(atom (STRING "5"))) "5")
(check-equal? (eval-atom '(atom (number (FLOAT 5)))) 5)

;; expr

(define (eval-expr tree)
  ; 1-expr : 2-(atom | invocation)
  (let* ([sub-tree (second tree)]
         [type     (first sub-tree)])
    (case type
      ['atom       (eval-atom       sub-tree)]
      ['invocation (eval-invocation sub-tree)]
      [else (error "eval-expr")])))
(check-equal? (eval-expr '(expr (atom (NAME +)))) +)

(define (eval-exprList tree)
  ; 1-exprList : 2-expr 3-optExprList
  (let* ([expr-tree (second tree)]
         [opt-tree  (third  tree)])
    (cons
     (eval-expr        expr-tree)
     (eval-optExprList opt-tree))))

(define (eval-optExprList tree)
  (if (empty? (rest tree))
      null
      (eval-exprList (second tree))))


(check-equal? (eval-exprList '(exprList (expr (atom (NAME +))) (optExprList))) (list +))
(check-equal? (eval-exprList '(exprList
                               (expr (atom (NAME +)))
                               (optExprList
                                (exprList
                                 (expr (atom (STRING "5")))
                                 (optExprList)))))
              (list + "5"))


;; invocation

(define (eval-invocation tree)
  ; 1-invocation : 2-OPAREN 3-exprList 4-CPAREN
  (let* ([exprList-tree (third tree)]
         [exprList      (eval-exprList exprList-tree)])
    (apply (first exprList) (rest exprList))))


(check-equal? (eval-invocation (second (second (second (parse "(+ 5 5 6 6 6 6 6)"))))) 40)
(check-equal? (eval-invocation (second (second (second (parse "(+ 5 5.5 6 6 6 5.5 6)"))))) 40.0)
(check-equal? (eval-invocation (second (second (second (parse "(+ 5 5.5 (+ 6 6) 6 (+ 5.5 6))"))))) 40.0)
(check-exn
 exn:fail?
 (eval-invocation (second (second (second (parse "(+ 5 \"5\")"))))))


;; program

(define (bottom list)
  (cond
    [(empty? list) null]
    [(empty? (rest list)) (first list)]
    [else (bottom (rest list))]))

(define (eval-program tree)
  (bottom (eval-exprList (second tree))))

(define (eval code)
  (eval-program (parse code)))

(check-equal? (eval "(+ 5 5 6 6 6 6 6)") 40)
(check-equal? (eval "(+ 1 1) (+ 2 2)") 4)
  

