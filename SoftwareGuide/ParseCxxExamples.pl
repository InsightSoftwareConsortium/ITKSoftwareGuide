#!/usr/bin/env perl

print "number of arguments =  $#ARGV \n";

if( $#ARGV < 1 )
  {
  print "Usage: ".$ARG0." <input file with list of inputs> <output path> \n";
  exit;
  }

open(INLISTFILE, "$ARGV[0]"  )  or die "Can't open $ARGV[0] $!";
my @inputfiles = <INLISTFILE>;

foreach (@inputfiles) {
  ParseCxxFile( $_ , $ARGV[1] );
}


sub ParseCxxFile {

  my $inputfilename  = shift;
  my $outputfilename = shift;

  my $basefilename = $inputfilename;

  $basefilename =~ s/.*\///;
  $basefilename =~ s/\.cxx/.tex/;
  
  $outputfilename .= "/".$basefilename;

  # truncate the initial part of the path
  $inputfilename =~ /(Examples\/.*$)/;
  my $examplefilename = $1;

  print "Processing $inputfilename into $outputfilename  ... \n";

  open(INFILE,    "$inputfilename"  )  or die "Can't open $inputfilename $!";
  open(OUTFILE,  ">$outputfilename" )  or die "Can't open $outputfilename $!";

  my $beginlatextag = "BeginLatex";
  my $endlatextag   = "EndLatex";

  my $begincodesnippettag = "BeginCodeSnippet";
  my $endcodesnippettag   = "EndCodeSnippet";

  my $dumpinglatex = 0;
  my $dumpingcode  = 0;

  print OUTFILE "\% The following file is automatically generated\n";
  print OUTFILE "\% by a perl script from the original cxx sources\n";
  print OUTFILE "\% in the Insight/Examples directory\n";
  print OUTFILE "\% $examplefilename\n";
  print OUTFILE "\n\n";
  print OUTFILE "The sources of this code can be found in the file\\\\\n";
  print OUTFILE "\\texttt\{$examplefilename\}\n\n";

  while(<INFILE>) {

    my $tagfound     = 0;

    if( /$beginlatextag/ ) {
      $tagfound = 1;
      $dumpinglatex = 1;
      $dumpingcode  = 0;
      }
    elsif( /$begincodesnippettag/ ) {
      $tagfound = 1;
      $dumpinglatex = 0;
      $dumpingcode  = 1;
      print OUTFILE "\\begin{verbatim}\n";
      }
    elsif( /$endlatextag/ ) {
      $tagfound = 1;
      $dumpinglatex = 0;
      }
    elsif( /$endcodesnippettag/ ) {
      $tagfound = 1;
      $dumpingcode = 0;
      print OUTFILE "\\end{verbatim}\n";
      }
    if( !$tagfound ) {
      if( $dumpinglatex ) {
        my $outline = $_;
        $outline =~ s/\/\///; 
        print OUTFILE "$outline";
        }
      if( $dumpingcode ) {
        print OUTFILE "$_";
        }
      }

  }

}
