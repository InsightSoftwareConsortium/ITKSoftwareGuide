Command Line Arguments
======================

This section summarizes the command line arguments used for running the
examples presented all along the text. You may use these values for
future reference as good initial guesses of parameters. Then play
modifying the values in order to appreciate their effect on the results
of the filter.

For simplicity we assume here that the image files are in the same
directory than the executables, or what is equivalent, that the
executables are in the path and we are located in the data directory.

Filtering
---------

::

  BilateralImageFilter BrainProtonDensitySlice.png BilateralImageFilterOutput.png 6.0 5.0
  BinaryMinMax BrainProtonDensitySlice.png BinaryMinMaxOutput.png 10 0.25 1 128
  BinaryThresholdImageFilter BrainProtonDensitySlice.png BinaryThresholdImageFilterOutput.png 150 180 0 255
  BinomialBlurImageFilter BrainProtonDensitySlice.png BinomialBlurImageFilterOutput.png 5
  CastingImageFilter \*\* It is grouping several casting filters, not accepting parameters, not writing to files

  CurvatureAnisotropicDiffusionImageFilter BrainProtonDensitySlice.png
  CurvatureAnisotropicDiffusionImageFilterOutput.png 5 0.25 3.0
  CurvatureFlowImageFilter BrainProtonDensitySlice.png
  CurvatureFlowImageFilterOutput.png 5 0.25
  DanielssonDistanceMapImageFilter FivePoints.png DanielssonDistanceMapImageFilterOutput1.png DanielssonDistanceMapImageFilterOutput2.png DanielssonDistanceMapImageFilterOutput3.mha
  DiscreteGaussianImageFilter BrainProtonDensitySlice.png DiscreteGaussianImageFilterOutput.png 1.73 10
  GradientAnisotropicDiffusionImageFilter BrainProtonDensitySlice.png GradientAnisotropicDiffusionImageFilterOutput.png 5 0.25 3.0
  GradientMagnitudeImageFiler BrainProtonDensitySlice.png GradientMagnitudeImageFilerOutput.png
  GradientMagnitudeRecursiveGaussianImageFilter BrainProtonDensitySlice.png GradientMagnitudeRecursiveGaussianImageFilterOutput.png 5
  LaplacianImageFilter BrainProtonDensitySlice.png LaplacianImageFilterOutput.png
  MathematicalMorphologyBinaryFilters BrainProtonDensitySlice.png MathematicalMorphologyBinaryFiltersErode.png MathematicalMorphologyBinaryFiltersErodeDilate.png 150 180
