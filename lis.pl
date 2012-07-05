use strict;
use warnings;
use utf8;
use 5.16.0;
use autodie;

package Lispl::Env {
    use List::Util qw(reduce);
    sub new {
        my ($class, $outer) = @_;
        bless {
            data => {
            },
            outer => $outer,
        }, $class;
    }
    sub update {
        my ($self, $vars, $args) = @_;
        for my $i (0..0+@$vars-1) {
            $self->data->{$vars->[$i]} = $args->[$i];
        }
    }
    sub init_globals {
        my $self = shift;
        my %data = (
            '+' => sub { reduce { $a + $b } @_ },
            '-' => sub { reduce { $a - $b } @_ },
            '*' => sub { reduce { $a * $b } @_ },
            '/' => sub { reduce { $a / $b } @_ },
            '<=' => sub { $_[0] <= $_[1] },
            '>=' => sub { $_[0] >= $_[1] },
            'say' => sub { say @_ },
        );
        for my $k (keys %data) {
            $self->data->{$k} = $data{$k};
        }
    }
    sub find {
        my ($self, $key) = @_;
        if (exists $self->data->{$key}) {
            $self
        } else {
            if ($self->outer) {
                $self->outer->find($key);
            } else {
                die "Name of $key not found";
            }
        }
    }

    sub outer { shift->{outer} }
    sub data  { shift->{data} }
}

package Lispl {
    sub new {
        my $class = shift;
        bless {
            global_env => do {
                my $env = Lispl::Env->new();
                $env->init_globals;
                $env;
            }
        }, $class;
    }

    sub evaluate {
        my ($self, $x, $env) = @_;
        $env ||= $self->{global_env};

        if (!ref $x && $x !~ /^\d+$|^\d+\.\d+$/) { # it's variable
            return $env->find($x)->data->{$x};
        } elsif (!ref $x) {
            return $x; # atom
        } elsif ($x->[0] eq 'quote') {
            shift @$x;
            return $x;
        } elsif ($x->[0] eq 'if') {
            if ($self->evaluate($x->[1], $env)) {
                return $self->evaluate($x->[2], $env);
            } else {
                return $self->evaluate($x->[3], $env);
            }
        } elsif ($x->[0] eq 'set!') {
            my (undef, $var, $exp) = @$x;
            $env->find($var)->data->{$var} = $self->evaluate($exp, $env);
        } elsif ($x->[0] eq 'define') {
            my (undef, $var, $exp) = @$x;
            $env->data->{$var} = $self->evaluate($exp, $env);
        } elsif ($x->[0] eq 'lambda') {
            my (undef, $vars, $exp) = @$x;
            return sub {
                my $env = Lispl::Env->new($env);
                $env->update($vars, \@_);
                $self->evaluate($exp, $env);
            };
        } elsif ($x->[0] eq 'begin') { # (begin *exp)
            my (undef, @exp) = @$x;
            my $ret;
            for (@exp) {
                $ret = $self->evaluate($_, $env);
            }
            return $ret;
        } else { # (proc exp*)
            my @exps = map { $self->evaluate($_, $env) } @$x;
            my $proc = shift @exps;
            return $proc->(@exps);
        }
    }

    sub parse {
        my ($class, $src) = @_;
        read_from($class->tokenize($src));
    }

    sub read_from {
        my $tokens = shift;
        if (0+@$tokens == 0) {
            die "unexpected EOF while reading";
        }
        my $token = shift @$tokens;
        given ($token) {
            when ('(') {
                my @L;
                while ($tokens->[0] ne ')') {
                    push @L, read_from($tokens);
                }
                shift @$tokens; # pop off ')'
                return \@L;
            }
            when (')') {
                die 'unexpected ")"';
            }
            default {
                return $token;
            }
        }
    }

    sub tokenize($) {
        my $class = shift;
        local $_ = shift;
        s/\(/ ( /g;
        s/\)/ ) /g;
        [grep { length $_ } split /\s+/, $_];
    }
}

use File::Basename qw(dirname);
use Getopt::Long;
unless (caller) {
    GetOptions(
        'e=s' => \my $expression,
    );
    if ($expression) {
        my $lispl = Lispl->new();
        my $tree = $lispl->parse($expression);
        my $ret = $lispl->evaluate($tree);
        warn Dumper($ret);
        exit;
    }
    while (1) {
        print "lispl> ";
        my $line = <> // last;
        chomp $line;
        my $tree = Lispl->parse($line);
        use Data::Dumper;
        warn Dumper($tree);
    }
}
