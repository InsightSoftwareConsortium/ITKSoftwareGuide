
PROJECT( VWSegmentation )

#
#  Find the binary directory where ITK is available
#
FIND_PACKAGE(ITK)
IF(ITK_FOUND)
  INCLUDE(${ITK_USE_FILE})
ELSE(ITK_FOUND)
  MESSAGE(FATAL_ERROR
          "Cannot build InsightApplications without ITK.  Please set ITK_DIR.")
ENDIF(ITK_FOUND)


ADD_EXECUTABLE( VWHistogramRGB VWHistogramRGB.cxx )
ADD_EXECUTABLE( VWHistogramHSV VWHistogramHSV.cxx )

TARGET_LINK_LIBRARIES( VWHistogramRGB ITKIO ITKBasicFilters ITKCommon ITKStatistics )
TARGET_LINK_LIBRARIES( VWHistogramHSV ITKIO ITKBasicFilters ITKCommon ITKStatistics )
