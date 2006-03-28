
# 
# Find LaTeX
#
INCLUDE (${CMAKE_ROOT}/Modules/FindLATEX.cmake)


#
# Verify that we found all the components we need
#
IF(NOT LATEX_COMPILER)
  MESSAGE("Latex compiler was not found. Please pass to advanced mode and provide its full path")
ENDIF(NOT LATEX_COMPILER)

IF(NOT BIBTEX_COMPILER)
  MESSAGE("BibTeX executable was not found. Please pass to advanced mode and provide its full path")
ENDIF(NOT BIBTEX_COMPILER)

IF(NOT DVIPS_CONVERTER)
  MESSAGE("dvips executable was not found. Please pass to advanced mode and provide its full path")
ENDIF(NOT DVIPS_CONVERTER)

IF(NOT PS2PDF_CONVERTER)
  MESSAGE("ps2pdf executable was not found. Please pass to advanced mode and provide its full path")
ENDIF(NOT PS2PDF_CONVERTER)

IF(NOT MAKEINDEX_COMPILER)
  MESSAGE("makeindex executable was not found. Please pass to advanced mode and provide its full path")
ENDIF(NOT MAKEINDEX_COMPILER)




SET (PDF_QUALITY_LEVEL "Screen" CACHE STRING "PDF Quality. Options are: Screen, Printer, PrePress")
#
# Options for PDF generation. 
# resolution in dpi.  
#
#  /screen   = low    resolution = Distiller "Screen" optimized
#  /ebook    = medium resolution = Distiller "eBook"  
#  /printer  = high   resolution = Distiller "Print" optimized  
#  /prepress = high   resolution = Distiller like "Print" with some error checking differences
#
IF( PDF_QUALITY_LEVEL STREQUAL "Screen" )
  SET(PS2PDF_CONVERTER_OPTIONS "-dPDFSETTINGS=/screen" -r600)
  SET(SoftwareGuide_PRINTED_VERSION_LATEX_BOOLEAN "\\itkPrintedVersionfalse")
ENDIF( PDF_QUALITY_LEVEL STREQUAL "Screen" )

IF( PDF_QUALITY_LEVEL STREQUAL "Printer" )
  SET(PS2PDF_CONVERTER_OPTIONS "-dPDFSETTINGS=/printer" -r600)
  SET(SoftwareGuide_PRINTED_VERSION_LATEX_BOOLEAN "\\itkPrintedVersiontrue")
ENDIF( PDF_QUALITY_LEVEL STREQUAL "Printer" )

IF( PDF_QUALITY_LEVEL STREQUAL "PrePress" )
  SET(PS2PDF_CONVERTER_OPTIONS "-dPDFSETTINGS=/prepress" "-dColorImageResolution=600" "-dGrayImageResolution=600" -r600)
  SET(SoftwareGuide_PRINTED_VERSION_LATEX_BOOLEAN "\\itkPrintedVersiontrue")
ENDIF( PDF_QUALITY_LEVEL STREQUAL "PrePress" )

SET(DVIPS_CONVERTER_OPTIONS  -D600)



#
# File that defines the path to .cxx examples in ITK sources
#
CONFIGURE_FILE(
${SoftwareGuide_SOURCE_DIR}/SoftwareGuideConfiguration.tex.in 
${SoftwareGuide_BINARY_DIR}/SoftwareGuideConfiguration.tex
)

ADD_CUSTOM_TARGET(SoftwareGuideLatex  ALL echo)

SET( Tex_SRCS 
  Abstract.tex
  Applications.tex
  AnisotropicDiffusionFiltering.tex
  Contributors.tex
  DataRepresentation.tex
  Filtering.tex
  GUI.tex
  ImageMetrics.tex
  ImageInterpolators.tex
  ImageAdaptors.tex
  Infrastructure.tex
  Installation.tex
  Introduction.tex
  IO.tex
  Iterators.tex
  Numerics.tex
  Registration.tex
  Segmentation.tex
  SoftwareGuide.tex
  SoftwareProcess.tex
  SpatialObjects.tex
  Statistics.tex
  SystemOverview.tex
  Transforms.tex
  Visualization.tex
  Wrapping.tex
  WatershedSegmentation.tex
)

FOREACH( file ${Tex_SRCS})
SET( SoftwareGuide_Tex_SRCS  
   ${SoftwareGuide_Tex_SRCS} ${SoftwareGuide_SOURCE_DIR}/Latex/${file}
 )
ENDFOREACH( file )



SET( ITK_EXAMPLES_TEX_SRCS_NAMES 
  BayesianPluginClassifier.tex
  BilateralImageFilter.tex
  BinaryMinMaxCurvatureFlowImageFilter.tex
  BinaryThresholdImageFilter.tex
  BinomialBlurImageFilter.tex
  CastingImageFilters.tex
  ConfidenceConnected.tex
  ConnectedThresholdImageFilter.tex
  CovariantVectorImageRead.tex
  CovariantVectorImageWrite.tex
  CovariantVectorImageExtractComponent.tex
  NeighborhoodConnectedImageFilter.tex
  CurvatureAnisotropicDiffusionImageFilter.tex
  CurvatureFlowImageFilter.tex
  DanielssonDistanceMapImageFilter.tex
  DeformableModel1.tex
  DiscreteGaussianImageFilter.tex
  EuclideanDistance.tex
  ExpectationMaximizationMixtureModelEstimator.tex
  FastMarchingImageFilter.tex
  GaussianDensityFunction.tex
  GeodesicActiveContourImageFilter.tex
  GibbsPriorImageFilter1.tex
  GradientAnisotropicDiffusionImageFilter.tex
  GradientMagnitudeImageFilter.tex
  GradientMagnitudeRecursiveGaussianImageFilter.tex
  HelloWorld.tex
  Histogram.tex
  HybridSegmentationFuzzyVoronoi.tex
  HoughTransform2DLinesImageFilter.tex
  Image1.tex
  Image2.tex
  Image3.tex
  Image4.tex
  Image5.tex
  ImageRandomConstIteratorWithIndex.tex
  ImageLinearIteratorWithIndex.tex
  ImageReadWrite.tex
  ImageReadCastWrite.tex
  ImageReadExtractWrite.tex
  ImageRegionIterator.tex
  ImageRegionIteratorWithIndex.tex
  ImageRegistration1.tex
  ImageRegistration2.tex
  ImageRegistration3.tex
  ImageRegistration4.tex
  ImageRegistration5.tex
  ImageRegistration6.tex
  ImageRegistration7.tex
  ImageRegistration8.tex
  ImageRegistration9.tex
  ImageRegistrationHistogramPlotter.tex
  ImageSliceIteratorWithIndex.tex
  ImageToListAdaptor.tex
  IsolatedConnectedImageFilter.tex
  IterativeClosestPoint1.tex
  IterativeClosestPoint2.tex
  IterativeClosestPoint3.tex
  KdTree.tex
  KdTreeBasedKMeansClustering.tex
  ListSample.tex
  ListSampleToHistogramFilter.tex
  ListSampleToHistogramGenerator.tex
  LandmarkWarping2.tex
  BSplineWarping1.tex
  DeformableRegistration1.tex
  DeformableRegistration2.tex
  DeformableRegistration3.tex
  DeformableRegistration4.tex
  MultiResImageRegistration1.tex
  MultiResImageRegistration2.tex
  MathematicalMorphologyBinaryFilters.tex
  MathematicalMorphologyGrayscaleFilters.tex
  MaximumDecisionRule.tex
  MaximumRatioDecisionRule.tex
  MeanImageFilter.tex
  MedianImageFilter.tex
  MembershipSample.tex
  Mesh1.tex
  Mesh2.tex
  Mesh3.tex
  MeshCellsIteration.tex
  MeshCellVisitor2.tex
  MeshCellVisitor.tex
  MeshKComplex.tex
  MeshTraits.tex
  ModelToImageRegistration1.tex
  MinimumDecisionRule.tex
  MinMaxCurvatureFlowImageFilter.tex
  NeighborhoodSampler.tex
  NormalVariateGenerator.tex
  PointSet1.tex
  PointSet2.tex
  PointSet3.tex
  PointSetToListAdaptor.tex
  PointSetWithCovariantVectors.tex
  PointSetWithVectors.tex
  ResampleImageFilter2.tex
  ResampleImageFilter3.tex
  ResampleImageFilter4.tex
  ResampleImageFilter5.tex
  ResampleImageFilter.tex
  RGBCurvatureAnisotropicDiffusionImageFilter.tex
  RGBGradientAnisotropicDiffusionImageFilter.tex
  RGBImageReadWrite.tex
  RGBImage.tex
  RGBPointSet.tex
  SampleSorting.tex
  SampleStatistics.tex
  SampleToHistogramProjectionFilter.tex
  ShapeDetectionLevelSetFilter.tex
  SmoothingRecursiveGaussianImageFilter.tex
  SmoothingRecursiveGaussianImageFilter2.tex
  SigmoidImageFilter.tex
  SampleSorting.tex
  Subsample.tex
  SurfaceExtraction.tex
  ThresholdImageFilter.tex
  VectorCurvatureAnisotropicDiffusionImageFilter.tex
  VectorGradientAnisotropicDiffusionImageFilter.tex
  VectorImage.tex
  WarpImageFilter1.tex
  WatershedSegmentation1.tex
  WeightedSampleStatistics.tex
  )

FOREACH( exampletexname ${ITK_EXAMPLES_TEX_SRCS_NAMES})
  SET( ITK_EXAMPLES_TEX_SRCS ${ITK_EXAMPLES_TEX_SRCS} ${SoftwareGuide_BINARY_DIR}/Examples/${exampletexname} )
ENDFOREACH( exampletexname )




IF(LATEX_COMPILER)

  IF (NOT UNIX)
    SET(ITK_TEXINPUTS ${SoftwareGuide_SOURCE_DIR}/../Latex;${SoftwareGuide_SOURCE_DIR};${SoftwareGuide_SOURCE_DIR}/Latex;${SoftwareGuide_SOURCE_DIR}/Art;${SoftwareGuide_BINARY_DIR};${SoftwareGuide_BINARY_DIR}/Examples;${SoftwareGuide_BINARY_DIR}/Art;${SoftwareGuide_BINARY_DIR}/Latex)

    CONFIGURE_FILE(${SoftwareGuide_SOURCE_DIR}/LaTeXWrapper.bat.in
                   ${SoftwareGuide_BINARY_DIR}/LaTeXWrapper.bat)
    SET (LATEX_WRAPPER1 ${SoftwareGuide_BINARY_DIR}/LaTeXWrapper.bat)
    SET (LATEX_WRAPPER2 "")

    CONFIGURE_FILE(${SoftwareGuide_SOURCE_DIR}/DvipsWrapper.bat.in
                   ${SoftwareGuide_BINARY_DIR}/DvipsWrapper.bat)
    SET (DVIPS_WRAPPER1 ${SoftwareGuide_BINARY_DIR}/DvipsWrapper.bat)
    SET (DVIPS_WRAPPER2 "")
  ELSE (NOT UNIX)
    SET(ITK_TEXINPUTS ${SoftwareGuide_SOURCE_DIR}/../Latex:${SoftwareGuide_SOURCE_DIR}:${SoftwareGuide_SOURCE_DIR}/Latex:${SoftwareGuide_SOURCE_DIR}/Art:${SoftwareGuide_BINARY_DIR}:${SoftwareGuide_BINARY_DIR}/Examples:${SoftwareGuide_BINARY_DIR}/Art:${SoftwareGuide_BINARY_DIR}/Latex)

    CONFIGURE_FILE(${SoftwareGuide_SOURCE_DIR}/LaTeXWrapper.sh.in
                   ${SoftwareGuide_BINARY_DIR}/LaTeXWrapper.sh)
    SET (LATEX_WRAPPER1 /bin/sh)
    SET (LATEX_WRAPPER2 ${SoftwareGuide_BINARY_DIR}/LaTeXWrapper.sh)

    CONFIGURE_FILE(${SoftwareGuide_SOURCE_DIR}/DvipsWrapper.sh.in
                   ${SoftwareGuide_BINARY_DIR}/DvipsWrapper.sh)
    SET (DVIPS_WRAPPER1 /bin/sh)
    SET (DVIPS_WRAPPER2 ${SoftwareGuide_BINARY_DIR}/DvipsWrapper.sh)
  ENDIF (NOT UNIX)

  ADD_CUSTOM_COMMAND( 
    SOURCE    ${SoftwareGuide_Tex_SRCS}  ${ITK_EXAMPLES_TEX_SRCS} ${ITK_EXAMPLES_TEX_SRCS}
    COMMAND   ${LATEX_WRAPPER1}
    ARGS      ${LATEX_WRAPPER2} 
              ${SoftwareGuide_SOURCE_DIR}/Latex/SoftwareGuide.tex
    TARGET    SoftwareGuideLatex
    DEPENDS   ${SoftwareGuide_Tex_SRCS} ${ITK_EXAMPLES_TEX_SRCS}
    OUTPUTS   SoftwareGuide.dvi
  )

  IF(DVIPS_CONVERTER)
    ADD_CUSTOM_COMMAND( 
      SOURCE    SoftwareGuide.dvi
      COMMAND   ${DVIPS_WRAPPER1}
      ARGS      ${DVIPS_WRAPPER2}
                SoftwareGuide.dvi ${DVIPS_CONVERTER_OPTIONS} -o  SoftwareGuide.ps
      TARGET    SoftwareGuideLatex
      DEPENDS   SoftwareGuide.ind SoftwareGuide.bbl
      OUTPUTS   SoftwareGuide.ps
    )
  ENDIF(DVIPS_CONVERTER)
  
  IF(PS2PDF_CONVERTER)
    ADD_CUSTOM_COMMAND( 
      SOURCE    SoftwareGuide.ps
      COMMAND   ${PS2PDF_CONVERTER}
      ARGS      ${PS2PDF_CONVERTER_OPTIONS} SoftwareGuide.ps
      TARGET    SoftwareGuideLatex
      OUTPUTS   SoftwareGuide.pdf
    )
    ADD_CUSTOM_COMMAND( 
      SOURCE    SoftwareGuideLatex
      COMMAND   echo
      TARGET    SoftwareGuideLatex
      DEPENDS   SoftwareGuide.pdf
    )
  ENDIF(PS2PDF_CONVERTER)

  IF(MAKEINDEX_COMPILER)
    ADD_CUSTOM_COMMAND( 
      SOURCE    ${SoftwareGuide_Tex_SRCS}  ${ITK_EXAMPLES_TEX_SRCS} 
      COMMAND   ${LATEX_WRAPPER1}
      ARGS      ${LATEX_WRAPPER2} 
                ${SoftwareGuide_SOURCE_DIR}/Latex/SoftwareGuide.tex
      TARGET    SoftwareGuideLatex
      DEPENDS   SoftwareGuide.ind SoftwareGuide.bbl
      OUTPUTS   SoftwareGuide.idx
    )
    ADD_CUSTOM_COMMAND( 
      SOURCE    SoftwareGuide.idx
      COMMAND   ${MAKEINDEX_COMPILER}
      ARGS      SoftwareGuide
      TARGET    SoftwareGuideLatex
      OUTPUTS   SoftwareGuide.ind
    )

  ENDIF(MAKEINDEX_COMPILER)

  IF(BIBTEX_COMPILER)
    ADD_CUSTOM_COMMAND( 
      SOURCE    ${SoftwareGuide_SOURCE_DIR}/Latex/SoftwareGuide.tex
      COMMAND   ${BIBTEX_COMPILER}
      ARGS      SoftwareGuide
      TARGET    SoftwareGuideLatex
      DEPENDS   ${SoftwareGuide_SOURCE_DIR}/Latex/SoftwareGuide.tex ${SoftwareGuide_SOURCE_DIR}/../Latex/Insight.bib
      OUTPUTS   SoftwareGuide.bbl
    )
  ENDIF(BIBTEX_COMPILER)


ENDIF(LATEX_COMPILER)



