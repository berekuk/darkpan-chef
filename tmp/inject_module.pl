#!/usr/bin/env perl

use strict;
use warnings;

use IPC::System::Simple;
use autodie qw(:all);

use File::Basename;

sub main {
    my @args = @_;
    unless (@args == 1) {
        die "Usage: inject_module.pl foo.tar.gz\n";
    }
    my $distr = shift @args;
    my $file = basename $distr;

    # 'darkpan-vagrant' host should be configured using the following command:
    # vagrant ssh-config --host darkpan-vagrant >>~/.ssh/config
    system("scp $distr darkpan-vagrant:/tmp/");

    system("ssh darkpan-vagrant sudo orepan.pl --destination=/opt/orepan --pause=MMCLERIC /tmp/$file");
    system("ssh darkpan-vagrant sudo orepan_index.pl --repository=/opt/orepan");

    system("ssh darkpan-vagrant sudo /opt/cpan-api/bin/metacpan release --cpan /opt/orepan /opt/orepan/authors/id/");
    system("ssh darkpan-vagrant 'cd /opt/cpan-api && sudo bin/metacpan latest --cpan /opt/orepan'");
    # authors indexing is broken
    #system("ssh darkpan-vagrant sudo /opt/cpan-api/bin/metacpan author --cpan /opt/orepan");
}

main(@ARGV) unless caller;
