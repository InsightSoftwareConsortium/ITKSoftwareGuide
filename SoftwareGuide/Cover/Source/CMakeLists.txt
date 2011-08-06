
project( VWSegmentation )

#
#  Find the binary directory where ITK is available
#
find_package(ITK)
if(ITK_FOUND)
  include(${ITK_USE_FILE})
else(ITK_FOUND)
  message(FATAL_ERROR
          "Cannot build InsightApplications without ITK.  Please set ITK_DIR.")
endif(ITK_FOUND)


add_executable( VWHistogramRGB VWHistogramRGB.cxx )
add_executable( VWHistogramHSV VWHistogramHSV.cxx )
add_executable( VWColorSegmentation VWColorSegmentation.cxx )
add_executable( VWBlueRemoval VWBlueRemoval.cxx )
add_executable( ImageReadExtractWriteRGB ImageReadExtractWriteRGB.cxx )
add_executable( BinaryMaskMedianFilter BinaryMaskMedianFilter.cxx )
add_executable( AntialiasFilter AntialiasFilter.cxx )
add_executable( DilateFilter DilateFilter.cxx )
add_executable( NegateFilter NegateFilter.cxx )
add_executable( VectorGradientAnisotropicDiffusionFilter VectorGradientAnisotropicDiffusionFilter.cxx )
add_executable( BinaryThresholdFilter BinaryThresholdFilter.cxx )
add_executable( RescaleIntensityFilter RescaleIntensityFilter.cxx )
add_executable( ModelBasedSegmentation ModelBasedSegmentation.cxx )

target_link_libraries( VWHistogramRGB ITKIO ITKBasicFilters ITKCommon ITKStatistics )
target_link_libraries( VWHistogramHSV ITKIO ITKBasicFilters ITKCommon ITKStatistics )
target_link_libraries( VWColorSegmentation  ITKIO ITKBasicFilters ITKCommon ITKStatistics )
target_link_libraries( VWBlueRemoval  ITKIO ITKBasicFilters ITKCommon ITKStatistics )
target_link_libraries( ImageReadExtractWriteRGB  ITKIO ITKBasicFilters ITKCommon ITKStatistics )
target_link_libraries( BinaryMaskMedianFilter  ITKIO ITKBasicFilters ITKCommon ITKStatistics )
target_link_libraries( AntialiasFilter  ITKIO ITKBasicFilters ITKCommon ITKStatistics )
target_link_libraries( DilateFilter  ITKIO ITKBasicFilters ITKCommon ITKStatistics )
target_link_libraries( NegateFilter  ITKIO ITKBasicFilters ITKCommon ITKStatistics )
target_link_libraries( VectorGradientAnisotropicDiffusionFilter  ITKIO ITKBasicFilters ITKCommon ITKStatistics )
target_link_libraries( BinaryThresholdFilter  ITKIO ITKBasicFilters ITKCommon ITKStatistics )
target_link_libraries( RescaleIntensityFilter  ITKIO ITKBasicFilters ITKCommon ITKStatistics )
target_link_libraries( ModelBasedSegmentation  ITKIO ITKNumerics ITKBasicFilters ITKCommon ITKStatistics )
