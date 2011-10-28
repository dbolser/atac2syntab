#!/usr/bin/perl -w

use strict;

use Getopt::Long;

my $verbose = 0;
my $clump_file;
my $source = 'UoD ATAC A2A';

GetOptions(
           "cf=s"     => \$clump_file,
           "source=s" => \$source,
           "verbose"  => \$verbose,
          )
  or die "failed to parse command line options\n";

$clump_file = $ARGV[0]
  unless defined $clump_file;

die "pass a clump file you lump\n"
  unless -s $clump_file;



## Grab sequence lengths

#my $psl_file = 'Data/PGSC0003DM/Indexes/PGSC0003DMB.fa.len';
#my $psl_file = '/homes/dbolser/BiO/Research/Potato/Assembly/Scaffolding/potato_agp/all.agp.seq.len';

my $psl_file = '/homes/dbolser/BiO/Research/Potato/Assembly/Scaffolding/potato_agp-v2.1.9/PGSC_DM_v3_PM-2.1.9-2.seq.len';
my $tsl_file = 'Assembly/build_2.40/S_lycopersicum_chromosomes.2.40.fa.len';


open PSL, '<', $psl_file or die "failed to open $psl_file : $!\n";
open TSL, '<', $tsl_file or die "failed to open $tsl_file : $!\n";

my %psl;
while(<PSL>){chomp; my ($id, $len) = split/\t/; $psl{$id} = $len}
warn "got the length of ", scalar keys %psl, " potato sequences\n";

my %tsl;
while(<TSL>){chomp; my ($id, $len) = split/\t/; $tsl{$id} = $len}
warn "got the length of ", scalar keys %tsl, " tomato sequences\n";





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
    
    die "seq?\t$hit\n" unless my $hs_len = $tsl{$hit};
    die "seq?\t$que\n" unless my $qs_len = $psl{$que};
    
    my $h_end = $h_off + $h_len;
    my $q_end = $q_off + $q_len;
    
    my $h_offx = sprintf("%.1f", $h_off/$hs_len * 100);
    my $h_endx = sprintf("%.1f", $h_end/$hs_len * 100);
    my $h_lenx = sprintf("%.1f", $h_len/$hs_len * 100);
    
    my $q_offx = sprintf("%.1f", $q_off/$qs_len * 100);
    my $q_endx = sprintf("%.1f", $q_end/$qs_len * 100);
    my $q_lenx = sprintf("%.1f", $q_len/$qs_len * 100);
    
    
    
    my $type;
    
    ## Grab 'clumps'
    if(/^M c /){
        $type = 'run';
        $run{$match_id} = [$h_off, $h_end, $q_off, $q_end];
    }
    
    ## Check 'blocks' (AND THEN DISCARD...)
    else{
        die unless /^M u /;
        if(!exists $run{$pmatch_id}){
            if($pmatch_id eq '.'){
                $type = 'singleton';
            }
            else{
                $type = 'block';
                die "missing parent: $_";
            }
        }
        else{
            # check range is within parent range?
        }
        ## Comment out to include 'blocks' and singletons
        next;
    }
    
    #   print
    #     join("\t",
    #          $hit, $source, $type, $h_off, $h_end, 0, '.', ($h_strand > 0 ? '+' : '-'),
    #          join("; ", "ID=$match_id", "Target=$que $q_off $q_end ". ($q_strand > 0 ? '+' : '-'),
    #              ($type eq 'block' ? "Parent=$pmatch_id" : ''))
    #         ), "\n";
    
    
    my $q_phase = ($q_strand > 0 ? '+' : '-');
    my $h_phase = ($h_strand > 0 ? '+' : '-');
    
    if($q_strand<0){
        ($h_offx, $h_endx) = ($h_endx, $h_offx);
    }
    
    print
      join("\t",
           $que, $source, $type, $q_off, $q_end, '.', $q_phase, '.',
           join(";",
                "ID=$match_id",
                "Target=$hit $h_off $h_end ". $h_phase,
                "Note=$hit from $h_offx% to $h_endx%",
               )
          ). ($type eq 'block' ? ";Parent=$pmatch_id" : '' ),
            "\n";
    
}

warn "OK\n";

