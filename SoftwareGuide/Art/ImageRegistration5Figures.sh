#!/usr/bin/zsh

EXAMPLESBINDIR="/home/ibanez/bin/ITKGcc3.3/bin"
DATADIR="/home/ibanez/src/Insight/Examples/Data"

OUTPUTDATAFILE1="ImageRegistration5Output1.txt"
OUTPUTDATAFILECLEANED1="ImageRegistration5OutputCleaned1.txt"

#
# Execute the example and capture the output.
#
$EXAMPLESBINDIR/ImageRegistration5 $DATADIR/BrainProtonDensitySliceBorder20.png $DATADIR/BrainProtonDensitySliceRotated10.png ImageRegistration5Output.png ImageRegistration5DifferenceAfter.png ImageRegistration5DifferenceBefore.png 0.1 | tee $OUTPUTDATAFILE1
#
# Take the first 200 lines, and remove the characters "["  "]"  ","
#
head -n 20 $OUTPUTDATAFILE1 | sed "s/\]/ /g"  | sed "s/\,/ /g"  | sed "s/\[/ /g"  > $OUTPUTDATAFILECLEANED1



OUTPUTDATAFILE2="ImageRegistration5Output2.txt"
OUTPUTDATAFILECLEANED2="ImageRegistration5OutputCleaned2.txt"

#
# Execute the example and capture the output.
#
$EXAMPLESBINDIR/ImageRegistration5 $DATADIR/BrainProtonDensitySliceBorder20.png $DATADIR/BrainProtonDensitySliceRotated10.png ImageRegistration5Output.png ImageRegistration5DifferenceAfter.png ImageRegistration5DifferenceBefore.png 0.1 | tee $OUTPUTDATAFILE2
#
# Take the first 200 lines, and remove the characters "["  "]"  ","
#
head -n 20 $OUTPUTDATAFILE2 | sed "s/\]/ /g"  | sed "s/\,/ /g"  | sed "s/\[/ /g"  > $OUTPUTDATAFILECLEANED2


#
# Take the metric and translation data and generate plots with GNUPlot
#
gnuplot ImageRegistration5Figures.gnup
