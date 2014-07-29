#!/bin/bash

EXAMPLESBINDIR="/scratch/ITK-softwareGuide/release/bin"
DATADIR="/scratch/ITK/ITK/Examples/Data"

OUTPUTDATAFILE="MultiStageImageRegistration2Output.txt"
OUTPUTDATAFILECLEANED="MultiStageImageRegistration2OutputCleaned.txt"

#
# Execute the example and capture the output.
#
$EXAMPLESBINDIR/MultiStageImageRegistration2 $DATADIR/BrainT1SliceBorder20.png $DATADIR/BrainProtonDensitySliceR10X13Y17.png MultiStageImageRegistration2Output.png 100 MultiStageImageRegistration2CheckerboardBefore.png MultiStageImageRegistration2CheckerboardAfter.png | tee $OUTPUTDATAFILE

#
# Take the first 5 lines, and remove the characters "["  "]"  ","
#
head -n 100 MultiStageImageRegistration2Output.txt | sed "s/\]/ /g"  | sed "s/\,/ /g"  | sed "s/\[/ /g"  > $OUTPUTDATAFILECLEANED

#
# Take the metric and translation data and generate plots with GNUPlot
#
gnuplot MultiStageImageRegistration2Figures.gnup
