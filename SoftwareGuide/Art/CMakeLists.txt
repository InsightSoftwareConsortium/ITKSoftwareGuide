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


#
#
#  Error checking for the components we need
#
#
IF(NOT IMAGEMAGICK_CONVERT_EXECUTABLE)
  MESSAGE("ImageMagick convert utility was not found. Please pass to advanced mode and provide its full path")
ENDIF(NOT IMAGEMAGICK_CONVERT_EXECUTABLE)




ADD_CUSTOM_TARGET(SoftwareGuideArt  ALL echo)

SET(XFIG_FIGURES
  BayesianPluginClassifier
  BinaryThresholdTransferFunction
  CannySegmentationLevelSetImageFilterCollaborationDiagram1
  DiscreteGaussian
  DeformableModelCollaborationDiagram
  DudaClassifier
  GeometricalObjects
  GeodesicActiveContoursCollaborationDiagram1
  GeodesicActiveContourShapePriorCollaborationDiagram
  FastMarchingCollaborationDiagram1
  FuzzyConnectednessClassDiagram1
  FuzzyConnectednessCollaborationDiagram1
  FuzzyVoronoiCollaborationDiagram1
  FuzzyVoronoiDeformableCollaborationDiagram1
  Histogram
  HybridSegmentationEngine1
  HybridSegmentationFCVDDM
  ImageAdaptorConcept
  ImageIOCollaborationDiagram
  ImageIOFactoriesClassDiagram
  ImageIOFactoriesUseCases
  ImageOriginAndSpacing
  IteratorFigure1
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
  ImageRegistration8TraceMetric
  ImageRegistration8TraceAngle
  ImageRegistration8TraceTranslations
  ImageRegistration9TraceMetric
  ImageRegistration9TraceAngle
  ImageRegistration9TraceTranslations
  LaplacianSegmentationLevelSetImageFilterCollaborationDiagram1
  LevelSetZeroSet
  LevelSetSegmentationFigure1
  MinMaxCurvatureFlowFunctionDiagram
  ModelToImageRegistrationConcept
  ModelToImageRegistrationTraceAngle
  ModelToImageRegistrationTraceTranslations
  MultiResImageRegistration1TraceMetric
  MultiResImageRegistration1TraceTranslations
  MultiResImageRegistration2TraceMetric
  MultiResImageRegistration2TraceTranslations
  MultiResRegistrationComponents
  MultiResRegistrationConcept
  ModelToImageRegistrationComponentsDiagram
  NeighborhoodIteratorFig1
  NeighborhoodIteratorFig2
  OptimizersHierarchy
  ParzenWindowing1
  ParzenWindowing2
  ParzenWindowing3
  ParzenWindowing13
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
  SampleInheritanceTree
  SigmoidBase
  SigmoidParameterAlpha
  SigmoidParameterBeta
  ShapeDetectionCollaborationDiagram1
  SpatialObjectTransforms
  StatisticalClassificationFramework
  ThresholdSegmentationLevelSetImageFilterFigure1
  ThresholdSegmentationLevelSetImageFilterCollaborationDiagram1
  ThresholdTransferFunctionAbove
  ThresholdTransferFunctionBelow
  ThresholdTransferFunctionOutside
  TranslationAndRotationCenter
  VoronoiSegmentationClassDiagram1
  VoronoiSegmentationCollaborationDiagram1
  VoronoiSegmentationCollaborationDiagram2
  WatershedCatchmentBasins
  WatershedsHierarchy
  WatershedImageFilter
)


SET(JPEG_IMAGES
  itkLogo
  BilateralImageFilterOutput
  BinaryImage
  BinaryThresholdImageFilterOutput
  BinaryMinMaxCurvatureFlowImageFilterOutput
  BinomialBlurImageFilterOutput
  BrainMidSagittalSlice
  BrainProtonDensitySlice
  BrainProtonDensitySlice2x3
  BrainProtonDensitySlice2x3b
  BrainProtonDensitySliceBorder20
  BrainProtonDensitySliceShifted13x17y
  BrainProtonDensitySliceRotated10
  BrainProtonDensitySliceR10X13Y17
  BrainProtonDensitySliceR10X13Y17S12
  BrainT1Slice
  BrainT1SliceBorder20
  ccmakeScreenShot
  CannySegmentationLevelSetImageFilterVentricle1
  CannySegmentationLevelSetImageFilterVentricle2
  CMakeSetupScreenShot
  ConfidenceConnectedOutput1
  ConfidenceConnectedOutput2
  ConfidenceConnectedOutput3
  ConnectedThresholdOutput1
  ConnectedThresholdOutput2
  ConnectedThresholdOutput3
  CorpusCallosumMeanShape
  CorpusCallosumModeMinus0
  CorpusCallosumModeMinus1
  CorpusCallosumModeMinus2
  CorpusCallosumModePlus0
  CorpusCallosumModePlus1
  CorpusCallosumModePlus2
  CurvatureFlowImageFilterOutput
  CurvatureAnisotropicDiffusionImageFilterOutput
  DanielssonDistanceMapImageFilterOutput1
  DanielssonDistanceMapImageFilterOutput2
  Dashboard
  DeformableRegistration1Output
  DeformableRegistration1CheckerboardBefore
  DeformableRegistration1CheckerboardAfter
  DeformableRegistration2Output
  DeformableRegistration2CheckerboardBefore
  DeformableRegistration2CheckerboardAfter
  DerivativeImageFilterOutput
  DiscreteGaussianImageFilterOutput
  FivePoints
  FastMarchingImageFilterOutput1
  FastMarchingImageFilterOutput2
  FastMarchingImageFilterOutput3
  FastMarchingImageFilterOutput5
  FastMarchingImageFilterOutput6
  FastMarchingImageFilterOutput7
  FastMarchingImageFilterOutput8
  FatMRISlice
  GeodesicActiveContourImageFilterOutput1
  GeodesicActiveContourImageFilterOutput2
  GeodesicActiveContourImageFilterOutput3
  GeodesicActiveContourImageFilterOutput4
  GeodesicActiveContourImageFilterOutput5
  GeodesicActiveContourImageFilterOutput6
  GeodesicActiveContourImageFilterOutput7
  GeodesicActiveContourImageFilterOutput8
  GeodesicActiveContourShapePriorImageFilterOutput1
  GeodesicActiveContourShapePriorImageFilterOutput2
  GeodesicActiveContourShapePriorImageFilterOutput5
  GeodesicActiveContourShapePriorImageFilterOutput6
  GradientMagnitudeImageFilterOutput
  GradientMagnitudeRecursiveGaussianImageFilterOutput3
  GradientMagnitudeRecursiveGaussianImageFilterOutput5
  GradientAnisotropicDiffusionImageFilterOutput
  HybridSegmentationFuzzyVoronoiOutput
  HybridSegmentationFuzzyVoronoiOutput2
  ImageAdaptorToVectorImageComponentX
  ImageAdaptorToVectorImageComponentY
  ImageAdaptorThresholdingA
  ImageAdaptorThresholdingB
  ImageRegionIteratorOutput
  ImageRegionIteratorWithIndexOutput
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
  ImageRegistration8Output
  ImageRegistration8DifferenceBefore
  ImageRegistration8DifferenceAfter
  ImageRegistration9Output
  ImageRegistration9DifferenceBefore
  ImageRegistration9DifferenceAfter
  ImageSliceIteratorWithIndexOutput
  IsolatedConnectedImageFilterOutput0
  IsolatedConnectedImageFilterOutput1
  Kitware-logo-medium-res
  LaplacianSegmentationLevelSetImageFilterVentricle
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
  NeighborhoodConnectedImageFilterOutput1
  NeighborhoodConnectedImageFilterOutput2
  NeighborhoodConnectedImageFilterOutput3
  NeighborhoodIterators1a
  NeighborhoodIterators1b
  NeighborhoodIterators4a
  NeighborhoodIterators4b
  NeighborhoodIterators4c
  NeighborhoodIterators4d
  NeighborhoodIterators6a
  NeighborhoodIterators6b
  NeighborhoodIterators6c
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
  ShapeDetectionLevelSetFilterOutput1
  ShapeDetectionLevelSetFilterOutput2
  ShapeDetectionLevelSetFilterOutput3
  ShapeDetectionLevelSetFilterOutput5
  ShapeDetectionLevelSetFilterOutput6
  ShapeDetectionLevelSetFilterOutput7
  ShapeDetectionLevelSetFilterOutput8
  ShapedNeighborhoodIterators1a
  ShapedNeighborhoodIterators1b
  ShapedNeighborhoodIterators1c
  ShapedNeighborhoodIterators1d
  SmoothingRecursiveGaussianImageFilterOutput3
  SmoothingRecursiveGaussianImageFilterOutput5
  SigmoidImageFilterOutput
  ThresholdImageFilterOutputAbove
  ThresholdImageFilterOutputBelow
  ThresholdImageFilterOutputOutside
  ThresholdSegmentationLevelSetImageFilterWhiteMatter
  ThresholdSegmentationLevelSetImageFilterGrayMatter
  ThresholdSegmentationLevelSetImageFilterVentricle
  TwoNormalDensityFunctionPlot
  VectorGradientAnisotropicDiffusionImageFilterInput
  VectorGradientAnisotropicDiffusionImageFilterOutput
  VectorCurvatureAnisotropicDiffusionImageFilterInput
  VectorCurvatureAnisotropicDiffusionImageFilterOutput
  VectorConfidenceConnectedOutput1
  VectorConfidenceConnectedOutput2
  VectorConfidenceConnectedOutput3
  VisibleWomanHeadSlice
  VisibleWomanEyeSlice
  VisibleWomanEyeSliceRedComponent
  VisibleWomanEyeSliceGreenComponent
  VisibleWomanEyeSliceBlueComponent
  WatershedAbdomenSegmentation
  WatershedRendering
  WatershedSegmentation1Output1
  WatershedSegmentation1Output2
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
  COMMAND   ${FIG2DEV_EXECUTABLE}
  ARGS      -L eps ${SoftwareGuide_SOURCE_DIR}/Art/${figure}.fig ${SoftwareGuide_BINARY_DIR}/Art/${figure}.eps
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



