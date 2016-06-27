#!/usr/bin/env perl

use warnings;
use strict;
use FindBin;

sub usage{
    print <<"end_of_usage";

Usage
    $FindBin::Script [pattern]

Description
    This is a program to list sci journals and their impact 
    factor. The given pattern is considered as Perl regular 
    expression, see the following examples.

    $FindBin::Script plant       # Means journals contain 'plant'
    $FindBin::Script 'agri|hort' # Means journal names contain 'agri' or 'hort'
    $FindBin::Script .           # Means all journals   
    $FindBin::Script ^nat        # Means journals start with 'nat'
    $FindBin::Script sci\$        # Means journals end with 'sci'

end_of_usage
    exit;
}

sub main{
    usage unless @ARGV == 1;
    my $pattern = shift @ARGV;
    
    my ($year, 
        $journal_title_index, 
        $ISSN_index, 
        $IF_index,
        $articles_index, )
#    = (2014, 1, 2, 4, 7);
     =(2015, 2, 3, 5, 9);    
    my @results;
    my $scidata = "$FindBin::RealBin/data_sci_$year.csv";
    open my $fh, "<", $scidata or die "$scidata: $!";
    
    # title
    my $title = <$fh>;
    chomp($title);
    my @title = split(/,/, $title);

    # journal data
    while(<$fh>){
        chomp;
        my @a = split(/,/);
        $a[$IF_index] = 0 unless $a[$IF_index] =~ /^\d+\.\d+$/;
        push @results,[@a] if $a[$journal_title_index] =~ /$pattern/i;
    }
    close $fh;

    die "\nWARNING: Nothing found for \"$pattern\"\n\n" unless @results;
    my $count = 0;
    print "\n";
    for my $a (sort{$b->[$IF_index] <=> $a->[$IF_index]}@results){
        $count++;
        printf "%4s:|IF=%8.3f |Articles=%6d |ISSN=%s|Name=%s\n",
            $count, 
            $a->[$IF_index], 
            $a->[$articles_index] ? $a->[$articles_index] : 0, 
            $a->[$ISSN_index],
            $a->[$journal_title_index];
    }
    print "\n";
}

main() unless caller;

__END__
