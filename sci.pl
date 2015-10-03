#!/usr/bin/env perl

use warnings;
use strict;
use File::Spec;
use FindBin;

sub usage{

print <<USAGE;

$FindBin::Script PATTERN

  This is a program to list sci journals and their impact 
  factor. The JOURNAL NAME PATTERN is actually considered 
  as Perl regular expression, see the following examples.

  $FindBin::Script plant       # Means journals contain 'plant'
  $FindBin::Script 'agri|hort' # Means journal names contain 'agri' or 'hort'
  $FindBin::Script .           # Means all journals   
  $FindBin::Script ^nat        # Means journals start with 'nat'
  $FindBin::Script sci\$       # Means journals end with 'sci'

USAGE
    exit;
}

sub get_pattern{
    usage unless @ARGV;
    return $ARGV[0];
}

sub sci_data_file_name{
    my $filename = q/data_sci_2015.csv/;
    my $fullname = File::Spec->catfile($FindBin::RealBin, $filename);
    return $fullname;
}

sub load_sci_data{
    my @journal;
    my $scidata = sci_data_file_name;
    open my $fh, "<", $scidata or die "$scidata: $!";
    my $title=<$fh>;
    chomp($title);
    $journal[0]=[(split(/,/,$title))];
    while(<$fh>){
        chomp;
        my @txt = split(/,/);
        unless($txt[4]){$txt[4] = 0}
        $journal[$txt[0]]=[@txt];
    }
    close $fh;
    return($title, \@journal);
}

sub grep_journal{
    my ($re, $title, $ref) = @_;
    my @journal = @$ref;

    my @results;
    print STDERR "----Searching: $re\n";
    foreach(1..$#journal){
        if($journal[$_]->[1] =~ /$re/i){
            push @results,$journal[$_];
        }
    }
    die "----WARNING: No journals found with names contain the text \"$re\"! Please specify another keyword.\n" 
        unless @results;
    my $count = 0;
    foreach(sort{$b->[4] <=> $a->[4]}@results){
        $count++;
        printf("%4s:|IF=%8.3f |Articles=%6d |ISSN=$_->[2]|Name=$_->[1]\n",$count,$_->[4],$_->[7]?$_->[7]:0);
    }
}

sub main{
    grep_journal(get_pattern(), load_sci_data());
}

main() unless caller;
