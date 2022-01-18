cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
cmake_policy(VERSION 3.10.2)

project(Examples C)

set(_required_vars
  SoftwareGuide_BINARY_DIR
  SoftwareGuide_SOURCE_DIR
  PDF_QUALITY_LEVEL
  ITK_SOURCE_DIR
  ITK_BINARY_DIR
  )
foreach(_var IN LISTS _required_vars)
  if(NOT DEFINED ${_var})
    message(FATAL_ERROR "Required variable: ${_var} is not defined!")
  endif()
endforeach()

#
# Generate .cmake files containing those macros defined above.
#
# First make a directory to store generated images
set(ART_GENERATED_FOLDER "${SoftwareGuide_BINARY_DIR}/Art/Generated" )
make_directory( "${ART_GENERATED_FOLDER}" )

#
# Rebuild the Software Guide figures
set(RUN_EXAMPLES_SCRIPT "${SoftwareGuide_SOURCE_DIR}/Examples/RunExamples.py" CACHE FILEPATH "Where the RunExamples Script is")


#
# Find ImageMagick tools
# This is used to convert image formats
#
#
# Find ImageMagick tools
# This is used to convert image formats
#
#include(${CMAKE_ROOT}/Modules/FindImageMagick.cmake)
find_package(ImageMagick REQUIRED)
if(NOT IMAGEMAGICK_CONVERT_EXECUTABLE)
  message("ImageMagick convert utility was not found. Please pass to advanced mode and provide its full path")
endif()



#
# Find Python executable
find_package(PythonInterp)
if( NOT PYTHONINTERP_FOUND )
  message(FATAL_ERROR "Python executable was not found")
endif()
set(PYTHONCXXPARSER ${SoftwareGuide_SOURCE_DIR}/Examples/ParseCxxExamples.py)
if( NOT EXISTS ${PYTHONCXXPARSER} )
  message(FATAL_ERROR "Missing script: ${SoftwareGuide_SOURCE_DIR}/Examples/ParseCxxExamples.py")
endif()

#
# Search for all the example sources
#
file( GLOB_RECURSE all_sources  ${ITK_SOURCE_DIR}/Examples/*.cxx)
# Exclude the RegistrationITKv3 sources.
set( ITK_EXAMPLES_SRCS )
foreach( source ${all_sources} )
  set(exclude RegistrationITKv3)
  if( NOT "${source}" MATCHES "${exclude}" )
    list( APPEND ITK_EXAMPLES_SRCS "${source}" )
  endif()
endforeach()

find_path(ITK_EXECUTABLES_DIR
  NAMES ImageReadWrite ImageReadWrite.exe
  PATHS
  "${ITK_BINARY_DIR}/../bin"
  "${ITK_BINARY_DIR}/../bin/Release"
  "${ITK_BINARY_DIR}/../bin/Debug"
  "${ITK_BINARY_DIR}/Wrapping/Generators/Python/itk/"
  "${ITK_BINARY_DIR}/../bin/RelWithDebInfo"
  "${ITK_BINARY_DIR}/../bin/MinSizeRel"
  DOC "Where the ITK examples executables are"
  )

message(STATUS "PRE_RUN_PYTHON ART GENERATION.")
message(STATUS "Running: ${PYTHON_EXECUTABLE} ${RUN_EXAMPLES_SCRIPT} --itkSource ${ITK_SOURCE_DIR} --itkBuildDir ${ITK_BINARY_DIR} --itkExecDir ${ITK_EXECUTABLES_DIR} --SWGuidBaseOutput ${SoftwareGuide_BINARY_DIR} "
  )
add_custom_target(RunExamples ALL
  COMMAND ${PYTHON_EXECUTABLE}
  ${RUN_EXAMPLES_SCRIPT}
  --itkSource ${ITK_SOURCE_DIR}
  --itkBuildDir ${ITK_BINARY_DIR}
  --itkExecDir ${ITK_EXECUTABLES_DIR}
  --SWGuidBaseOutput ${SoftwareGuide_BINARY_DIR}
  DEPENDS     ${RUN_EXAMPLES_SCRIPT}
  WORKING_DIRECTORY "${ART_GENERATED_FOLDER}"
  COMMENT "Running examples"
  )


file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/ConvertImagesToEPS.cmake "
#
# ADD THE LIST OF INPUT IMAGES YOU WANT FLIPPED HERE.
#
# NOTE:
# All input images in the list and all outputs that use these images
# as inputs in cmd line args will be flipped about 'y'. The command line
# argument itself does not run using the flipped images; instead the eps
# images corresponding to the inputs mentioned in the list and their output
# dependencies are flipped for inclusion in the TEX document.

set(ITK_FLIP_IMG
  BrainProtonDensitySlice
  BrainT1Slice
  BrainT1SliceBorder20
  BrainProtonDensitySliceBorder20
  BrainProtonDensitySliceRotated10
  BrainProtonDensitySliceR10X13Y17
  BrainProtonDensitySliceR10X13Y17S12
  ConfidenceConnectedOutput1
  ConfidenceConnectedOutput2
  ConfidenceConnectedOutput3
  VisibleWomanEyeSlice
  VisibleWomanHeadSlice
  BinaryImage
  VentricleModel
  FivePoints
  ThresholdSegmentationLevelSetImageFilterVentricle
  BrainProtonDensitySliceShifted13x17y
  IsolatedConnectedImageFilterOutput1
  OtsuThresholdImageFilterOutput
  FastMarchingFilterOutput1
  FastMarchingFilterOutput2
  FastMarchingFilterOutput3
  ShapeDetectionLevelSetFilterOutput1
  ShapeDetectionLevelSetFilterOutput1Smoothing
  ShapeDetectionLevelSetFilterOutput1GradientMagnitude
  ShapeDetectionLevelSetFilterOutput1FastMarching
  ShapeDetectionLevelSetFilterOutput2
  ShapeDetectionLevelSetFilterOutput3
  ShapeDetectionLevelSetFilterOutput4
  ThresholdSegmentationLevelSetImageFilterWhiteMatter
  ThresholdSegmentationLevelSetImageFilterVentricle
  ThresholdSegmentationLevelSetImageFilterGrayMatter
  BinaryThresholdImageFilterOutput
  BinaryMedianImageFilterOutput
  SigmoidImageFilterOutput
  GradientMagnitudeImageFilterOutput
  GradientMagnitudeRecursiveGaussianImageFilterOutput3
  GradientMagnitudeRecursiveGaussianImageFilterOutput5
  DerivativeImageFilterOutput
  MeanImageFilterOutput
  MedianImageFilterOutput
  MathematicalMorphologyGrayscaleErosionOutput
  MathematicalMorphologyGrayscaleDilationOutput
  DiscreteGaussianImageFilterOutput
  BinomialBlurImageFilterOutput
  GradientAnisotropicDiffusionImageFilterOutput
  ThresholdImageFilterOutputBelow
  ThresholdImageFilterOutputAbove
  ThresholdImageFilterOutputOutside
  LaplacianRecursiveGaussianImageFilterOutput3
  LaplacianRecursiveGaussianImageFilterOutput5
  MathematicalMorphologyGrayscaleErosionOutput
  MathematicalMorphologyGrayscaleDilationOutput
  MathematicalMorphologyBinaryErosionOutput
  MathematicalMorphologyBinaryDilationOutput
  VotingBinaryHoleFillingImageFilterOutput1
  VotingBinaryHoleFillingImageFilterOutput2
  VotingBinaryHoleFillingImageFilterOutput3
  VotingBinaryIterativeHoleFillingImageFilterOutput1
  VotingBinaryIterativeHoleFillingImageFilterOutput2
  VotingBinaryIterativeHoleFillingImageFilterOutput3
  SmoothingRecursiveGaussianImageFilterOutput3
  SmoothingRecursiveGaussianImageFilterOutput5
  CurvatureAnisotropicDiffusionImageFilterOutput
  CurvatureFlowImageFilterOutput
  MinMaxCurvatureFlowImageFilterOutput
  BilateralImageFilterOutput
  RGBGradientAnisotropicDiffusionImageFilterOutput
  RGBCurvatureAnisotropicDiffusionImageFilterOutput
  ResampleImageFilterOutput1
  ResampleImageFilterOutput2
  ResampleImageFilterOutput10
  ImageRegistration1Output
  ImageRegistration1DifferenceBefore
  ImageRegistration1DifferenceAfter
  ImageRegistration2Output
  ImageRegistration2CheckerboardBefore
  ImageRegistration2CheckerboardAfter
  ImageRegistration5Output
  ImageRegistration5DifferenceBefore
  ImageRegistration5DifferenceAfter
  ImageRegistration5Output2
  ImageRegistration5DifferenceBefore2
  ImageRegistration5DifferenceAfter2
  ImageRegistration6Output
  ImageRegistration6DifferenceBefore
  ImageRegistration6DifferenceAfter
  ImageRegistration7Output
  ImageRegistration7DifferenceBefore
  ImageRegistration7DifferenceAfter
  ImageRegistration8Output
  ImageRegistration8DifferenceBefore
  ImageRegistration8DifferenceAfter
  ImageRegistration9Output
  ImageRegistration9DifferenceBefore
  ImageRegistration9DifferenceAfter
  MultiResImageRegistration1Output
  MultiResImageRegistration1CheckerboardBefore
  MultiResImageRegistration1CheckerboardAfter
  MultiResImageRegistration2Output
  MultiResImageRegistration2CheckerboardBefore
  MultiResImageRegistration2CheckerboardAfter
  ConnectedThresholdOutput1
  ConnectedThresholdOutput2
  ConnectedThresholdOutput3
  FastMarchingImageFilterOutput5
  FastMarchingImageFilterOutput6
  FastMarchingImageFilterOutput7
  FastMarchingImageFilterOutput8
  GeodesicActiveContourImageFilterOutput1
  GeodesicActiveContourImageFilterOutput2
  GeodesicActiveContourImageFilterOutput3
  GeodesicActiveContourImageFilterOutput5
  GeodesicActiveContourImageFilterOutput6
  GeodesicActiveContourImageFilterOutput7
  GeodesicActiveContourImageFilterOutput8
  CannySegmentationLevelSetImageFilterVentricle1
  LaplacianSegmentationLevelSetImageFilterVentricle
  BrainT1Slice_labelled
  ScalarImageMarkovRandomField1Output
  ImageSliceIteratorWithIndexOutput
  NeighborhoodIterators1a
  NeighborhoodIterators4a
  NeighborhoodIterators4b
  NeighborhoodIterators4c
  NeighborhoodIterators4d
  ShapedNeighborhoodIterators1b
  ImageAdaptorThresholdingA
  ImageAdaptorThresholdingB
  ImageRegistration4Output
  ImageRegistration4CheckerboardBefore
  ImageRegistration4CheckerboardAfter
  MultiStageImageRegistration1Output
  MultiStageImageRegistration1CheckerboardBefore
  MultiStageImageRegistration1CheckerboardAfter
  MultiStageImageRegistration2Output
  MultiStageImageRegistration2CheckerboardBefore
  MultiStageImageRegistration2CheckerboardAfter
  ImageRegionIteratorOutput
)
# END FLIP_INPUTS LIST
# Convert an image from some file format to EPS for inclusion in Latex using
# ImageMagick. This image is an input image. A separate macro is necessary
# because input images do not have any dependecies
set(EPS_INPUT_CONVERT_FLAGS)
set(EPS_OUTPUT_CONVERT_FLAGS)
if( \"${PDF_QUALITY_LEVEL}\" STREQUAL \"Printer\" )
  # Upsample to satify the printer
  set( EPS_INPUT_CONVERT_FLAGS -density 72 )
  set( EPS_OUTPUT_CONVERT_FLAGS -density 72 -scale 4194304@ )
endif()
macro(CONVERT_INPUT_IMG SOME_IMG EPS_IMG IMAGEMAGICK_FLAGS)
  get_filename_component(IMG_BASENAME \${SOME_IMG} NAME_WE)
  list(FIND ITK_FLIP_IMG \"\${IMG_BASENAME}\" _index)
  if(\${_index} GREATER -1)
    if(NOT "\${FLAGS}" MATCHES "-flip")
      set(FLAGS \${FLAGS} -flip)
    endif()
  endif()
  if( NOT DEFINED \${EPS_IMG}_HAS_CUSTOM_COMMAND)
    message(STATUS \"Converting \${SOME_IMG}\")
    execute_process(
        COMMAND \"${IMAGEMAGICK_CONVERT_EXECUTABLE}\" \${FLAGS} -quality 100 \${EPS_INPUT_CONVERT_FLAGS} \"\${SOME_IMG}\" \${EPS_OUTPUT_CONVERT_FLAGS} \"\${EPS_IMG}\"
        OUTPUT_FILE ${CMAKE_CURRENT_BINARY_DIR}/ConvertImagesToEPSOutput.txt
	ERROR_FILE ${CMAKE_CURRENT_BINARY_DIR}/ConvertImagesToEPSError.txt
	RESULT_VARIABLE _result
    )
    if(NOT \${_result} EQUAL 0)
      message(FATAL_ERROR "Convert image to EPS failed! Check log file.")
    endif()
    set(\${EPS_IMG}_HAS_CUSTOM_COMMAND 1)
  endif()
  set(FLAGS \"\")
endmacro()
include(\"${SoftwareGuide_BINARY_DIR}/Examples/GeneratedDependencies.cmake\")
")
add_custom_command(TARGET RunExamples POST_BUILD
  COMMAND ${CMAKE_COMMAND}
  ARGS -P ${CMAKE_CURRENT_BINARY_DIR}/ConvertImagesToEPS.cmake
  COMMENT "Converting Images to EPS"
  USES_TERMINAL
)


#
# Parse Latex file for latex includes
#
set(TEX_DEPENDENCIES "")
foreach(example ${ITK_EXAMPLES_SRCS})
  get_filename_component(TEX_FILE_BASE ${example} NAME_WE)
  set(TEX_FILE ${SoftwareGuide_BINARY_DIR}/Examples/${TEX_FILE_BASE}.tex)
  add_custom_command(
    OUTPUT    ${TEX_FILE}
    COMMAND   ${PYTHON_EXECUTABLE}
    ARGS      ${PYTHONCXXPARSER} ${example} ${TEX_FILE}
    DEPENDS   ${PYTHONCXXPARSER} ${example} ${${TEX_FILE_BASE}-DEPS}
  )
  set(TEX_DEPENDENCIES ${TEX_DEPENDENCIES} ${TEX_FILE})
endforeach()

add_custom_target(BuildTexFiles ALL
  DEPENDS ${TEX_DEPENDENCIES}
  )
