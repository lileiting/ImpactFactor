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
    my @results;
    print STDERR "----Searching: $pattern\n";
    
    my $scidata = "$FindBin::RealBin/data_sci_2014.csv";
    open my $fh, "<", $scidata or die "$scidata: $!";
    
    # title
    my $title = <$fh>;
    chomp($title);
    my @title = split(/,/, $title);

    # journal data
    while(<$fh>){
        chomp;
        my @txt = split(/,/);
        
        # impact factor
        $txt[4] = 0 unless $txt[4];
        
        # Journal title
        if($txt[1] =~ /$pattern/i){
            push @results,[@txt];
        }
    }
    close $fh;

    die "----WARNING: No journals found with names contain the text \"$pattern\"! Please specify another keyword.\n" 
        unless @results;
    my $count = 0;
    for(sort{$b->[4] <=> $a->[4]}@results){
        $count++;
        printf("%4s:|IF=%8.3f |Articles=%6d |ISSN=$_->[2]|Name=$_->[1]\n",
            $count,$_->[4],$_->[7]?$_->[7]:0);
    }
    
}

main() unless caller;

__END__