
#
#  This empty files makes the Examples directory 
#  to be created in the binary tree
#

# 
# Find ITK Sources
#
FIND_PATH(ITK_SOURCE_DIR UseITK.cmake.in)



#
# Find perl script for parsing cxx files and generate latex
#
FIND_PROGRAM(PERLCXXPARSER
  NAMES ${SoftwareGuide_SOURCE_DIR}/ParseCxxExamples.pl
)


ADD_CUSTOM_TARGET(SoftwareGuideExamples  ALL echo)


SET( ITK_EXAMPLES_SRCS
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Image/Image1.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Image/Image2.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Image/Image3.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Image/Image4.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Image/RGBImage.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Image/VectorImage.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Mesh/PointSet1.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Mesh/PointSet2.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Mesh/PointSet3.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Mesh/RGBPointSet.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Mesh/PointSetWithVectors.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Mesh/PointSetWithCovariantVectors.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Mesh/Mesh1.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Mesh/Mesh2.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Mesh/Mesh3.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Mesh/MeshTraits.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Mesh/MeshKComplex.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Mesh/MeshCellsIteration.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Mesh/MeshCellVisitor.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Mesh/MeshCellVisitor2.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/BinaryThresholdImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/BinaryMinMaxCurvatureFlowImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/ThresholdImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/CastingImageFilters.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/CurvatureFlowImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/DiscreteGaussianImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/GradientMagnitudeImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/GradientMagnitudeRecursiveGaussianImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/MathematicalMorphologyBinaryFilters.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/MathematicalMorphologyGrayscaleFilters.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/MedianImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/MinMaxCurvatureFlowImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/IO/RGBImageReadWrite.cxx
)



SET( ITK_EXAMPLES_TEX_SRCS
  Image1.tex
  Image2.tex
  Image3.tex
  Image4.tex
  RGBImage.tex
  VectorImage.tex
  PointSet1.tex
  PointSet2.tex
  PointSet3.tex
  RGBPointSet.tex
  PointSetWithVectors.tex
  PointSetWithCovariantVectors.tex
  Mesh1.tex
  Mesh2.tex
  Mesh3.tex
  MeshTraits.tex
  MeshKComplex.tex
  MeshCellsIteration.tex
  MeshCellVisitor.tex
  MeshCellVisitor2.tex
  MinMaxCurvatureFlowImageFilter.tex
  BinaryThresholdImageFilter.tex
  BinaryMinMaxCurvatureFlowImageFilter.tex
  ThresholdImageFilter.tex
  CastingImageFilters.tex
  CurvatureFlowImageFilter.tex
  DiscreteGaussianImageFilter.tex
  GradientMagnitudeImageFilter.tex
  GradientMagnitudeRecursiveGaussianImageFilter.tex
  MathematicalMorphologyBinaryFilters.tex
  MathematicalMorphologyGrayscaleFilters.tex
  MedianImageFilter.tex
  RGBImageReadWrite.tex
)



SET( CxxExamplesListFile
  ${SoftwareGuide_BINARY_DIR}/Examples/ExamplesList.txt
 )



IF( PERLCXXPARSER )

  ADD_CUSTOM_COMMAND(
    SOURCE    ${ITK_EXAMPLES_SRCS}
    COMMAND   find
    ARGS      ${ITK_SOURCE_DIR}/Examples   -name '*.cxx' -print > ${CxxExamplesListFile}
    TARGET    SoftwareGuideExamples
    DEPENDS   ${ITK_EXAMPLES_SRCS}
    OUTPUTS   ${CxxExamplesListFile}
  )
  ADD_CUSTOM_COMMAND( 
    SOURCE    SoftwareGuideExamples
    COMMAND   echo
    TARGET    SoftwareGuideExamples
    DEPENDS   ${ITK_EXAMPLES_TEX_SRCS}
  )

  ADD_CUSTOM_COMMAND(
    SOURCE    ${ITK_EXAMPLES_SRCS}
    COMMAND   ${PERLCXXPARSER}
    ARGS      ${CxxExamplesListFile}   ${SoftwareGuide_BINARY_DIR}/Examples
    TARGET    SoftwareGuideExamples
    DEPENDS   ${CxxExamplesListFile} ${PERLCXXPARSER}
    OUTPUTS   ${ITK_EXAMPLES_TEX_SRCS}
  )

ENDIF( PERLCXXPARSER )


