#!/usr/bin/zsh

EXAMPLESBINDIR="/home/ibanez/bin/ITKGcc3.3/bin"
DATADIR="/home/ibanez/src/Insight/Examples/Data"

OUTPUTDATAFILE="ImageRegistration6Output.txt"
OUTPUTDATAFILECLEANED="ImageRegistration6OutputCleaned.txt"

#
# Execute the example and capture the output.
#
$EXAMPLESBINDIR/ImageRegistration6 $DATADIR/BrainProtonDensitySliceBorder20.png $DATADIR/BrainProtonDensitySliceR10X13Y17.png ImageRegistration6Output.png ImageRegistration6DifferenceBefore.png ImageRegistration6DifferenceAfter.png | tee $OUTPUTDATAFILE
#
# Take the first N lines, and remove the characters "["  "]"  ","
#
head -n 22 $OUTPUTDATAFILE | sed "s/\]/ /g"  | sed "s/\,/ /g"  | sed "s/\[/ /g"  > $OUTPUTDATAFILECLEANED



#
# Take the metric and translation data and generate plots with GNUPlot
#
gnuplot ImageRegistration6Figures.gnup
