#
#  This empty files makes the Examples directory 
#  to be created in the binary tree
#
PROJECT(Examples C)

# Macro defs
#
MACRO(RUN_EXAMPLE EXECUTABLE OUTPUT_IMG SOURCE_FILE)
  ADD_CUSTOM_COMMAND(
      OUTPUT      "${SoftwareGuide_BINARY_DIR}/Art/Generated/${OUTPUT_IMG}"
      COMMAND     "${ITK_EXECUTABLES_DIR}/${EXECUTABLE}" 
      ARGS        ${ARGN}
      DEPENDS     ${RUN_EXAMPLES_SCRIPT} ${SOURCE_FILE}
  )
ENDMACRO(RUN_EXAMPLE)

MACRO(ADD_GENERATED_FIG_DEPS OUTPUT_IMG GENERATED_FIG)
  SET( GENERATED_FIGURE_DEPS ${GENERATED_FIGURE_DEPS} "${SoftwareGuide_BINARY_DIR}/Art/Generated/${GENERATED_FIG}" )
ENDMACRO( ADD_GENERATED_FIG_DEPS )

MACRO(CONVERT_IMG SOME_IMG EPS_IMG PATH)
  ADD_CUSTOM_COMMAND(
      SOURCE      "${PATH}/${SOME_IMG}"
      COMMAND     ${IMAGEMAGICK_CONVERT_EXECUTABLE} 
      ARGS        "${PATH}/${SOME_IMG}" "${SoftwareGuide_BINARY_DIR}/Art/${EPS_IMG}"
      DEPENDS     ${RUN_EXAMPLES_SCRIPT} "${SoftwareGuide_BINARY_DIR}/Art/Generated/${SOME_IMG}"
      OUTPUT      "${SoftwareGuide_BINARY_DIR}/Art/${EPS_IMG}"
  )
ENDMACRO(CONVERT_IMG)

MACRO(CONVERT_AND_FLIP_IMG SOME_IMG EPS_IMG PATH)
  ADD_CUSTOM_COMMAND(
      SOURCE      "${PATH}/${SOME_IMG}"
      COMMAND     ${IMAGEMAGICK_CONVERT_EXECUTABLE} 
      ARGS        "-flip" "${PATH}/${SOME_IMG}" "${SoftwareGuide_BINARY_DIR}/Art/${EPS_IMG}"
      DEPENDS     ${RUN_EXAMPLES_SCRIPT} "${SoftwareGuide_BINARY_DIR}/Art/Generated/${SOME_IMG}"
      OUTPUT      "${SoftwareGuide_BINARY_DIR}/Art/${EPS_IMG}"
  )
ENDMACRO(CONVERT_AND_FLIP_IMG)

MACRO(CONVERT_INPUT_IMG SOME_IMG EPS_IMG PATH)
  ADD_CUSTOM_COMMAND(
      SOURCE      "${PATH}/${SOME_IMG}"
      COMMAND     ${IMAGEMAGICK_CONVERT_EXECUTABLE} 
      ARGS        "${PATH}/${SOME_IMG}" "${SoftwareGuide_BINARY_DIR}/Art/${EPS_IMG}"
      DEPENDS     ${RUN_EXAMPLES_SCRIPT}
      OUTPUT      "${SoftwareGuide_BINARY_DIR}/Art/${EPS_IMG}"
  )
ENDMACRO(CONVERT_INPUT_IMG)

MACRO(CONVERT_AND_FLIP_INPUT_IMG SOME_IMG EPS_IMG PATH)
  ADD_CUSTOM_COMMAND(
      SOURCE      "${PATH}/${SOME_IMG}"
      COMMAND     ${IMAGEMAGICK_CONVERT_EXECUTABLE} 
      ARGS        "-flip" "${PATH}/${SOME_IMG}" "${SoftwareGuide_BINARY_DIR}/Art/${EPS_IMG}"
      DEPENDS     ${RUN_EXAMPLES_SCRIPT}
      OUTPUT      "${SoftwareGuide_BINARY_DIR}/Art/${EPS_IMG}"
  )
ENDMACRO(CONVERT_AND_FLIP_INPUT_IMG)


MACRO(SET_DEP_FOR_TEXFILE NAME VAL)
  SET(${NAME} ${${NAME}} "${VAL}")
  #MESSAGE("set: ${NAME}: ${${NAME}}")
ENDMACRO(SET_DEP_FOR_TEXFILE)
MACRO(GET_DEP_FOR_TEXFILE NAME VAR)
  SET(${VAR} ${${NAME}})
  #MESSAGE("get: ${NAME}: ${${NAME}}")
ENDMACRO(GET_DEP_FOR_TEXFILE)

MACRO(ADD_DEP_TEX_ON_EPS_FIGS TEXFILE EPSIMG)
  GET_FILENAME_COMPONENT(name "${TEXFILE}" NAME_WE)
  SET_DEP_FOR_TEXFILE("${name}-DEPS" "${SoftwareGuide_BINARY_DIR}/Art/${EPSIMG}")
  #MESSAGE("Add dependency to ${TEXFILE} to ${EPSIMG}")
  GET_DEP_TEX_ON_EPS_FIGS("${TEXFILE}" deps)
  #MESSAGE("Stored as ${deps}")
ENDMACRO(ADD_DEP_TEX_ON_EPS_FIGS)

MACRO(GET_DEP_TEX_ON_EPS_FIGS TEXFILE VAR)
  GET_FILENAME_COMPONENT(name "${TEXFILE}" NAME_WE)
  #MESSAGE("-- name: ${name} --")
  GET_DEP_FOR_TEXFILE("${name}-DEPS" ${VAR})
ENDMACRO(GET_DEP_TEX_ON_EPS_FIGS)

#
# Find Perl executable

INCLUDE (${CMAKE_ROOT}/Modules/FindPerl.cmake)
IF( NOT PERL_FOUND )
  MESSAGE("Perl executable was not found")
ENDIF( NOT PERL_FOUND )
FIND_PROGRAM(PERLCXXPARSER
  NAMES ${SoftwareGuide_SOURCE_DIR}/ParseCxxExamples.pl
)


ADD_CUSTOM_TARGET(SoftwareGuideExamples  ALL echo)


#
# At some point we should replace the manual ITK_EXAMPLES_SRCS with 
# this FILE GLOB_RECURSE expression.
#
#FILE( GLOB_RECURSE ITK_EXAMPLES_SRCS  ${ITK_SOURCE_DIR}/Examples/*.cxx)


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
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Mesh/MeshPolyLine.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Mesh/MeshCellsIteration.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Mesh/MeshCellVisitor.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Mesh/MeshCellVisitor2.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Path/PolyLineParametricPath1.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/COntainers/TreeContainer.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/BilateralImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/BinaryThresholdImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/BinaryMedianImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/BinaryMinMaxCurvatureFlowImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/BinomialBlurImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/ThresholdImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/CastingImageFilters.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/CurvatureFlowImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/CurvatureAnisotropicDiffusionImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/CannyEdgeDetectionImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/DanielssonDistanceMapImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/SignedDanielssonDistanceMapImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/DiscreteGaussianImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/DerivativeImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/FlipImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/GradientMagnitudeImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/GradientMagnitudeRecursiveGaussianImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/GradientRecursiveGaussianImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/GradientAnisotropicDiffusionImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/GaussianBlurImageFunction.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/IsoSurfaceExtraction.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/MathematicalMorphologyBinaryFilters.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/MathematicalMorphologyGrayscaleFilters.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/MedianImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/MeanImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/MinMaxCurvatureFlowImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/OtsuThresholdImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/OtsuMultipleThresholdImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/ResampleImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/ResampleImageFilter2.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/ResampleImageFilter3.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/ResampleImageFilter4.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/ResampleImageFilter5.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/ResampleVolumesToBeIsotropic.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/WarpImageFilter1.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/RGBCurvatureAnisotropicDiffusionImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/RGBGradientAnisotropicDiffusionImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/SmoothingRecursiveGaussianImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/SmoothingRecursiveGaussianImageFilter2.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/SecondDerivativeRecursiveGaussianImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/SigmoidImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/SubsampleVolume.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/VectorCurvatureAnisotropicDiffusionImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/VectorGradientAnisotropicDiffusionImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/IO/DicomImageReadWrite.cxx
  ${ITK_SOURCE_DIR}/Examples/IO/DicomSeriesReadImageWrite2.cxx
  ${ITK_SOURCE_DIR}/Examples/IO/DicomSeriesReadSeriesWrite.cxx
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
  ${ITK_SOURCE_DIR}/Examples/Registration/ImageRegistration10.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/ImageRegistration11.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/ImageRegistration12.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/ImageRegistration13.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/MeanSquaresImageMetric1.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/DeformableRegistration1.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/DeformableRegistration2.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/DeformableRegistration3.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/DeformableRegistration4.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/DeformableRegistration5.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/DeformableRegistration6.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/DeformableRegistration7.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/DeformableRegistration8.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/LandmarkWarping2.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/BSplineWarping1.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/MultiResImageRegistration1.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/MultiResImageRegistration2.cxx
  ${ITK_SOURCE_DIR}/Examples/Patented/IterativeClosestPoint1.cxx
  ${ITK_SOURCE_DIR}/Examples/Patented/IterativeClosestPoint2.cxx
  ${ITK_SOURCE_DIR}/Examples/Patented/IterativeClosestPoint3.cxx
  ${ITK_SOURCE_DIR}/Examples/Registration/ModelToImageRegistration1.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/CannySegmentationLevelSetImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/ConnectedThresholdImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/DeformableModel1.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/GibbsPriorImageFilter1.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/LaplacianSegmentationLevelSetImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/NeighborhoodConnectedImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/ConfidenceConnected.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/IsolatedConnectedImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Patented/HybridSegmentationFuzzyVoronoi.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/HoughTransform2DLinesImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/HoughTransform2DCirclesImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/FastMarchingImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Patented/FuzzyConnectednessImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/ShapeDetectionLevelSetFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/ThresholdSegmentationLevelSetImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/VectorConfidenceConnected.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/GeodesicActiveContourImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/GeodesicActiveContourShapePriorLevelSetImageFilter.cxx
  ${ITK_SOURCE_DIR}/Examples/Segmentation/WatershedSegmentation1.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/SpatialObjectTreeContainer.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/ArrowSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/CylinderSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/DTITubeSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/GaussianSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/GroupSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/MeshSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/BlobSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/EllipseSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/ImageSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/ImageMaskSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/LandmarkSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/LineSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/ReadWriteSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/SceneSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/SpatialObjectHierarchy.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/SpatialObjectTransforms.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/SurfaceSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/TubeSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/VesselTubeSpatialObject.cxx
  ${ITK_SOURCE_DIR}/Examples/SpatialObjects/SpatialObjectToImageStatisticsCalculator.cxx
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


    




IF( BUILD_FIGURES )
  #
  # Generate .cmake files now.... to configure eps dependencies on 
  # outputs of the source files.
  #
  # First make a directory to store generated images
  MAKE_DIRECTORY( "${SoftwareGuide_BINARY_DIR}/Art/Generated" )
  SET ( GeneratedFolder "${SoftwareGuide_BINARY_DIR}/Art/Generated" )


  IF(ITK_FLIP_INPUTS_AND_THEIR_OUTPUTS)
    SET(FILENAME "${SoftwareGuide_BINARY_DIR}/Art/Generated/Flipped_files.txt")
    FILE(WRITE ${FILENAME} "")
    FOREACH(FLIPIMG ${ITK_FLIP_IMG})
      FILE(APPEND ${FILENAME} "${FLIPIMG} ")
    ENDFOREACH(FLIPIMG)
  ENDIF(ITK_FLIP_INPUTS_AND_THEIR_OUTPUTS)   
  
  SET(FILENAME2 "${SoftwareGuide_BINARY_DIR}/Art/Generated/GeneratedFiles.txt")
  FILE(WRITE ${FILENAME2} "")

  
  FOREACH (example ${ITK_EXAMPLES_SRCS})
    #
    # Configure .. copy needed source files
    #
    GET_FILENAME_COMPONENT(EXAMPLE_FILE ${example} NAME)
    #CONFIGURE_FILE(${example} ${Examples_BINARY_DIR}/${EXAMPLE_FILE}
    #  COPYONLY IMMEDIATE)

    #Clear Figure dependencies for this examples
    #A figure may be generated by another example
    SET( GENERATED_FIGURE_DEPS "")

    # Run Perl script on each example to generate .cmake files 
    GET_FILENAME_COMPONENT(EXAMPLE_FILE_BASE ${example} NAME_WE)

    IF(PERL_FOUND AND RUN_EXAMPLES_SCRIPT)
      SET( ExampleCmakeFile "${Examples_BINARY_DIR}/${EXAMPLE_FILE_BASE}.cmake")
      GET_FILENAME_COMPONENT(TEX_FILE ${example} NAME_WE)
      SET(TEX_FILE ${SoftwareGuide_BINARY_DIR}/Examples/${TEX_FILE}.tex)    
      EXEC_PROGRAM(${PERL_EXECUTABLE} "${SoftwareGuide_BINARY_DIR}/Art/Generated"
        ${Examples_BINARY_DIR}
        ARGS      ${RUN_EXAMPLES_SCRIPT} ${example} ${ITK_EXECUTABLES_DIR} "${ITK_DATA_PATHS}" ${ExampleCmakeFile} ${TEX_FILE} ${GeneratedFolder}
      ) 
      # Include each of the generated .cmake files in dependencies list
      INCLUDE(${ExampleCmakeFile})

    ENDIF(PERL_FOUND AND RUN_EXAMPLES_SCRIPT)
  ENDFOREACH(example)

  #
  # Parse Latex file for latex includes 
  #
  IF( PERL_FOUND AND PERLCXXPARSER )
    FOREACH(example ${ITK_EXAMPLES_SRCS})
    GET_FILENAME_COMPONENT(TEX_FILE ${example} NAME_WE)
    SET(TEX_FILE ${SoftwareGuide_BINARY_DIR}/Examples/${TEX_FILE}.tex)
    GET_DEP_TEX_ON_EPS_FIGS("${TEX_FILE}" deps)
    #MESSAGE("Deps gotten from GET_DEP_TEX_ON_EPS_FIG are ${deps}")
    #GET_FILENAME_COMPONENT(depsNAME ${deps} NAME)
    #MESSAGE("File ${TEX_FILE} depends on: ${deps}")
    ADD_CUSTOM_COMMAND(
      SOURCE    ${example}
      COMMAND   ${PERL_EXECUTABLE} 
      ARGS      ${PERLCXXPARSER} ${example} ${TEX_FILE}
      TARGET    SoftwareGuideExamples
      DEPENDS   ${PERLCXXPARSER} ${example} ${deps}
      OUTPUTS   ${TEX_FILE}
    )
    SET(TEX_DEPENDENCIES ${TEX_DEPENDENCIES} ${TEX_FILE})
    ENDFOREACH(example)

  ENDIF( PERL_FOUND AND PERLCXXPARSER )

ELSE( BUILD_FIGURES )
  #
  # Parse Latex file for latex includes 
  #
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

ENDIF( BUILD_FIGURES )

ADD_CUSTOM_TARGET(BuildTexFiles ALL DEPENDS ${TEX_DEPENDENCIES})

