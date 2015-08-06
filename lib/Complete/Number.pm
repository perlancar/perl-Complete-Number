package Complete::Number;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
#use experimental 'smartmatch';
#use Log::Any::IfLOG '$log';

use Complete;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(
                       complete_int
                       complete_float
               );
our %SPEC;

$SPEC{':package'} = {
    v => 1.1,
    summary => 'Complete numbers',
};

my %common_args = (
    word => { schema=>[str=>{default=>''}], pos=>0, req=>1 },
    ci   => { schema=>['bool'] },
);

$SPEC{complete_int} = {
    v => 1.1,
    summary => 'Complete integer number',
    args => {
        %common_args,
        max  => ['int'],
        min  => ['int'],
        xmax => ['int'],
        xmin => ['int'],
    },
    result_naked => 1,
    result => {
        schema => 'array',
    },
};
sub complete_int {
    my %args = @_;
    my $word = $args{word} // "";
    my $ci   = $args{ci} // $Complete::OPT_CI;

    my @words;

    my $limit = 100;
    if(defined($args{min}) && defined($args{max}) &&
           $args{max}-$args{min} <= $limit) {
        push @words, $args{min} .. $args{max};
    } elsif (defined($args{min}) && defined($args{xmax}) &&
                 $args{xmax}-$args{min} <= $limit) {
        push @words, $args{min} .. $args{xmax}-1;
    } elsif (defined($args{xmin}) && defined($args{max}) &&
                 $args{max}-$args{xmin} <= $limit) {
        push @words, $args{xmin}+1 .. $args{max};
    } elsif (defined($args{xmin}) && defined($args{xmax}) &&
                 $args{xmax}-$args{xmin} <= $limit) {
        push @words, $args{xmin}+1 .. $args{xmax}-1;
    } elsif (length($word) && $word !~ /\A-?\d*\z/) {
        # warn: not an int
    } else {
        # do a digit by digit completion
        my @signs = ("");
        push @signs, "-" if $word =~ /\A-|\A\z/;
        for my $sign (@signs) {
            for ("", 0..9) {
                my $i = $sign . $word . $_;
                next unless length $i;
                next unless $i =~ /\A-?\d+\z/;
                next if $i eq '-0';
                next if $i =~ /\A-?0\d/;
                next if defined($args{min} ) && $i <  $args{min};
                next if defined($args{xmin}) && $i <= $args{xmin};
                next if defined($args{max} ) && $i >  $args{max};
                next if defined($args{xmin}) && $i >= $args{xmax};
                push @words, $i;
            }
        }
    }

    @words = sort {$a cmp $b} @words;
    \@words;
}

$SPEC{complete_float} = {
    v => 1.1,
    summary => 'Complete floating number',
    args => {
        %common_args,
        max  => ['float'],
        min  => ['float'],
        xmax => ['float'],
        xmin => ['float'],
    },
    result_naked => 1,
    result => {
        schema => 'array',
    },
};
sub complete_float {
    my %args = @_;
    my $word = $args{word} // "";
    my $ci   = $args{ci} // $Complete::OPT_CI;

    my @words;

    my $limit = 100;

    if (length($word) && $word !~ /\A-?\d*(\.\d*)?\z/) {
        # warn: not a float
    } else {
        my @signs = ("");
        push @signs, "-" if $word =~ /\A-|\A\z/;
        for my $sign (@signs) {
            for ("", 0..9,
                 ".0",".1",".2",".3",".4",".5",".6",".7",".8",".9") {
                my $f = $sign . $word . $_;
                next unless length $f;
                next unless $f =~ /\A-?\d+(\.\d+)?\z/;
                next if $f eq '-0';
                next if $f =~ /\A-?0\d\z/;
                next if defined($args{min} ) && $f <  $args{min};
                next if defined($args{xmin}) && $f <= $args{xmin};
                next if defined($args{max} ) && $f >  $args{max};
                next if defined($args{xmin}) && $f >= $args{xmax};
                push @words, $f;
            }
        }
    }

    @words = sort {$a cmp $b} @words;
    \@words;
}


1;
# ABSTRACT:

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 SEE ALSO

L<Complete>

=cut
