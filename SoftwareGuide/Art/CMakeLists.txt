#
#  Convert images from different formats
#  into Encapsulated Postscript to be
#  included in LaTeX files.
#
# TODO: It is likely some images sitting in this directory are no longer in use.
#

file(GLOB PNGandJPG_IMAGES *.jpg *.png)
file(GLOB EPS_IMAGES *.eps)

set(OutputEPSFilePath "${SoftwareGuide_BINARY_DIR}/Art")
foreach(ImageFile ${PNGandJPG_IMAGES})
  get_filename_component(ImageFileNoExt ${ImageFile} NAME_WE)
  set(OutputEPSFile "${OutputEPSFilePath}/${ImageFileNoExt}.eps")
  add_custom_command(
    OUTPUT    ${OutputEPSFile}
    COMMAND   ${IMAGEMAGICK_CONVERT_EXECUTABLE}
              ${EPS_INPUT_CONVERT_FLAGS}
              ${ImageFile}
              ${EPS_OUTPUT_CONVERT_FLAGS}
              ${OutputEPSFile}
    DEPENDS   ${ImageFile}
    )
  set(EPS_DEPS ${EPS_DEPS} ${SoftwareGuide_BINARY_DIR}/Art/${ImageFileNoExt}.eps)
endforeach(ImageFile)


foreach(ImageFile ${EPS_IMAGES})
  get_filename_component(ImageFileNoExt ${ImageFile} NAME_WE)
  file(COPY "${SoftwareGuide_SOURCE_DIR}/Art/${ImageFileNoExt}.eps"
       DESTINATION "${SoftwareGuide_BINARY_DIR}/Art/")
  set(EPS_DEPS ${EPS_DEPS} ${SoftwareGuide_BINARY_DIR}/Art/${ImageFileNoExt}.eps)
endforeach(ImageFile)

add_custom_target(SoftwareGuideArt
  ALL
  DEPENDS ${EPS_DEPS}
  )
