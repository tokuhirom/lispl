use strict;
use warnings;
use utf8;
use Test::More;

require 'lis.pl';

is_deeply(run('(list 1 2 3)'), [qw/( list 1 2 3 )/]);
is_deeply(run('(list "hoge")'), [qw/( list "hoge" )/]);

done_testing;

sub run {
    my $src = shift;
    open my $fh, '<', \$src;
    my $scanner = Lispl::Scanner->new($fh);
    my @ret;
    while (1) {
        my $token = $scanner->next_token();
        if (ref $token) {
            last;
        }
        push @ret, $token;
    }
    return \@ret;
}
