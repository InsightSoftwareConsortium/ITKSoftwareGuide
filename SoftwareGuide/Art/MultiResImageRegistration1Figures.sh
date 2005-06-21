#!/usr/bin/zsh

EXAMPLESBINDIR="/home/karthik/work/ITK/binaries/Insight/Nightly/bin"
DATADIR="/home/karthik/work/ITK/src/Insight/Nightly/Examples/Data"

#
# Execute the example and capture the output.
#
$EXAMPLESBINDIR/MultiResImageRegistration1 $DATADIR/BrainT1SliceBorder20.png $DATADIR/BrainProtonDensitySliceShifted13x17y.png MultiResImageRegistration1Output.png | tee MultiResImageRegistration1Output.txt

#
# Take the first 6 lines, and remove the characters "["  "]"  ","
#
head -n 6 MultiResImageRegistration1Output.txt | sed "s/\]/ /g"  | sed "s/\,/ /g"  | sed "s/\[/ /g"  > MultiResImageRegistration1OutputCleanedQuarterRes.txt

head -n 100 MultiResImageRegistration1Output.txt | sed "s/\]/ /g"  | sed "s/\,/ /g"  | sed "s/\[/ /g"  > MultiResImageRegistration1OutputCleaned2.txt

#
# Take the metric and translation data and generate plots with GNUPlot
#
gnuplot MultiResImageRegistration1Figures.gnup
