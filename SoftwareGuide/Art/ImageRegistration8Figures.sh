#!/usr/bin/zsh
# script to execute ImageRegistration8.cxx, and capture the output and plot it
# with gnuplot


EXAMPLESBINDIR="/home/ibanez/bin/ITKGcc3.3/bin"
BRAINWEBDATADIR="/home/ibanez/data/BrainWeb"

OUTPUTDATAFILE="ImageRegistration8Output.txt"
OUTPUTDATAFILECLEANED="ImageRegistration8OutputCleaned.txt"

#
# Execute the example and capture the output.
#
$EXAMPLESBINDIR/ImageRegistration8 $BRAINWEBDATADIR/brainweb1e1a10f20.mha $BRAINWEBDATADIR/brainweb1e1a10f20Rot10Tx15.mha ImageRegistration8Output.mhd ImageRegistration8DifferenceBefore.mhd ImageRegistration8DifferenceAfter.mhd ImageRegistration8Output.png ImageRegistration8DifferenceBefore.png ImageRegistration8DifferenceAfter.png | tee $OUTPUTDATAFILE

#
# Take the first N lines, and remove the characters "["  "]"  ","
#
head -n 23 $OUTPUTDATAFILE | sed "s/\]/ /g"  | sed "s/\,/ /g"  | sed "s/\[/ /g"  > $OUTPUTDATAFILECLEANED

#
# Take the metric and translation data and generate plots with GNUPlot
#
# gnuplot ImageRegistration8Figures.gnup
