#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use 5.010000;

use Benchmark qw(cmpthese timethese);

require 'lis.pl';

my $lispl = Lispl->new();
$lispl->evaluate($lispl->parse(<<'...'));
(define fib (lambda (n)
        (if (< n 2)
            1
            (+ (fib (- n 1)) (fib (- n 2))))))
...
my $tree = $lispl->parse('(fib 20)');
# test
{
    my $a = fib(20);
    my $b = $lispl->evaluate($tree);
    $a == $b or die "$a != $b";
}


cmpthese(
    10 => {
        'perl' => sub { fib(20) },
        'lispl' => sub { $lispl->evaluate($tree) },
    }
);

sub fib {
    $_[0] < 2 ? 1 : fib($_[0]-1) + fib($_[0]-2)
}

__END__

20120706 optimized evaluator

            (warning: too few iterations for a reliable count)
        s/iter  lispl   perl
lispl     3.51     --  -100%
perl  1.20e-02 29125%     --

20120706 b43d80cbf4460178c0abc9b649721ee53791e4b9

            (warning: too few iterations for a reliable count)
        s/iter  lispl   perl
lispl     3.34     --  -100%
perl  1.20e-02 27717%     --

