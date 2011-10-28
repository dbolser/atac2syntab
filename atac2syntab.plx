#!/usr/bin/perl -w

use strict;

use Getopt::Long;

my $verbose = 0;
my $clump_file;
my $source = 'UoD ATAC A2A';

my $s1 = 'tom';
my $s2 = 'pot';

GetOptions(
           "cf=s"     => \$clump_file,
           "source=s" => \$source,
           "verbose"  => \$verbose,
           "s1=s"     => \$s1,
           "s2=s"     => \$s2,
          )
  or die "failed to parse command line options\n";

$clump_file = $ARGV[0]
  unless defined $clump_file;

die "pass a clump file you lump\n"
  unless -s $clump_file;



## Parse clumpy

my %run;

while(<>){
  unless(/^M/){
    warn "skipping header line : $_"
      if $verbose > 0;
    next
  }
  
  my ($class, $match_type, $match_id, $pmatch_id,
      $hit, $h_off, $h_len, $h_strand,
      $que, $q_off, $q_len, $q_strand,
     ) = split /\s/;
  
  my $h_end = $h_off + $h_len;
  my $q_end = $q_off + $q_len;
  
  my $type = 'block';
  
  ## Grab the clumps (or not!)
  
  ## Clumps
  next unless /^M c /;

  ## Grains
  #next if /^M c /;
  
  print
    join("\t",
         $s1, $hit, $h_off, $h_end, ($h_strand >= 0 ? '+' : '-'), '.',
         $s2, $que, $q_off, $q_end, ($q_strand >= 0 ? '+' : '-'), '.',
        ), "\n";
  
}

warn "OK\n";

