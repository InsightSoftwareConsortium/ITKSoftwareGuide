#!/usr/bin/env perl

#
#
# This Script is used to infer figure dependencies from the .cxx/.txx source
# files in the Insight/Examples directory.
# 
# This automatic generation mechanism guaranties that the figures 
# presented on the SoftwareGuide book match exactly the code
# the is compiled and updated in the source repository.
#
# To automate generation, the example source files must contain tags such as
#   .
#   .
# //  Software Guide : BeginCommandLineArgs
# //    INPUTS: {BrainProtonDensitySlice.png}, {BrainProtonDensitySliceR13X13Y17.png}
# //    INPUTS: {SomeOtherInputfile.png}, {MoreInputfiles.png}
# //    OUTPUTS: {GradientDiffusedOutput.png}, {Output2.txt}
# //    5 0.25 3
# //  Software Guide : EndCommandLineArgs
#  .
#  .
#
# Multiple tags may be specified.
# 
# Please do not specify paths along with the file names. A list of search paths 
# where input data files may be found is specified through CMAKE. Paths are 
# specified in a colon seperated list such as
#     /Insight/Examples/Data:/VTK/VTKData
# Specifying the root path will suffice. A recursive search for input data 
# is done.
#
# The output of this script is a set of "ExampleSourceFileName.cmake" file. THe
# file contains a set of macros used by CMake to infer figure dependencies, 
# possibly across source files. ie. One example may be used to generate a 
# figure used as input to another example.
# 
# Dependencies for a figure are only inferred if the figure is included 
# in the software guide with the \includegraphics tag.
# 
# Generated figures are stored in Art/Generated.
# 
# The script is invoked from CMAKE if BUILD FIGURES is ON
#
# If BUILD FIGURES is OFF, it is expected that the images be present in either
# (.png, .fig, .jpg, .eps) format in the Art/ folder
#
#
use File::Spec; #for platform independent file paths
use File::Find; #for platform independent recursive search of input images in 
                #specified directories
use File::Copy;
use IO::File;

$numArgs = $#ARGV + 1;
if( $numArgs < 5 )
  {
  print "Usage arguments: \n".
  "  Name of the .cxx/.txx file (with extenstion).\n".
  "  ITKExecsDirectoryPath \n".
  "  Cmake file to be generated\n".
  "  Name of the TEX file generated, so dependencies can be specified\n".
  "  Ouput folder to store generated images\n".
  "  Colon separated list of possible include directories for input images\n".
  die;
  }

@searchdir = split(/:/, $ARGV[2]);
foreach $eachpath (@searchdir)
  {
    if (-d File::Spec->canonpath($eachpath))   # if the directory is valid
    { push (@searchdirs, File::Spec->canonpath($eachpath)); }
  }
GetArgsAndFilenames( $ARGV[1], $ARGV[0], \@searchdirs, $ARGV[3], $ARGV[4], $ARGV[5]);


#
#  Subroutine for parsing each one of the .cxx files.
#  The command line args and Figure file names are returned
#
sub GetArgsAndFilenames {

  my $execpath = shift;
  my $inputfilename  = shift;
  my $searchdirs = shift;
  my $cmakefile = shift;
  my $texfile = shift;
  my $generatedPath = shift;
  my $source_file =  $inputfilename;
  
  my $examplefilename = File::Spec->canonpath($inputfilename);
  if (!(-e $examplefilename)) 
    {
    die "File $examplefilename does not exist.\n"; 
    }


  #Strip the path and file extension to get the exec file name.
  #Exec file anme is assumed to be the same as the source filename
  my $volume; my $directories;
  ($volume,$directories,$inputsourcefile) = File::Spec->splitpath( $inputfilename );
  $inputsourcefile =~ m/(.*)(\.cxx|\.CXX|\.txx|\.TXX)/; 
  my $execfilenamebase = $1;

  #If the executable path has a leading /, remove it.
  if ($execpath =~ /\/$/)
    {
    $execpath =~ m/(.*)\//; 
    $execpath = $1;
    }
  if ($generatedPath =~ /\/$/)
    {
    $generatedPath =~ m/(.*)\//; 
    $generatedPath = $1;
    }

  # Make the path platform independent
  my @execdirs = File::Spec->splitdir($execpath);
  $execfilename = File::Spec->catfile(@execdirs, $execfilenamebase);

  #Get the command line args from the source file
  open(INFILE, "< $examplefilename"  )  or die "Can't open $examplefilename $!";

  #
  # Tag defs
  # 
  my $beginCmdLineArgstag = "BeginCommandLineArgs";
  my $endCmdLineArgstag   = "EndCommandLineArgs";
  my $fileinputstag = "INPUTS:";
  my $fileoutputstag = "OUTPUTS:";
  my $includegraphicstag = 'includegraphics';

  my $tagfound     = 0;
  my $filefound = 0;
  my $cmdLineArgs;
  my $thisline='';
  my $counter=0; 
  my $inputfileInThisLine;
  my $outputfileInThisLine;
  my @outputfilesInThisLine;
  my $artdir;
  my @outputs;
  
  #Create a .cmake file
  $cmakeFile =  File::Spec->canonpath($cmakefile);

  #Check if file exists
  if (-e $cmakeFile) 
    {
    open CMAKEFILE, "<  $cmakeFile" or die "Couldn't open $cmakeFile";
    @cmakelinesold = <CMAKEFILE>;   
    }
    
  
  #
  #Read each line and Parse the input file 
  #
  while(<INFILE>) 
    {
    $thisline=$_; 
    if ($thisline)
      {
      if ($thisline =~ /$beginCmdLineArgstag/)
        { 
        $tagfound = 1;
        $cmdLineArgs = '';
        @outputs = ();
        }
      elsif ($thisline =~ /$endCmdLineArgstag/)
        {
        # Add these commands to the .cmake file
        $tagfound=0;
        # Execute with command line args now.. 
        $toexecute = "$execfilename"." "."$cmdLineArgs";
        foreach $output (@outputs)
          { 
          foreach $generatedinput (@generatedinputfile)
            {
            $myline = sprintf("\n#This figure was generated by another example.. so add a dependency");
            push(@cmakelines, $myline);
            $myline = sprintf("\nADD_GENERATED_FIG_DEPS( \"%s\" \"%s\" )\n",$output,$generatedinput);
            push(@cmakelines, $myline);
            }
          $myline = sprintf("\n\n# Cmake macro to invoke: %s\n",$toexecute);
          push(@cmakelines, $myline);
          $myline = sprintf("RUN_EXAMPLE( \"%s\" \"%s\" \"%s\" %s )\n",$execfilenamebase,$output, $source_file, $cmdLineArgs);
          push(@cmakelines, $myline);
          }
        }
      
      #        
      #Read and parse each line of the command line args
      #
      if ($tagfound)
        {
        if (!($thisline =~ /$beginCmdLineArgstag/))
          {
          $_ =~ s/\/\///; 
          chomp;
          $line = $_;

          #Line contains file inputs
          #
          if ($thisline =~ /$fileinputstag/)
            {
            $line =~ s/$fileinputstag//; #Strip the tag away
            # squish more than one space into one
            $line =~ tr/ //s; 
            $line =~ s/^ *//; #strip leading and trailing spaces
            $line =~ s/ *$//;

            @inputfilesInThisLine = split(/,/,$line);

            # Search the path tree to get the full paths of the input files.
            foreach $inputfileInThisLine (@inputfilesInThisLine)
              {
              $inputfileInThisLine =~ m/{(.*)}/;
              $inputfileInThisLine = $1;
              if (($inputfileInThisLine =~ /{/) || ($inputfileInThisLine =~ /}/))
                { die "\nPlease check syntax. Input/Output files must be included ".
                  "in a comma separated list and enclosed in {} as in ".
                  "INPUTS: {file1}, {file2}, .... \n";  
                }       
              $filefound=0;

              foreach $searchelement (@$searchdirs)
                {
                File::Find::find (
                sub 
                  { 
                  if ($File::Find::name =~ /$inputfileInThisLine/) 
                    { 
                    # We found the file in the directory.
                    # Check to see if it is a plain file - not a directory
                    $foundfilename = $File::Find::name; 
                    $filefound = 1;
                    }
                  }, $searchelement);
                  if ($filefound)   { last;  }
                }

              if (!($filefound)) 
                {
                #die " File $inputfileInThisLine could not be found in the search paths supplied.";
                #File must be generated by another source....So must be found in the generatedPath
                $foundfilename = $generatedPath.'/'.$inputfileInThisLine;
                push(@generatedinputfile, $inputfileInThisLine);
                }
              
              #Add the file to the list of command line arguments in the same order
              $cmdLineArgs = $cmdLineArgs . ' ' . File::Spec->canonpath($foundfilename);
              }
            }
            
          #Line contains file outputs
          #
          elsif ($thisline =~ /$fileoutputstag/)
            {
            $line =~ s/$fileoutputstag//; #Strip the tag away
            # squish more than one space into one
            $line =~ tr/ //s; 
            $line =~ s/^ *//; #strip leading and trailing spaces
            $line =~ s/ *$//; 
            @outputfilesInThisLine = split(/,/,$line);
            
            # Search the path tree to get the full paths of the input files.
            foreach $outputfileInThisLine (@outputfilesInThisLine)
              {
              $outputfileInThisLine =~ m/{(.*)}/;
              $outputfileInThisLine = $1;
              push(@outputfiles, $1);
              
              if (($outputfileInThisLine =~ /{/) || ($outputfileInThisLine =~ /}/))
                { die "\nPlease check syntax. Input/Output files must be included ".
                  "in a comma separated list and enclosed in {} as in ".
                  "INPUTS: {file1}, {file2}, .... \n";  
                }       
              
              $tmp =   $generatedPath.'/'.$outputfileInThisLine;
              $outputfiletoadd = File::Spec->canonpath($tmp);  
                
              #Add the file to the list of command line arguments in the same order
              $cmdLineArgs = $cmdLineArgs . ' ' . $outputfiletoadd;
              push(@outputs, $outputfileInThisLine);
              }
            }

          else  #Not a file input, just a command line arg
            {
            $thisLineContains = join(' ', split); 
            $cmdLineArgs = $cmdLineArgs . ' ' . $thisLineContains;
            }    
          }
        }

        
      #
      #Parse file to see the list of eps files generated (through the includegraphics statement)
      #
      if ($thisline =~ /$includegraphicstag/)
        {
        $thisline =~ m/$includegraphicstag(.*)/; $thisline = $1;
        $thisline =~ m/{(.*)}/;    $thisline = $1;
        $thisline =~ s/ //; 
        $lateximgFile = $1;
        push (@lateximgfile, $lateximgFile);
        $lateximgFile =~ m/(.*)\./;
        $lateximgFilebase = $1;
        push (@lateximgfilebase, $lateximgFilebase);
        }
      }
    }

  #
  #
  #Covert using ImageMagick convert executable. It is expected that CMAKE
  #will pass the path etc to the script...For now we will assume that 
  #its path has been added and we needn't find 'convert'
  #
  #
  my $ctr=0;
  foreach $lateximgFile (@lateximgfile)
    {
    $lateximgFilebase = $lateximgfilebase[$ctr++];  
    foreach $cmdlineoutfile (@outputfiles)
      {
      if ($cmdlineoutfile =~ /$lateximgFilebase/)
        {
          $myline = sprintf("CONVERT_IMG( \"%s\" \"%s\" )\n",$cmdlineoutfile,$lateximgFile);       
          push(@cmakelines, $myline);
          $myline = sprintf("ADD_DEP_TEX_ON_EPS_FIGS( \"%s\" \"%s\" )\n",$texfile,$lateximgFile);                 
          push(@cmakelines, $myline);
        }
      }
    }
  if (@cmakelines) {
    $same=0;
    if (@cmakelinesold) {
      $same=1; $ctr=0;
      if (@cmakelinesold != @cmakelines) { $same =0; }
      else {
        foreach $cmakeline (@cmakelines) {
          $ctr++;
          if ($cmakeline != $cmakelinesold[$ctr]) { $same =0; }
          }
        }
      }
    }
  
  if (!($same)) {
    $cmakefilehandle = new IO::File $cmakeFile, "w";
    if (!(defined $cmakefilehandle)) { die "Could not open file $cmakeFile\n"; }
    foreach $cmakeline (@cmakelines) {
      $cmakefilehandle->printf("%s",$cmakeline);
      }
    }
  }

