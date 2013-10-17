#
#  Convert images from different formats
#  into Encapsulated Postscript to be
#  included in LaTeX files.
#
# TODO: It is likely some images sitting in this directory are no longer in use.
#

add_custom_target(SoftwareGuideArt ALL echo)

file(GLOB PNG_IMAGES *.png)
file(GLOB JPEG_IMAGES *.jpg)
file(GLOB EPS_IMAGES *.eps)

foreach(ImageFile ${JPEG_IMAGES})
  get_filename_component(ImageFileNoExt ${ImageFile} NAME_WE)
  add_custom_command(
  COMMAND   ${IMAGEMAGICK_CONVERT_EXECUTABLE}
  ARGS      ${ImageFile}
            ${ImageFileNoExt}.eps
  TARGET    SoftwareGuideArt
  )
  set(EPS_DEPS ${EPS_DEPS} ${SoftwareGuide_BINARY_DIR}/Art/${ImageFileNoExt}.eps)
endforeach(ImageFile)

foreach(ImageFile ${PNG_IMAGES})
  get_filename_component(ImageFileNoExt ${ImageFile} NAME_WE)
  add_custom_command(
  COMMAND   ${IMAGEMAGICK_CONVERT_EXECUTABLE}
  ARGS      ${ImageFile}
            ${ImageFileNoExt}.eps
  TARGET    SoftwareGuideArt
  )
  set(EPS_DEPS ${EPS_DEPS} ${SoftwareGuide_BINARY_DIR}/Art/${ImageFileNoExt}.eps)
endforeach(ImageFile)

# TODO: Use file(COPY ...) signature of the file manipulation command.
foreach(ImageFile ${EPS_IMAGES})
  get_filename_component(ImageFileNoExt ${ImageFile} NAME_WE)
  configure_file(
                "${SoftwareGuide_SOURCE_DIR}/Art/${ImageFileNoExt}.eps"
                "${SoftwareGuide_BINARY_DIR}/Art/${ImageFileNoExt}.eps"
                COPYONLY IMMEDIATE)
  set(EPS_DEPS ${EPS_DEPS} ${SoftwareGuide_BINARY_DIR}/Art/${ImageFileNoExt}.eps)
endforeach(ImageFile)

add_custom_command(
  SOURCE SoftwareGuideArt
  COMMAND echo
  TARGET SoftwareGuideArt
  DEPENDS ${EPS_DEPS}
)

