#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use 5.010000;
use autodie;

require 'lis.pl';

my $lispl = Lispl->new();
$lispl->evaluate($lispl->parse(<<'...'));
(define fib (lambda (n)
        (if (< n 2)
            1
            (+ (fib (- n 1)) (fib (- n 2))))))
...
my $tree = $lispl->parse('(fib 10)');
if (0) {
    my $a = fib(20);
    my $b = $lispl->evaluate($tree);
    $a == $b or die "$a != $b";
}

for (1..3) {
    warn $lispl->evaluate($tree);
}

sub fib {
    $_[0] < 2 ? 1 : fib($_[0]-1) + fib($_[0]-2)
}

