use strict;
use warnings;
use utf8;
use Test::More;
use Data::Dumper;

require 'lis.pl';

sub sym($) { Lispl::Symbol->new($_[0]) }

my @tests = (
    # ["(quote (testing 1 (2.0) -3.14e159))", [sym 'testing', 1, [2.0], -3.14e159]],
    ["(+ 2 2)", 4],
    ["(+ (* 2 100) (* 1 10))", 210],
    ["(if (> 6 5) (+ 1 1) (+ 2 2))", 2],
    ["(if (< 6 5) (+ 1 1) (+ 2 2))", 4],
    ["(define x 3)", undef], ["x", 3], ["(+ x x)", 6],
    ["(begin (define x 1) (set! x (+ x 1)) (+ x 1))", 3],
    ["((lambda (x) (+ x x)) 5)", 10],
    ["(define twice (lambda (x) (* 2 x)))", undef], ["(twice 5)", 10],
    ["(define compose (lambda (f g) (lambda (x) (f (g x)))))", undef],
    ["((compose list twice) 5)", [10]],
    ["(define repeat (lambda (f) (compose f f)))", undef],
    ["((repeat twice) 5)", 20], ["((repeat (repeat twice)) 5)", 80],
    ["(define fact (lambda (n) (if (<= n 1) 1 (* n (fact (- n 1))))))", undef],
    ["(fact 3)", 6],
    ["(fact 50)", 30414093201713378043612608166064768844377641568960512000000000000],
    ["(define abs (lambda (n) ((if (> n 0) + -) 0 n)))", undef],
    ["(list (abs -3) (abs 0) (abs 3))", [3, 0, 3]],
    [q"(define combine (lambda (f)
            (lambda (x y)
            (if (null? x) (quote ())
                (f (list (car x) (car y))
                    ((combine f) (cdr x) (cdr y)))))))", undef],
    [q"(define riff-shuffle (lambda (deck)
        (begin
            (define take (lambda (n seq) (if (<= n 0) (quote ()) (cons (car seq) (take (- n 1) (cdr seq))))))
            (define drop (lambda (n seq) (if (<= n 0) seq (drop (- n 1) (cdr seq)))))
            (define mid (lambda (seq) (/ (length seq) 2)))
            ((combine append) (take (mid deck) deck) (drop (mid deck) deck)))))", undef],
    ["(riff-shuffle (list 1 2 3 4 5 6 7 8))", [1, 5, 2, 6, 3, 7, 4, 8]],
    ["((repeat riff-shuffle) (list 1 2 3 4 5 6 7 8))",  [1, 3, 5, 7, 2, 4, 6, 8]],
    ["(riff-shuffle (riff-shuffle (riff-shuffle (list 1 2 3 4 5 6 7 8))))", [1,2,3,4,5,6,7,8]],

    # additional tests
    ["(zip (list 1 2 3 4) (list 5 6 7 8))", [[1, 5], [2, 6], [3, 7], [4, 8]]],
    [q"((combine append) (list 1 2 3 4) (list 5 6 7 8))", [1, 5, 2, 6, 3, 7, 4, 8]],
    [q"(quote ())", []],
    [q"(quote ())", []],
    [q[(quote (1 2 3 4 5))], [qw/1 2 3 4 5/]],
    [q"(begin
        (define take_ (lambda (n seq) (if (<= n 0) (quote ()) (cons (car seq) (take_ (- n 1) (cdr seq))))))
        (define drop_ (lambda (n seq) (if (<= n 0) seq (drop_ (- n 1) (cdr seq)))))
        (define mid_ (lambda (seq) (/ (length seq) 2))))", undef],
    ["(mid_ (list 1 2 3 4 5 6 7 8))", 4],
    ["(take_ 4 (list 1 2 3 4 5 6 7 8))", [qw/1 2 3 4/]],
    ["(car (list 1 2 3 4 5 6 7 8))", 1],
    ["(cdr (list 1 2 3 4 5 6 7 8))", [2..8]],
    ["(cons (list 1 2 3) (list 4 5 6)))", [[1..3], 4..6]],
    ["(cons (list 1) 2))", [[1], 2]],
);

my $lispl = Lispl->new();
for my $test (@tests) {
    my $tree = $lispl->parse($test->[0]);
    my $got = eval {
        $lispl->evaluate($tree);
    };
    if ($@) {
        warn Dumper($tree);
        die $@;
    }
    is_deeply($got, $test->[1], $test->[0]) or warn Dumper($got, $got);
}

done_testing;

