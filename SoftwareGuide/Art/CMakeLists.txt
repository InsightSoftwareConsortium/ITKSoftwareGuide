#
#  Convert images from different formats
#  into Encapsulated Postscript to be
#  included in LaTeX files.
#


#
#  Find fig2dev : this program convert Xfig figures
#  to Encapsulated Postscript on the command line.
#
find_program(FIG2DEV_EXECUTABLE
  NAMES fig2dev
)

add_custom_target(SoftwareGuideArt  ALL echo)

#
#  At some point we should replace XFIG_FIGURES with the FILE GLOB expression.
#
file(GLOB XFIG_FIGURES *.fig)
file(GLOB PNG_IMAGES *.png)
file(GLOB JPEG_IMAGES *.jpg)
file(GLOB EPS_IMAGES *.eps)

if ( 0 ) ## HACK REMOVE THIS
#
# If we built the figures, remove figures that were already generated
# from the list
#
find_file(GENERATED_FILES "GeneratedFiles.txt" "${SoftwareGuide_BINARY_DIR}/Art/Generated")
set(GENERATED_FILES "${GENERATED_FILES}" CACHE INTERNAL "These files were generated" FORCE) #Just make the variable internal
if(GENERATED_FILES)
  file(READ ${GENERATED_FILES} REGULAR_EXPRESSIONS)
  file(GLOB FILES_TO_REMOVE ${REGULAR_EXPRESSIONS})
  remove(XFIG_FIGURES ${FILES_TO_REMOVE})
  remove(PNG_IMAGES ${FILES_TO_REMOVE})
  remove(JPEG_IMAGES ${FILES_TO_REMOVE})
  remove(EPS_IMAGES ${FILES_TO_REMOVE})
endif(GENERATED_FILES)
endif()


foreach(image ${JPEG_IMAGES})
  get_filename_component(Imagebase ${image} NAME)
  get_filename_component(ImageBaseNoExt ${Imagebase} NAME_WE)
  add_custom_command(
  SOURCE    ${SoftwareGuide_SOURCE_DIR}/Art/${ImageBaseNoExt}.jpg
  COMMAND   ${IMAGEMAGICK_CONVERT_EXECUTABLE}
  ARGS      ${SoftwareGuide_SOURCE_DIR}/Art/${ImageBaseNoExt}.jpg
            ${ImageBaseNoExt}.eps
  TARGET    SoftwareGuideArt
  OUTPUTS   ${SoftwareGuide_BINARY_DIR}/Art/${ImageBaseNoExt}.eps
  )
  set(EPS_DEPS ${EPS_DEPS} ${SoftwareGuide_BINARY_DIR}/Art/${ImageBaseNoExt}.eps)
endforeach(image)

foreach(image ${PNG_IMAGES})
  get_filename_component(Imagebase ${image} NAME)
  get_filename_component(ImageBaseNoExt ${Imagebase} NAME_WE)
  add_custom_command(
  SOURCE    ${SoftwareGuide_SOURCE_DIR}/Art/${ImageBaseNoExt}.png
  COMMAND   ${IMAGEMAGICK_CONVERT_EXECUTABLE}
  ARGS      ${SoftwareGuide_SOURCE_DIR}/Art/${ImageBaseNoExt}.png
            ${ImageBaseNoExt}.eps
  TARGET    SoftwareGuideArt
  OUTPUTS   ${SoftwareGuide_BINARY_DIR}/Art/${ImageBaseNoExt}.eps
  )
  set(EPS_DEPS ${EPS_DEPS} ${SoftwareGuide_BINARY_DIR}/Art/${ImageBaseNoExt}.eps)
endforeach(image)

foreach(image ${XFIG_FIGURES})
  get_filename_component(Imagebase ${image} NAME)
  get_filename_component(ImageBaseNoExt ${Imagebase} NAME_WE)
  add_custom_command(
  SOURCE    ${SoftwareGuide_SOURCE_DIR}/Art/${ImageBaseNoExt}.fig
  COMMAND   ${FIG2DEV_EXECUTABLE}
  ARGS      -L eps ${SoftwareGuide_SOURCE_DIR}/Art/${ImageBaseNoExt}.fig ${SoftwareGuide_BINARY_DIR}/Art/${ImageBaseNoExt}.eps
  TARGET    SoftwareGuideArt
  OUTPUTS   ${SoftwareGuide_BINARY_DIR}/Art/${ImageBaseNoExt}.eps
  )
  set(EPS_DEPS ${EPS_DEPS} ${SoftwareGuide_BINARY_DIR}/Art/${ImageBaseNoExt}.eps)
endforeach(image)

foreach(image ${EPS_IMAGES})
  get_filename_component(Imagebase ${image} NAME)
  get_filename_component(ImageBaseNoExt ${Imagebase} NAME_WE)
  configure_file(
                "${SoftwareGuide_SOURCE_DIR}/Art/${ImageBaseNoExt}.eps"
                "${SoftwareGuide_BINARY_DIR}/Art/${ImageBaseNoExt}.eps"
                COPYONLY IMMEDIATE)
  set(EPS_DEPS ${EPS_DEPS} ${SoftwareGuide_BINARY_DIR}/Art/${ImageBaseNoExt}.eps)
endforeach(image)

add_custom_command(
  SOURCE SoftwareGuideArt
  COMMAND echo
  TARGET SoftwareGuideArt
  DEPENDS ${EPS_DEPS}
)

