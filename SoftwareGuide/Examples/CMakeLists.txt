
#
#  This empty files makes the Examples directory 
#  to be created in the binary tree
#

# 
# Find ITK Sources
#
FIND_PATH(ITK_SOURCE_DIR UseITK.cmake.in)



#
# Find Perl executable
#
INCLUDE (${CMAKE_ROOT}/Modules/FindPerl.cmake)



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
  ${ITK_SOURCE_DIR}/Examples/Filtering/BilateralImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/BinaryThresholdImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/BinaryMinMaxCurvatureFlowImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/BinomialBlurImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/ThresholdImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/CastingImageFilters.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/CurvatureFlowImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/CurvatureAnisotropicDiffusionImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/DanielssonDistanceMapImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/DiscreteGaussianImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/GradientMagnitudeImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/GradientMagnitudeRecursiveGaussianImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/GradientAnisotropicDiffusionImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/MathematicalMorphologyBinaryFilters.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/MathematicalMorphologyGrayscaleFilters.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/MedianImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/MeanImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/MinMaxCurvatureFlowImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/ResampleImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/ResampleImageFilter2.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/ResampleImageFilter3.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/RGBCurvatureAnisotropicDiffusionImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/RGBGradientAnisotropicDiffusionImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/VectorCurvatureAnisotropicDiffusionImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/VectorGradientAnisotropicDiffusionImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/IO/RGBImageReadWrite.cxx
  ${ITK_SOURCE_DIR}/Examples/Installation/HelloWorld.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/ImageRegistration1.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/ImageRegistration2.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/ImageRegistration3.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/ImageRegistration4.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/DeformableRegistration1.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/MultiResImageRegistration1.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/MultiResImageRegistration2.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/ConfidenceConnected.cxx
)



IF( NOT PERL_FOUND )
  MESSAGE("Perl executable was not found")
ENDIF( NOT PERL_FOUND )
  


IF( PERL_FOUND AND PERLCXXPARSER )
  FOREACH(example ${ITK_EXAMPLES_SRCS})
  GET_FILENAME_COMPONENT(TEX_FILE ${example} NAME_WE)
  SET(TEX_FILE ${SoftwareGuide_BINARY_DIR}/Examples/${TEX_FILE}.tex)
  ADD_CUSTOM_COMMAND(
    SOURCE    ${example}
    COMMAND   ${PERL_EXECUTABLE} ${PERLCXXPARSER}
    ARGS      ${example} ${TEX_FILE}
    TARGET    SoftwareGuideExamples
    DEPENDS   ${PERLCXXPARSER} ${example}
    OUTPUTS   ${TEX_FILE}
  )
  SET(TEX_DEPENDENCIES ${TEX_DEPENDENCIES} ${TEX_FILE})
  ENDFOREACH(example)

ENDIF( PERL_FOUND AND PERLCXXPARSER )


ADD_CUSTOM_COMMAND( 
  SOURCE    SoftwareGuideExamples
  COMMAND   echo
  TARGET    SoftwareGuideExamples
  DEPENDS   ${TEX_DEPENDENCIES}
)


