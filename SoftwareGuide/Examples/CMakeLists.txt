

#
# Find perl script for parsing cxx files
#
FIND_PROGRAM(PERLCXXPARSER
  NAMES ParseCxxExamples.pl ${SoftwareGuide_SOURCE_DIR}/ParseCxxExamples.pl
)


EXEC_PROGRAM(find ${SoftwareGuide_BINARY_DIR}/Examples ARGS ${ITK_SOURCE_DIR}/Examples "  -name '*.cxx' -print > ExamplesList.txt")

EXEC_PROGRAM(${PERLCXXPARSER} ${SoftwareGuide_BINARY_DIR}/Examples ARGS ExamplesList.txt ${SoftwareGuide_BINARY_DIR}/Examples ) 



