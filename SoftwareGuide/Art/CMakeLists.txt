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
  GeometricalObjects
  HybridSegmentationDiagram1
  ImageIOCollaborationDiagram
  ImageIOFactoriesClassDiagram
  ImageIOFactoriesUseCases
  ImageOriginAndSpacing
  ImageOverlapedRegions
  ImageOverlap
  ImageOverlapInterpolator
  ImageOverlapIterator
  ImageRegistrationConcept
  ImageRegistration1Pipeline
  ImageRegistration1TraceMetric
  ImageRegistration1TraceTranslations
  ImageRegistration2TraceTranslations
  ImageRegistration2TraceTranslations2
  ImageRegistration2TraceMetric
  ImageRegistration2TraceMetric2
  ImageRegistration3Observer
  ImageRegistration4TraceMetric
  ImageRegistration4TraceTranslations
  ImageRegistration5TraceMetric
  ImageRegistration5TraceAngle
  ImageRegistration5TraceTranslations
  ImageRegistration5TraceMetric2
  ImageRegistration5TraceAngle2
  ImageRegistration5TraceTranslations2
  ImageRegistration6TraceMetric
  ImageRegistration6TraceAngle
  ImageRegistration6TraceTranslations
  MultiResImageRegistration1TraceMetric
  MultiResImageRegistration1TraceTranslations
  MultiResImageRegistration2TraceMetric
  MultiResImageRegistration2TraceTranslations
  MultiResRegistrationComponents
  MultiResRegistrationConcept
  OptimizersHierarchy
  ParzenWindowing1
  ParzenWindowing2
  ParzenWindowing3
  PointSetWithVectors
  RegistrationComponentsDiagram
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
  TranslationAndRotationCenter
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
  BrainProtonDensitySliceBorder20
  BrainProtonDensitySliceShifted13x17y
  BrainProtonDensitySliceRotated10
  BrainProtonDensitySliceR10X13Y17
  BrainT1Slice
  BrainT1SliceBorder20
  ccmakeScreenShot
  CMakeSetupScreenShot
  ConfidenceConnectedOutput1
  ConfidenceConnectedOutput2
  ConfidenceConnectedOutput3
  CurvatureFlowImageFilterOutput
  CurvatureAnisotropicDiffusionImageFilterOutput
  DanielssonDistanceMapImageFilterOutput1
  DanielssonDistanceMapImageFilterOutput2
  Dashboard
  DeformableRegistration1Output
  DeformableRegistration1CheckerboardBefore
  DeformableRegistration1CheckerboardAfter
  DiscreteGaussianImageFilterOutput
  FivePoints
  GradientMagnitudeImageFilterOutput
  GradientMagnitudeRecursiveGaussianImageFilterOutput3
  GradientMagnitudeRecursiveGaussianImageFilterOutput5
  GradientAnisotropicDiffusionImageFilterOutput
  HybridSegmentationFuzzyVoronoiOutput
  HybridSegmentationOutput1
  ImageRegistration1Output
  ImageRegistration2Output
  ImageRegistration4Output
  ImageRegistration1DifferenceBefore
  ImageRegistration1DifferenceAfter
  ImageRegistration2CheckerboardBefore
  ImageRegistration2CheckerboardAfter
  ImageRegistration4CheckerboardBefore
  ImageRegistration4CheckerboardAfter
  ImageRegistration5Output
  ImageRegistration5DifferenceBefore
  ImageRegistration5DifferenceAfter
  ImageRegistration5Output2
  ImageRegistration5DifferenceBefore2
  ImageRegistration5DifferenceAfter2
  ImageRegistration6Output
  ImageRegistration6DifferenceBefore
  ImageRegistration6DifferenceAfter
  MultiResImageRegistration1CheckerboardBefore
  MultiResImageRegistration1CheckerboardAfter
  MultiResImageRegistration1Output
  MultiResImageRegistration2CheckerboardBefore
  MultiResImageRegistration2CheckerboardAfter
  MultiResImageRegistration2Output
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
  ResampleImageFilterOutput10
  ResampleImageFilterOutput11
  RGBCurvatureAnisotropicDiffusionImageFilterOutput
  RGBCurvatureAnisotropicDiffusionImageFilterOutput2
  RGBGradientAnisotropicDiffusionImageFilterOutput
  RGBGradientAnisotropicDiffusionImageFilterOutput2
  SmoothingRecursiveGaussianImageFilterOutput3
  SmoothingRecursiveGaussianImageFilterOutput5
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



