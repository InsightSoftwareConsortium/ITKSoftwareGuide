#
#  Convert images from different formats
#  into Encapsulated Postscript to be 
#  included in LaTeX files.
#



# 
# Find ImageMagick tools
# This is used to convert image formats
#
INCLUDE (${CMAKE_ROOT}/Modules/FindImageMagick.cmake)


ADD_CUSTOM_TARGET(SoftwareGuideArt  ALL echo)

SET(JPEG_IMAGES
  BilateralImageFilterOutput
  BinaryThresholdImageFilterOutput
  BinaryMinMaxCurvatureFlowImageFilterOutput
  BinomialBlurImageFilterOutput
  BrainProtonDensitySlice
  ccmakeScreenShot
  CurvatureFlowImageFilterOutput
  CurvatureAnisotropicDiffusionImageFilterOutput
  CMakeSetupScreenShot
  DiscreteGaussianImageFilterOutput
  DanielssonDistanceMapImageFilterOutput1
  DanielssonDistanceMapImageFilterOutput2
  Dashboard
  FivePoints
  GradientMagnitudeImageFilterOutput
  GradientMagnitudeRecursiveGaussianImageFilterOutput3
  GradientMagnitudeRecursiveGaussianImageFilterOutput5
  GradientAnisotropicDiffusionImageFilterOutput
  MathematicalMorphologyBinaryErosionOutput
  MathematicalMorphologyBinaryDilationOutput
  MathematicalMorphologyGrayscaleErosionOutput
  MathematicalMorphologyGrayscaleDilationOutput
  MinMaxCurvatureFlowImageFilterOutput
  MeanImageFilterOutput
  MedianImageFilterOutput
  ResampleImageFilterOutput1
  ResampleImageFilterOutput2
  ResampleImageFilterOutput3
  ResampleImageFilterOutput7
  ResampleImageFilterOutput7b
  RGBCurvatureAnisotropicDiffusionImageFilterOutput
  RGBCurvatureAnisotropicDiffusionImageFilterOutput2
  RGBGradientAnisotropicDiffusionImageFilterOutput
  RGBGradientAnisotropicDiffusionImageFilterOutput2
  ThresholdImageFilterOutputAbove
  ThresholdImageFilterOutputBelow
  ThresholdImageFilterOutputOutside
  VectorGradientAnisotropicDiffusionImageFilterInput
  VectorGradientAnisotropicDiffusionImageFilterOutput
  VectorCurvatureAnisotropicDiffusionImageFilterInput
  VectorCurvatureAnisotropicDiffusionImageFilterOutput
  VisibleWomanHeadSlice
  VisibleWomanEyeSlice
)

FOREACH(image ${JPEG_IMAGES})
ADD_CUSTOM_COMMAND( 
  SOURCE    ${SoftwareGuide_SOURCE_DIR}/Art/${image}.jpg
  COMMAND   ${IMAGEMAGICK_CONVERT_EXECUTABLE}
  ARGS      ${SoftwareGuide_SOURCE_DIR}/Art/${image}.jpg
            ${image}.eps
  TARGET    SoftwareGuideArt
  OUTPUTS   ${SoftwareGuide_BINARY_DIR}/Art/${image}.eps
)
SET(DEPS ${DEPS} ${SoftwareGuide_BINARY_DIR}/Art/${image}.eps)
ENDFOREACH(image)

ADD_CUSTOM_COMMAND(
  SOURCE SoftwareGuideArt
  COMMAND echo
  TARGET SoftwareGuideArt
  DEPENDS ${DEPS}
)



