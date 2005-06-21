#!/usr/bin/zsh

EXAMPLESBINDIR="/home/ibanez/bin/ITKGcc3.3/bin"
DATADIR="/home/ibanez/src/Insight/Examples/Data"

OUTPUTDATAFILE="MeanSquaresMetricOutput.txt"

#
# Execute the example and capture the output.
#
$EXAMPLESBINDIR/MeanSquaresImageMetric1 $DATADIR/BrainProtonDensitySlice.png $DATADIR/BrainProtonDensitySlice.png | tee $OUTPUTDATAFILE


#
# Take the metric and translation data and generate plots with GNUPlot
#
gnuplot MeanSquaresMetricFigures.gnup
