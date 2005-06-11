#!/usr/bin/zsh

EXAMPLESBINDIR="/home/ibanez/bin/ITKGcc3.3/bin"
DATADIR="/home/ibanez/src/Insight/Examples/Data"

OUTPUTDATAFILE="ImageRegistration4Output.txt"
OUTPUTDATAFILECLEANED="ImageRegistration4OutputCleaned.txt"

#
# Execute the example and capture the output.
#
$EXAMPLESBINDIR/ImageRegistration4 $DATADIR/BrainT1SliceBorder20.png $DATADIR/BrainProtonDensitySliceShifted13x17y.png ImageRegistration4Output.png 0 ImageRegistration4CheckerBoardAfter.png ImageRegistration4CheckerBoardBefore.png | tee $OUTPUTDATAFILE
#
# Take the first 200 lines, and remove the characters "["  "]"  ","
#
head -n 200 $OUTPUTDATAFILE | sed "s/\]/ /g"  | sed "s/\,/ /g"  | sed "s/\[/ /g"  > $OUTPUTDATAFILECLEANED

#
# Take the metric and translation data and generate plots with GNUPlot
#
gnuplot ImageRegistration4Figures.gnup
