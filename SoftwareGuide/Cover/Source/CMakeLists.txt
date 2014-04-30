cmake_minimum_required( VERSION 2.8 )

project( VWSegmentation )

find_package( ITK REQUIRED )
include( ${ITK_USE_FILE} )

set( operations
  VWHistogramRGB
  VWHistogramHSV
  VWColorSegmentation
  VWBlueRemoval
  ImageReadExtractWriteRGB
  BinaryMaskMedianFilter
  AntialiasFilter
  DilateFilter
  NegateFilter
  VectorGradientAnisotropicDiffusionFilter
  BinaryThresholdFilter
  ModelBasedSegmentation
  )

foreach( operation ${operations} )
  add_executable( ${operation} ${operation}.cxx )
  target_link_libraries( ${operation} ${ITK_LIBRARIES} )
endforeach()
