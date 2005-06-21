#!/usr/bin/zsh

EXAMPLESBINDIR="/home/karthik/work/ITK/binaries/Insight/Nightly/bin"
DATADIR="/home/karthik/work/ITK/src/Insight/Nightly/Examples/Data"

#
# Execute the example and capture the output.
#
$EXAMPLESBINDIR/MultiResImageRegistration2 $DATADIR/BrainT1SliceBorder20.png $DATADIR/BrainProtonDensitySliceShifted13x17y.png MultiResImageRegistration2Output.png | tee MultiResImageRegistration2Output.txt

#
# Take the first 5 lines, and remove the characters "["  "]"  ","
#
head -n 100 MultiResImageRegistration2Output.txt | sed "s/\]/ /g"  | sed "s/\,/ /g"  | sed "s/\[/ /g"  > MultiResImageRegistration2OutputCleaned.txt

#
# Take the metric and translation data and generate plots with GNUPlot
#
gnuplot MultiResImageRegistration2Figures.gnup
