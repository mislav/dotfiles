#!/usr/bin/env perl
 
# Finds duplicate adjacent words.
 
use strict ;
 
my $DupCount = 0 ;
 
if (!@ARGV) {
  print "usage: dups <file> ...\n" ;
  exit ;
}
 
while (1) {
  my $FileName = shift @ARGV ;
 
  # Exit code = number of duplicates found. 
  exit $DupCount if (!$FileName) ;
 
  open FILE, $FileName or die $!;
   
  my $LastWord = "" ;
  my $LineNum = 0 ;
   
  while (<FILE>) {
    chomp ;
 
    $LineNum ++ ;
     
    my @words = split (/(\W+)/) ;
     
    foreach my $word (@words) {
      # Skip spaces:
      next if $word =~ /^\s*$/ ;
 
      # Skip punctuation:
      if ($word =~ /^\W+$/) {
        $LastWord = "" ;
        next ;
      }
       
      # Found a dup?
      if (lc($word) eq lc($LastWord)) {
        print "$FileName:$LineNum $word\n" ;
        $DupCount ++ ;
      } # Thanks to Sean Cronin for tip on case.
 
      # Mark this as the last word:
      $LastWord = $word ;
    }
  }
   
  close FILE ;
}
