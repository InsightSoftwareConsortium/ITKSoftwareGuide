#!/bin/bash

EXAMPLESBINDIR="/scratch/ITK-softwareGuide/release/bin"
DATADIR="/scratch/ITK/ITK/Examples/Data"

OUTPUTDATAFILE="MultiStageImageRegistration1Output.txt"
OUTPUTDATAFILECLEANED="MultiStageImageRegistration1OutputCleaned.txt"

#
# Execute the example and capture the output.
#
$EXAMPLESBINDIR/MultiStageImageRegistration1 $DATADIR/BrainT1SliceBorder20.png $DATADIR/BrainProtonDensitySliceR10X13Y17.png MultiStageImageRegistration1Output.png 100 MultiStageImageRegistration1CheckerboardBefore.png MultiStageImageRegistration1CheckerboardAfter.png | tee $OUTPUTDATAFILE

#
# Take the first 5 lines, and remove the characters "["  "]"  ","
#
head -n 100 MultiStageImageRegistration1Output.txt | sed "s/\]/ /g"  | sed "s/\,/ /g"  | sed "s/\[/ /g"  > $OUTPUTDATAFILECLEANED

#
# Take the metric and translation data and generate plots with GNUPlot
#
gnuplot MultiStageImageRegistration1Figures.gnup
