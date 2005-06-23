#!/usr/bin/zsh

EXAMPLESBINDIR="/home/ibanez/bin/ITKGcc3.3/bin"
DATADIR="/home/ibanez/src/Insight/Examples/Data"

#
# Execute the example and capture the output.
#
$EXAMPLESBINDIR/ImageRegistration1 $DATADIR/BrainT1SliceBorder20.png $DATADIR/BrainProtonDensitySliceShifted13x17y.png ImageRegistration1Output.png | tee ImageRegistration1Output.txt

#
# Take the first 200 lines, and remove the characters "["  "]"  ","
#
head -n 200 ImageRegistration1Output.txt | sed "s/\]/ /g"  | sed "s/\,/ /g"  | sed "s/\[/ /g"  > ImageRegistration1OutputCleaned.txt

#
# Take the metric and translation data and generate plots with GNUPlot
#
gnuplot ImageRegistration1Figures.gnup
