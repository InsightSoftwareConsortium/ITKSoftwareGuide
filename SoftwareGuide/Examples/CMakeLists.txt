
#
#  This empty files makes the Examples directory 
#  to be created in the binary tree
#

# 
# Find ITK Sources
#
FIND_PATH(ITK_SOURCE_DIR UseITK.cmake.in)

IF( NOT ITK_SOURCE_DIR )
  MESSAGE("The source directory for Insight has not been found, please provide this path")
ENDIF( NOT ITK_SOURCE_DIR )

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
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Image/Image5.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Image/RGBImage.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Image/VectorImage.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Image/ImageAdaptor1.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Image/ImageAdaptor2.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Image/ImageAdaptor3.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Image/ImageAdaptor4.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Mesh/AutomaticMesh.cxx
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
  ${ITK_SOURCE_DIR}/Examples/Filtering/CannyEdgeDetectionImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/DanielssonDistanceMapImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/DiscreteGaussianImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/DerivativeImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/FlipImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/GradientMagnitudeImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/GradientMagnitudeRecursiveGaussianImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/GradientRecursiveGaussianImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/GradientAnisotropicDiffusionImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/GaussianBlurImageFunction.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/MathematicalMorphologyBinaryFilters.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/MathematicalMorphologyGrayscaleFilters.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/MedianImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/MeanImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/MinMaxCurvatureFlowImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/ResampleImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/ResampleImageFilter2.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/ResampleImageFilter3.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/ResampleImageFilter4.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/ResampleImageFilter5.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/ResampleVolumesToBeIsotropic.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/RGBCurvatureAnisotropicDiffusionImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/RGBGradientAnisotropicDiffusionImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/SmoothingRecursiveGaussianImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/SmoothingRecursiveGaussianImageFilter2.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/SigmoidImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/VectorCurvatureAnisotropicDiffusionImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/VectorGradientAnisotropicDiffusionImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/IO/DicomSeriesReadImageWrite.cxx
  ${ITK_SOURCE_DIR}/Examples/IO/ImageReadWrite.cxx
  ${ITK_SOURCE_DIR}/Examples/IO/ImageReadCastWrite.cxx
  ${ITK_SOURCE_DIR}/Examples/IO/ImageReadExtractWrite.cxx
  ${ITK_SOURCE_DIR}/Examples/IO/ImageReadExportVTK.cxx
  ${ITK_SOURCE_DIR}/Examples/IO/ImageReadRegionOfInterestWrite.cxx
  ${ITK_SOURCE_DIR}/Examples/IO/ImageReadImageSeriesWrite.cxx
  ${ITK_SOURCE_DIR}/Examples/IO/ImageSeriesReadWrite.cxx
  ${ITK_SOURCE_DIR}/Examples/IO/RGBImageReadWrite.cxx
  ${ITK_SOURCE_DIR}/Examples/IO/RGBImageSeriesReadWrite.cxx
  ${ITK_SOURCE_DIR}/Examples/IO/CovariantVectorImageWrite.cxx
  ${ITK_SOURCE_DIR}/Examples/IO/CovariantVectorImageRead.cxx
  ${ITK_SOURCE_DIR}/Examples/IO/CovariantVectorImageExtractComponent.cxx
  ${ITK_SOURCE_DIR}/Examples/Installation/HelloWorld.cxx
  ${ITK_SOURCE_DIR}/Examples/Iterators/ImageLinearIteratorWithIndex.cxx
  ${ITK_SOURCE_DIR}/Examples/Iterators/ImageLinearIteratorWithIndex2.cxx
  ${ITK_SOURCE_DIR}/Examples/Iterators/ImageRandomConstIteratorWithIndex.cxx
  ${ITK_SOURCE_DIR}/Examples/Iterators/ImageRegionIterator.cxx
  ${ITK_SOURCE_DIR}/Examples/Iterators/ImageRegionIteratorWithIndex.cxx
  ${ITK_SOURCE_DIR}/Examples/Iterators/ImageSliceIteratorWithIndex.cxx
  ${ITK_SOURCE_DIR}/Examples/Iterators/NeighborhoodIterators1.cxx
  ${ITK_SOURCE_DIR}/Examples/Iterators/NeighborhoodIterators2.cxx
  ${ITK_SOURCE_DIR}/Examples/Iterators/NeighborhoodIterators3.cxx
  ${ITK_SOURCE_DIR}/Examples/Iterators/NeighborhoodIterators4.cxx
  ${ITK_SOURCE_DIR}/Examples/Iterators/NeighborhoodIterators5.cxx
  ${ITK_SOURCE_DIR}/Examples/Iterators/NeighborhoodIterators6.cxx
  ${ITK_SOURCE_DIR}/Examples/Iterators/ShapedNeighborhoodIterators1.cxx
  ${ITK_SOURCE_DIR}/Examples/Iterators/ShapedNeighborhoodIterators2.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/ImageRegistration1.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/ImageRegistration2.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/ImageRegistration3.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/ImageRegistration4.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/ImageRegistration5.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/ImageRegistration6.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/ImageRegistration7.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/ImageRegistration8.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/ImageRegistration9.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/DeformableRegistration1.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/DeformableRegistration2.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/MultiResImageRegistration1.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/MultiResImageRegistration2.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/ModelToImageRegistration1.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/CannySegmentationLevelSetImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/ConnectedThresholdImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/DeformableModel1.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/GibbsPriorImageFilter1.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/LaplacianSegmentationLevelSetImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/NeighborhoodConnectedImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/ConfidenceConnected.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/IsolatedConnectedImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/HybridSegmentationFuzzyVoronoi.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/HoughTransform2DLinesImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/HoughTransform2DCirclesImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/FastMarchingImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/ShapeDetectionLevelSetFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/ThresholdSegmentationLevelSetImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/VectorConfidenceConnected.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/GeodesicActiveContourImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/WatershedSegmentation1.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/BlobSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/EllipseSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/ImageSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/LandmarkSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/LineSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/ReadWriteSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/SceneSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/SpatialObjectHierarchy.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/SpatialObjectTransforms.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/SurfaceSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/TubeSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/BayesianPluginClassifier.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/EuclideanDistance.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/ExpectationMaximizationMixtureModelEstimator.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/GaussianDensityFunction.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/Histogram.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/ImageToListAdaptor.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/ImageHistogram1.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/ImageHistogram2.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/ImageHistogram3.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/KdTree.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/KdTreeBasedKMeansClustering.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/ListSample.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/ListSampleToHistogramFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/ListSampleToHistogramGenerator.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/MaximumDecisionRule.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/MaximumRatioDecisionRule.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/MembershipSample.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/MinimumDecisionRule.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/NeighborhoodSampler.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/PointSetToListAdaptor.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/NormalVariateGenerator.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/SampleSorting.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/SampleStatistics.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/SampleToHistogramProjectionFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/Subsample.cxx
  ${ITK_SOURCE_DIR}/Examples/Statistics/WeightedSampleStatistics.cxx
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
    COMMAND   ${PERL_EXECUTABLE} 
    ARGS      ${PERLCXXPARSER} ${example} ${TEX_FILE}
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


