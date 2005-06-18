#!/usr/bin/zsh

EXAMPLESBINDIR="/home/ibanez/bin/ITKGcc3.3/bin"
DATADIR="/home/ibanez/src/Insight/Examples/Data"

OUTPUTDATAFILE="ImageRegistration7Output.txt"
OUTPUTDATAFILECLEANED="ImageRegistration7OutputCleaned.txt"

#
# Execute the example and capture the output.
#
$EXAMPLESBINDIR/ImageRegistration7 $DATADIR/BrainProtonDensitySliceBorder20.png $DATADIR/BrainProtonDensitySliceR10X13Y17S12.png ImageRegistration7Output.png ImageRegistration7DifferenceBefore.png ImageRegistration7DifferenceAfter.png 1.0 1.0 0.0 | tee $OUTPUTDATAFILE
#
# Take the first N lines, and remove the characters "["  "]"  ","
#
head -n 67 $OUTPUTDATAFILE | sed "s/\]/ /g"  | sed "s/\,/ /g"  | sed "s/\[/ /g"  > $OUTPUTDATAFILECLEANED



#
# Take the metric and translation data and generate plots with GNUPlot
#
gnuplot ImageRegistration7Figures.gnup
