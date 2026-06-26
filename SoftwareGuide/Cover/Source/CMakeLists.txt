cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)

project(VWSegmentation)

find_package(ITK 6 REQUIRED)

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
