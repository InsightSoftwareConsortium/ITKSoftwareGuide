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
  BinaryThresholdImageFilterOutput
  BinaryMinMaxCurvatureFlowImageFilterOutput
  BinomialBlurImageFilterOutput
  BrainProtonDensitySlice
  CurvatureFlowImageFilterOutput
  CurvatureAnisotropicDiffusionImageFilterOutput
  DiscreteGaussianImageFilterOutput
  GradientMagnitudeImageFilterOutput
  GradientMagnitudeRecursiveGaussianImageFilterOutput3
  GradientMagnitudeRecursiveGaussianImageFilterOutput5
  GradientAnisotropicDiffusionImageFilterOutput
  MathematicalMorphologyBinaryErosionOutput
  MathematicalMorphologyBinaryDilationOutput
  MathematicalMorphologyGrayscaleErosionOutput
  MathematicalMorphologyGrayscaleDilationOutput
  MinMaxCurvatureFlowImageFilterOutput
  MedianImageFilterOutput
  RGBCurvatureAnisotropicDiffusionImageFilterOutput
  ThresholdImageFilterOutputAbove
  ThresholdImageFilterOutputBelow
  ThresholdImageFilterOutputOutside
  VectorGradientAnisotropicDiffusionImageFilterInput
  VectorGradientAnisotropicDiffusionImageFilterOutput
  VectorCurvatureAnisotropicDiffusionImageFilterInput
  VectorCurvatureAnisotropicDiffusionImageFilterOutput
  VisibleWomanHeadSlice
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
SET(DEPS ${DEPS} " " ${SoftwareGuide_BINARY_DIR}/Art/${image}.eps)
ENDFOREACH(image)

ADD_CUSTOM_COMMAND(
  SOURCE SoftwareGuideArt
  COMMAND echo
  TARGET SoftwareGuideArt
  DEPENDS ${DEPS}
)



