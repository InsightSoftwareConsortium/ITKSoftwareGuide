#!/usr/bin/zsh

EXAMPLESBINDIR="/home/ibanez/bin/ITKGcc3.3/bin"
DATADIR="/home/ibanez/src/Insight/Examples/Data"

#
# Execute the example and capture the output.
#
# $EXAMPLESBINDIR/ImageRegistration2 $DATADIR/BrainT1SliceBorder20.png $DATADIR/BrainProtonDensitySliceShifted13x17y.png ImageRegistration2Output.png | tee ImageRegistration2Output.txt

#
# Take the first 200 lines, and remove the characters "["  "]"  ","
#
head -n 200 ImageRegistration2Output.txt | sed "s/\]/ /g"  | sed "s/\,/ /g"  | sed "s/\[/ /g"  > ImageRegistration2OutputCleaned.txt

#
# Take the metric and translation data and generate plots with GNUPlot
#
gnuplot ImageRegistration2Figures.gnup
