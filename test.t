use strict;
use warnings;
use utf8;
use Test::More 0.96;
use Data::Dumper;

require 'lis.pl';

subtest 'simple' => sub {
    my $l = Lispl->new();
    my $tree = $l->parse('(+ 2 3)');
    is($l->evaluate($tree), 5);
};

subtest '+' => sub {
    my $l = Lispl->new();
    my $tree = $l->parse('(+ 1 2 3 4 5 6 7 8 9 10)');
    is($l->evaluate($tree), 55);
};

subtest 'define' => sub {
    my $l = Lispl->new();
    my $tree = $l->parse('(begin (define x 4) x)');
    is($l->evaluate($tree), 4);
};

subtest 'begin' => sub {
    my $l = Lispl->new();
    my $tree = $l->parse('(begin 1 2 3)');
    is($l->evaluate($tree), 3);
};

subtest 'set!' => sub {
    my $l = Lispl->new();
    my $tree = $l->parse('(begin (define x 4) (set! x 5) x)');
    is($l->evaluate($tree), 5);
};

subtest 'if' => sub {
    {
        my $l = Lispl->new();
        my $tree = $l->parse('(if 1 3 4)');
        is($l->evaluate($tree), 3);
    }
    {
        my $l = Lispl->new();
        my $tree = $l->parse('(if 0 3 4)');
        is($l->evaluate($tree), 4);
    }
};

subtest 'area' => sub {
    my $l = Lispl->new();
    my $tree = $l->parse('(begin
        (define area (lambda (r) (* 3.141592653 (* r r))))
        (area 3)
        )');
    is($l->evaluate($tree), 28.274333877);
};

subtest 'fact' => sub {
    my $l = Lispl->new();
    my $tree = $l->parse('(begin
         (define fact (lambda (n)
            (if (<= n 1)
                1
                (* n (fact (- n 1))))))
         (fact 10)
        )');
    is($l->evaluate($tree), 3628800);
};

done_testing;

