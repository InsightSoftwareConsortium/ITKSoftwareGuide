#
#  Convert images from different formats
#  into Encapsulated Postscript to be 
#  included in LaTeX files.
#


#
#  Find fig2dev : this program convert Xfig figures 
#  to Encapsulated Postscript on the command line.
#
FIND_PROGRAM(FIG2DEV_EXECUTABLE
  NAMES fig2dev
)



# 
# Find ImageMagick tools
# This is used to convert image formats
#
INCLUDE (${CMAKE_ROOT}/Modules/FindImageMagick.cmake)


ADD_CUSTOM_TARGET(SoftwareGuideArt  ALL echo)

SET(XFIG_FIGURES
  BinaryThresholdTransferFunction
  DiscreteGaussian
  ImageIOCollaborationDiagram
  ImageIOFactoriesClassDiagram
  ImageIOFactoriesUseCases
  ImageOverlapedRegions
  ImageOverlap
  ImageOverlapInterpolator
  ImageOverlapIterator
  ImageRegistrationConcept
  ParzenWindowing1
  ParzenWindowing2
  ParzenWindowing3
  PointSetWithVectors
  ResampleImageFilterOutput1Analysis
  ResampleImageFilterOutput2Analysis
  ResampleImageFilterOutput3Analysis
  ResampleImageFilterTransformComposition1
  ResampleImageFilterTransformComposition2
  ResampleImageFilterTransformComposition3
  ResampleImageFilterTransformComposition4
  ResampleImageFilterTransformComposition5
  ResampleImageFilterTransformComposition6
  ThresholdTransferFunctionAbove
  ThresholdTransferFunctionBelow
  ThresholdTransferFunctionOutside
  WatershedCatchmentBasins
  WatershedsHierarchy
  WatershedImageFilter
  WatershedSegmentationEditorBuild
)


SET(JPEG_IMAGES
  BilateralImageFilterOutput
  BinaryThresholdImageFilterOutput
  BinaryMinMaxCurvatureFlowImageFilterOutput
  BinomialBlurImageFilterOutput
  BrainProtonDensitySlice
  BrainProtonDensitySlice2x3
  BrainProtonDensitySlice2x3b
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
  ResampleImageFilterInput2x3
  ResampleImageFilterOutput1
  ResampleImageFilterOutput2
  ResampleImageFilterOutput3
  ResampleImageFilterOutput7
  ResampleImageFilterOutput7b
  ResampleImageFilterOutput9
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
  WatershedColorEdges
  WatershedColorInput
  WatershedColorGradientMagnitude
  WatershedSpine1
  WatershedSpine2
  WatershedAbdomenSegmentation
  WatershedArm1
  WatershedArm2
  WatershedRendering
  WatershedsPreprocessing
  WatershedSegmentationApplicationGUI
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
SET(EPS_DEPS ${EPS_DEPS} ${SoftwareGuide_BINARY_DIR}/Art/${image}.eps)
ENDFOREACH(image)


FOREACH(figure ${XFIG_FIGURES})
ADD_CUSTOM_COMMAND( 
  SOURCE    ${SoftwareGuide_SOURCE_DIR}/Art/${figure}.fig
  COMMAND   ${CMAKE_COMMAND}
  ARGS     -E chdir ${SoftwareGuide_SOURCE_DIR}/Art ${FIG2DEV_EXECUTABLE} -L eps ${SoftwareGuide_SOURCE_DIR}/Art/${figure}.fig ${SoftwareGuide_BINARY_DIR}/Art/${figure}.eps
  TARGET    SoftwareGuideArt
  OUTPUTS   ${SoftwareGuide_BINARY_DIR}/Art/${figure}.eps
)
SET(EPS_DEPS ${EPS_DEPS} ${SoftwareGuide_BINARY_DIR}/Art/${figure}.eps)
ENDFOREACH(figure)


ADD_CUSTOM_COMMAND(
  SOURCE SoftwareGuideArt
  COMMAND echo
  TARGET SoftwareGuideArt
  DEPENDS ${EPS_DEPS}
)



