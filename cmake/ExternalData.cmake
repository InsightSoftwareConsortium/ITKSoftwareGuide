# - Manage data files stored outside source tree
# Use this module to unambiguously reference data files stored outside the
# source tree and fetch them at build time from arbitrary local and remote
# content-addressed locations.  Functions provided by this module recognize
# arguments with the syntax "DATA{<name>}" as references to external data,
# replace them with full paths to local copies of those data, and create build
# rules to fetch and update the local copies.
#
# The DATA{} syntax is literal and the <name> is a full or relative path
# within the source tree.  The source tree must contain either a real data
# file at <name> or a "content link" at <name><ext> containing a hash of the
# real file using a hash algorithm corresponding to <ext>.  For example, the
# argument "DATA{img.png}" may be satisfied by either a real "img.png" file in
# the current source directory or a "img.png.md5" file containing its MD5 sum.
#
# The 'ExternalData_Expand_Arguments' function evaluates DATA{} references
# in its arguments and constructs a new list of arguments:
#  ExternalData_Expand_Arguments(
#    <target>   # Name of data management target
#    <outVar>   # Output variable
#    [args...]  # Input arguments, DATA{} allowed
#    )
# It replaces each DATA{} reference argument with the full path of a real
# data file on disk that will exist after the <target> builds.
#
# The 'ExternalData_Add_Test' function wraps around the CMake add_test()
# command but supports DATA{} reference arguments:
#  ExternalData_Add_Test(
#    <target>   # Name of data management target
#    ...        # Arguments of add_test(), DATA{} allowed
#    )
# It passes its arguments through ExternalData_Expand_Arguments and then
# invokes add_test() using the results.
#
# The 'ExternalData_Add_Target' function creates a custom target to manage
# local instances of data files stored externally:
#  ExternalData_Add_Target(
#    <target>   # Name of data management target
#    )
# It creates custom commands in the target as necessary to make data files
# available for each DATA{} reference previously evaluated by other functions
# provided by this module.  A list of URL templates must be provided in the
# variable ExternalData_URL_TEMPLATES using the placeholders "%(algo)" and
# "%(hash)" in each template.  Data fetch rules try each URL template in order
# by substituting the hash algorithm name for "%(algo)" and the hash value for
# "%(hash)".
#
# The following hash algorithms are supported:
#    %(algo)     <ext>     Description
#    -------     -----     -----------
#    MD5         .md5      Message-Digest Algorithm 5, RFC 1321
# Note that the hashes are used only for unique data identification and
# download verification.  This is not security software.
#
# Example usage:
#   include(ExternalData)
#   set(ExternalData_URL_TEMPLATES "file:///local/%(algo)/%(hash)"
#                                  "http://data.org/%(algo)/%(hash)"
#   ExternalData_Add_Test(MyData
#     NAME MyTest
#     COMMAND MyExe DATA{MyInput.png}
#     )
#   ExternalData_Add_Target(MyData)
# When test "MyTest" runs the "DATA{MyInput.png}" argument will be replaced by
# the full path to a real instance of the data file "MyInput.png" on disk.  If
# the source tree contains a content link such as "MyInput.png.md5" then the
# "MyData" target creates a real "MyInput.png" in the build tree.
#
# The DATA{} syntax can automatically recognize and fetch a file series.  If
# the source tree contains a group of files or content links named like a
# series then a DATA{} reference to one member adds rules to fetch all of
# them.  Although all members of a series are fetched, only the file
# originally named by the DATA{} argument is substituted for it.  Two
# variables configure recognition of a series from DATA{<name>}.  First,
# ExternalData_SERIES_PARSE is a regex of the form "^(...)(...)(...)$" to
# parse <prefix>, <number>, and <suffix> parts from <name>.  Second,
# ExternalData_SERIES_MATCH is a regex matching the <number> part of series
# members named <prefix><number><suffix>.  Note that the <suffix> of a series
# does not include a hash-algorithm extension.  Both series configuration
# variables have default values that work well for common cases.
#
# The DATA{} syntax can alternatively match files associated with the named
# file and contained in the same directory.  Associated files may be specified
# by options using the syntax DATA{<name>,<opt1>,<opt2>,...}.  Each option may
# specify one file by name or specify a regular expression to match file names
# using the syntax REGEX:<regex>.  For example, the arguments
#   DATA{MyData/MyInput.mhd,MyInput.img}                   # File pair
#   DATA{MyData/MyFrames00.png,REGEX:MyFrames[0-9]+\\.png} # Series
# will pass MyInput.mha and MyFrames00.png on the command line but ensure
# that the associated files are present next to them.
#
# The variable ExternalData_LINK_CONTENT may be set to the name of a supported
# hash algorithm to enable automatic conversion of real data files referenced
# by the DATA{} syntax into content links.  For each such <file> a content
# link named "<file><ext>" is created.  The original file is renamed to the
# form ".ExternalData_<algo>_<hash>" to stage it for future transmission to
# one of the locations in the list of URL templates (by means outside the
# scope of this module).  The data fetch rule created for the content link
# will use the staged object if it cannot be found using any URL template.
#
# The variable ExternalData_OBJECT_STORES may be set to a list of local
# directories that store objects using the layout <dir>/%(algo)/%(hash).
# These directories will be searched first for a needed object.  If the object
# is not available in any store then it will be fetched remotely using the URL
# templates and added to the first local store listed.  If no stores are
# specified the default is a location inside the build tree.
#
# The variable ExternalData_SOURCE_ROOT may be set to the highest source
# directory containing any path named by a DATA{} reference.  The default is
# CMAKE_SOURCE_DIR.  ExternalData_SOURCE_ROOT and CMAKE_SOURCE_DIR must refer
# to directories within a single source distribution (e.g. they come together
# in one tarball).
#
# The variable ExternalData_BINARY_ROOT may be set to the directory to store the
# fetched data.  If not set, it defaults to ${CMAKE_BINARY_DIR}/ExternalData.
#
# Variables ExternalData_TIMEOUT_INACTIVITY and ExternalData_TIMEOUT_ABSOLUTE
# set the download inactivity and absolute timeouts, in seconds.  The defaults
# are 60 seconds and 300 seconds, respectively.  Set either timeout to 0
# seconds to disable enforcement.  The inactivity timeout is enforced only
# with CMake >= 2.8.5.

#=============================================================================
# Copyright 2010-2011 Kitware, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
#
# * Neither the names of Kitware, Inc., the Insight Software Consortium,
#   nor the names of their contributors may be used to endorse or promote
#   products derived from this software without specific prior written
#   permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#=============================================================================

function(ExternalData_add_test target)
  ExternalData_expand_arguments("${target}" testArgs ${ARGN})
  add_test(${testArgs})
endfunction()

function(ExternalData_add_target target)
  if(NOT ExternalData_URL_TEMPLATES)
    message(FATAL_ERROR "ExternalData_URL_TEMPLATES is not set!")
  endif()
  if(NOT ExternalData_OBJECT_STORES)
    set(ExternalData_OBJECT_STORES ${CMAKE_BINARY_DIR}/ExternalData/Objects)
  endif()
  set(config ${CMAKE_CURRENT_BINARY_DIR}/${target}_config.cmake)
  configure_file(${_ExternalData_SELF_DIR}/ExternalData_config.cmake.in ${config} @ONLY)

  set(files "")

  # Set "_ExternalData_FILE_${file}" for each output file to avoid duplicate
  # rules.  Use local data first to prefer real files over content links.

  # Custom commands to copy or link local data.
  get_property(data_local GLOBAL PROPERTY _ExternalData_${target}_LOCAL)
  foreach(entry IN LISTS data_local)
    string(REPLACE "|" ";" tuple "${entry}")
    list(GET tuple 0 file)
    list(GET tuple 1 name)
    if(NOT DEFINED "_ExternalData_FILE_${file}")
      set("_ExternalData_FILE_${file}" 1)
      add_custom_command(
        COMMENT "Generating ${file}"
        OUTPUT "${file}"
        COMMAND ${CMAKE_COMMAND} -Drelative_top=${CMAKE_BINARY_DIR}
                                 -Dfile=${file} -Dname=${name}
                                 -DExternalData_ACTION=local
                                 -DExternalData_CONFIG=${config}
                                 -P ${_ExternalData_SELF}
        DEPENDS "${name}"
        )
      list(APPEND files "${file}")
    endif()
  endforeach()

  # Custom commands to fetch remote data.
  get_property(data_fetch GLOBAL PROPERTY _ExternalData_${target}_FETCH)
  foreach(entry IN LISTS data_fetch)
    string(REPLACE "|" ";" tuple "${entry}")
    list(GET tuple 0 file)
    list(GET tuple 1 name)
    list(GET tuple 2 ext)
    if(NOT DEFINED "_ExternalData_FILE_${file}")
      set("_ExternalData_FILE_${file}" 1)
      add_custom_command(
        # Users care about the data file, so hide the hash/timestamp file.
        COMMENT "Generating ${file}"
        # The hash/timestamp file is the output from the build perspective.
        # List the real file as a second output in case it is a broken link.
        # The files must be listed in this order so CMake can hide from the
        # make tool that a symlink target may not be newer than the input.
        OUTPUT "${file}${ext}" "${file}"
        # Run the data fetch/update script.
        COMMAND ${CMAKE_COMMAND} -Drelative_top=${CMAKE_BINARY_DIR}
                                 -Dfile=${file} -Dname=${name} -Dext=${ext}
                                 -DExternalData_ACTION=fetch
                                 -DExternalData_CONFIG=${config}
                                 -P ${_ExternalData_SELF}
        # Update whenever the object hash changes.
        DEPENDS "${name}${ext}"
        )
      list(APPEND files "${file}${ext}")
    endif()
  endforeach()

  # Custom target to drive all update commands.
  add_custom_target(${target} ALL DEPENDS ${files})
endfunction()

function(ExternalData_expand_arguments target outArgsVar)
  # Replace DATA{} references with real arguments.
  set(data_regex "^xDATA{([^{}\r\n]*)}$")
  set(outArgs "")
  foreach(arg IN LISTS ARGN)
    if("x${arg}" MATCHES "${data_regex}")
      string(REGEX REPLACE "${data_regex}" "\\1" data "x${arg}")
      _ExternalData_arg("${target}" "${arg}" "${data}" file)
      list(APPEND outArgs "${file}")
    else()
      list(APPEND outArgs "${arg}")
    endif()
  endforeach()
  set("${outArgsVar}" "${outArgs}" PARENT_SCOPE)
endfunction()

#-----------------------------------------------------------------------------
# Private helper interface

set(_ExternalData_SELF "${CMAKE_CURRENT_LIST_FILE}")
get_filename_component(_ExternalData_SELF_DIR "${_ExternalData_SELF}" PATH)

function(_ExternalData_compute_hash var_hash algo file)
  if("${algo}" STREQUAL "MD5")
    # TODO: Errors
    execute_process(COMMAND "${CMAKE_COMMAND}" -E md5sum "${file}"
      OUTPUT_VARIABLE output)
    string(SUBSTRING "${output}" 0 32 hash)
    set("${var_hash}" "${hash}" PARENT_SCOPE)
  else()
    # TODO: Other hashes.
    message(FATAL_ERROR "Hash algorithm ${algo} unimplemented.")
  endif()
endfunction()

function(_ExternalData_random var)
  if(NOT ${CMAKE_VERSION} VERSION_LESS 2.8.5)
    string(RANDOM LENGTH 6 random)
  elseif(EXISTS /dev/urandom)
    file(READ /dev/urandom random LIMIT 4 HEX)
  else()
    message(FATAL_ERROR "CMake >= 2.8.5 required in this environment")
  endif()
  set("${var}" "${random}" PARENT_SCOPE)
endfunction()

function(_ExternalData_exact_regex regex_var string)
  string(REGEX REPLACE "([][+.*()^])" "\\\\\\1" regex "${string}")
  set("${regex_var}" "${regex}" PARENT_SCOPE)
endfunction()

function(_ExternalData_atomic_write file content)
  _ExternalData_random(random)
  set(tmp "${file}.tmp${random}")
  file(WRITE "${tmp}" "${content}")
  file(RENAME "${tmp}" "${file}")
endfunction()

function(_ExternalData_link_content name var_ext)
  if("${ExternalData_LINK_CONTENT}" MATCHES "^(MD5)$")
    set(algo "${ExternalData_LINK_CONTENT}")
  else()
    message(FATAL_ERROR
      "Unknown hash algorithm specified by ExternalData_LINK_CONTENT:\n"
      "  ${ExternalData_LINK_CONTENT}")
  endif()
  _ExternalData_compute_hash(hash "${algo}" "${name}")
  get_filename_component(dir "${name}" PATH)
  set(staged "${dir}/.ExternalData_${algo}_${hash}")
  set(ext ".md5")
  _ExternalData_atomic_write("${name}${ext}" "${hash}\n")
  file(RENAME "${name}" "${staged}")
  set("${var_ext}" "${ext}" PARENT_SCOPE)

  file(RELATIVE_PATH relname "${ExternalData_SOURCE_ROOT}" "${name}${ext}")
  message(STATUS "Linked ${relname} to ExternalData ${algo}/${hash}")
endfunction()

function(_ExternalData_arg target arg options var_file)
  # Separate data path from the options.
  string(REPLACE "," ";" options "${options}")
  list(GET options 0 data)
  list(REMOVE_AT options 0)

  # Convert to full path.
  if(IS_ABSOLUTE "${data}")
    set(absdata "${data}")
  else()
    # TODO: If ${data} does not start in "./" or "../" then use search path?
    get_filename_component(absdata "${CMAKE_CURRENT_SOURCE_DIR}/${data}" ABSOLUTE)
  endif()

  # Convert to relative path under the source tree.
  if(NOT ExternalData_SOURCE_ROOT)
    set(ExternalData_SOURCE_ROOT "${CMAKE_SOURCE_DIR}")
  endif()
  set(top_src "${ExternalData_SOURCE_ROOT}")
  file(RELATIVE_PATH reldata "${top_src}" "${absdata}")
  if(IS_ABSOLUTE "${reldata}" OR "${reldata}" MATCHES "^\\.\\./")
    message(FATAL_ERROR "Data file referenced by argument\n"
      "  ${arg}\n"
      "does not lie under the top-level source directory\n"
      "  ${top_src}\n")
  endif()
  if(NOT ExternalData_BINARY_ROOT)
    set(ExternalData_BINARY_ROOT "${CMAKE_BINARY_DIR}/ExternalData")
  endif()
  set(top_bin "${ExternalData_BINARY_ROOT}")

  set(external "") # Entries external to the source tree.
  set(internal "") # Entries internal to the source tree.
  set(have_original 0)

  # Process options.
  set(associated_files "")
  set(associated_regex "")
  foreach(opt ${options})
    if("x${opt}" MATCHES "^xREGEX:[^:/]+$")
      # Regular expression to match associated files.
      string(REGEX REPLACE "^REGEX:" "" regex "${opt}")
      list(APPEND associated_regex "${regex}")
    elseif("x${opt}" MATCHES "^[^][:/*?]+$")
      # Specific associated file.
      list(APPEND associated_files "${opt}")
    else()
      message(FATAL_ERROR "Unknown option \"${opt}\" in argument\n"
        "  ${arg}\n")
    endif()
  endforeach()

  if(associated_files OR associated_regex)
    # Load the named data file and listed/matching associated files.
    _ExternalData_arg_single()
    _ExternalData_arg_associated()
  elseif("${reldata}" MATCHES "(^|/)[^/.]+$")
    # Files with no extension cannot be a series.
    _ExternalData_arg_single()
  else()
    # Match a whole file series by default.
    _ExternalData_arg_series()
  endif()

  if(NOT have_original)
    message(FATAL_ERROR "Data file referenced by argument\n"
      "  ${arg}\n"
      "corresponds to source tree path\n"
      "  ${reldata}\n"
      "that does not exist (with or without an extension)!")
  endif()

  if(external)
    # Make the series available in the build tree.
    set_property(GLOBAL APPEND PROPERTY
      _ExternalData_${target}_FETCH "${external}")
    set_property(GLOBAL APPEND PROPERTY
      _ExternalData_${target}_LOCAL "${internal}")
    set("${var_file}" "${top_bin}/${reldata}" PARENT_SCOPE)
  else()
    # The whole series is in the source tree.
    set("${var_file}" "${top_src}/${reldata}" PARENT_SCOPE)
  endif()
endfunction()

macro(_ExternalData_arg_associated)
  # Associated files lie in the same directory.
  get_filename_component(reldir "${reldata}" PATH)
  if(reldir)
    set(reldir "${reldir}/")
  endif()
  _ExternalData_exact_regex(reldir_regex "${reldir}")

  # Find files named explicitly.
  foreach(file ${associated_files})
    _ExternalData_exact_regex(file_regex "${file}")
    _ExternalData_arg_find_files("${reldir}${file}" "${reldir_regex}${file_regex}")
  endforeach()

  # Find files matching the given regular expressions.
  set(all "")
  set(sep "")
  foreach(regex ${associated_regex})
    set(all "${all}${sep}${reldir_regex}${regex}")
    set(sep "|")
  endforeach()
  _ExternalData_arg_find_files("${reldir}" "${all}")
endmacro()

macro(_ExternalData_arg_single)
  # Match only the named data by itself.
  _ExternalData_exact_regex(data_regex "${reldata}")
  _ExternalData_arg_find_files("${reldata}" "${data_regex}")
endmacro()

macro(_ExternalData_arg_series)
  # Configure series parsing and matching.
  if(ExternalData_SERIES_PARSE)
    if(NOT "${ExternalData_SERIES_PARSE}" MATCHES
        "^\\^\\([^()]*\\)\\([^()]*\\)\\([^()]*\\)\\$$")
      message(FATAL_ERROR
        "ExternalData_SERIES_PARSE is set to\n"
        "  ${ExternalData_SERIES_PARSE}\n"
        "which is not of the form\n"
        "  ^(...)(...)(...)$\n")
    endif()
    set(series_parse "${ExternalData_SERIES_PARSE}")
  else()
    set(series_parse "^(.*)()(\\.[^./]*)$")
  endif()
  if(ExternalData_SERIES_MATCH)
    set(series_match "${ExternalData_SERIES_MATCH}")
  else()
    set(series_match "[_.]?[0-9]*")
  endif()

  # Parse the base, number, and extension components of the series.
  string(REGEX REPLACE "${series_parse}" "\\1;\\2;\\3" tuple "${reldata}")
  list(LENGTH tuple len)
  if(NOT "${len}" EQUAL 3)
    message(FATAL_ERROR "Data file referenced by argument\n"
      "  ${arg}\n"
      "corresponds to path\n"
      "  ${reldata}\n"
      "that does not match regular expression\n"
      "  ${series_parse}")
  endif()
  list(GET tuple 0 relbase)
  list(GET tuple 2 ext)

  # Glob files that might match the series.
  # Then match match base, number, and extension.
  _ExternalData_exact_regex(series_base "${relbase}")
  _ExternalData_exact_regex(series_ext "${ext}")
  _ExternalData_arg_find_files("${relbase}*${ext}"
    "${series_base}${series_match}${series_ext}")
endmacro()

function(_ExternalData_arg_find_files pattern regex)
  file(GLOB globbed RELATIVE "${top_src}" "${top_src}/${pattern}*")
  foreach(entry IN LISTS globbed)
    string(REGEX REPLACE "^(${regex})(\\.md5|)$" "\\1;\\2" tuple "${entry}")
    list(LENGTH tuple len)
    if("${len}" EQUAL 2)
      list(GET tuple 0 relname)
      list(GET tuple 1 alg)
      set(name "${top_src}/${relname}")
      set(file "${top_bin}/${relname}")
      if(alg)
        list(APPEND external "${file}|${name}|${alg}")
      elseif(ExternalData_LINK_CONTENT)
        _ExternalData_link_content("${name}" alg)
        list(APPEND external "${file}|${name}|${alg}")
      else()
        list(APPEND internal "${file}|${name}")
      endif()
      if("${relname}" STREQUAL "${reldata}")
        set(have_original 1)
      endif()
    endif()
  endforeach()
  set(external "${external}" PARENT_SCOPE)
  set(internal "${internal}" PARENT_SCOPE)
  set(have_original "${have_original}" PARENT_SCOPE)
endfunction()

#-----------------------------------------------------------------------------
# Private script mode interface

if(CMAKE_GENERATOR OR NOT ExternalData_ACTION)
  return()
endif()

if(ExternalData_CONFIG)
  include(${ExternalData_CONFIG})
endif()
if(NOT ExternalData_URL_TEMPLATES)
  message(FATAL_ERROR "No ExternalData_URL_TEMPLATES set!")
endif()

function(_ExternalData_link_or_copy src dst)
  # Create a temporary file first.
  get_filename_component(dst_dir "${dst}" PATH)
  file(MAKE_DIRECTORY "${dst_dir}")
  _ExternalData_random(random)
  set(tmp "${dst}.tmp${random}")
  if(UNIX)
    # Create a symbolic link.
    set(tgt "${src}")
    if(relative_top)
      # Use relative path if files are close enough.
      file(RELATIVE_PATH relsrc "${relative_top}" "${src}")
      file(RELATIVE_PATH relfile "${relative_top}" "${dst}")
      if(NOT IS_ABSOLUTE "${relsrc}" AND NOT "${relsrc}" MATCHES "^\\.\\./" AND
          NOT IS_ABSOLUTE "${reldst}" AND NOT "${reldst}" MATCHES "^\\.\\./")
        file(RELATIVE_PATH tgt "${dst_dir}" "${src}")
      endif()
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E create_symlink "${tgt}" "${tmp}" RESULT_VARIABLE result)
  else()
    # Create a copy.
    execute_process(COMMAND "${CMAKE_COMMAND}" -E copy "${src}" "${tmp}" RESULT_VARIABLE result)
  endif()
  if(result)
    file(REMOVE "${tmp}")
    message(FATAL_ERROR "Failed to create\n  ${tmp}\nfrom\n  ${obj}")
  endif()

  # Atomically create/replace the real destination.
  file(RENAME "${tmp}" "${dst}")
endfunction()

function(_ExternalData_download_file url file err_var msg_var)
  set(retry 3)
  while(retry)
    math(EXPR retry "${retry} - 1")
    if("${CMAKE_VERSION}" VERSION_GREATER 2.8.4.20110602)
      if(ExternalData_TIMEOUT_INACTIVITY)
        set(inactivity_timeout INACTIVITY_TIMEOUT ${ExternalData_TIMEOUT_INACTIVITY})
      elseif(NOT "${ExternalData_TIMEOUT_INACTIVITY}" EQUAL 0)
        set(inactivity_timeout INACTIVITY_TIMEOUT 60)
      else()
        set(inactivity_timeout "")
      endif()
    else()
      set(inactivity_timeout "")
    endif()
    if(ExternalData_TIMEOUT_ABSOLUTE)
      set(absolute_timeout TIMEOUT ${ExternalData_TIMEOUT_ABSOLUTE})
    elseif(NOT "${ExternalData_TIMEOUT_ABSOLUTE}" EQUAL 0)
      set(absolute_timeout TIMEOUT 300)
    else()
      set(absolute_timeout "")
    endif()
    file(DOWNLOAD "${url}" "${file}" STATUS status LOG log ${inactivity_timeout} ${absolute_timeout} SHOW_PROGRESS)
    list(GET status 0 err)
    list(GET status 1 msg)
    if(err)
      if("${msg}" MATCHES "HTTP response code said error" AND
          "${log}" MATCHES "error: 503")
        set(msg "temporarily unavailable")
      endif()
    elseif("${log}" MATCHES "\nHTTP[^\n]* 503")
      set(err TRUE)
      set(msg "temporarily unavailable")
    endif()
    if(NOT err OR NOT "${msg}" MATCHES "partial|timeout|temporarily")
      break()
    elseif(retry)
      message(STATUS "[download terminated: ${msg}, retries left: ${retry}]")
    endif()
  endwhile()
  set("${err_var}" "${err}" PARENT_SCOPE)
  set("${msg_var}" "${msg}" PARENT_SCOPE)
endfunction()

function(_ExternalData_download_object name hash algo var_obj)
  # Search all object stores for an existing object.
  foreach(dir ${ExternalData_OBJECT_STORES})
    set(obj "${dir}/${algo}/${hash}")
    if(EXISTS "${obj}")
      message(STATUS "Found object: \"${obj}\"")
      set("${var_obj}" "${obj}" PARENT_SCOPE)
      return()
    endif()
  endforeach()

  # Download object to the first store.
  list(GET ExternalData_OBJECT_STORES 0 store)
  set(obj "${store}/${algo}/${hash}")

  _ExternalData_random(random)
  set(tmp "${obj}.tmp${random}")
  set(found 0)
  set(tried "")
  foreach(url_template IN LISTS ExternalData_URL_TEMPLATES)
    string(REPLACE "%(hash)" "${hash}" url_tmp "${url_template}")
    string(REPLACE "%(algo)" "${algo}" url "${url_tmp}")
    message(STATUS "Fetching \"${url}\"")
    _ExternalData_download_file("${url}" "${tmp}" err errMsg)
    set(tried "${tried}\n  ${url}")
    if(err)
      set(tried "${tried} (${errMsg})")
    else()
      # Verify downloaded object.
      _ExternalData_compute_hash(dl_hash "${algo}" "${tmp}")
      if("${dl_hash}" STREQUAL "${hash}")
        set(found 1)
        break()
      else()
        set(tried "${tried} (wrong hash ${algo}=${dl_hash})")
        if("$ENV{ExternalData_DEBUG_DOWNLOAD}" MATCHES ".")
          file(RENAME "${tmp}" "${store}/${algo}/${dl_hash}")
        endif()
      endif()
    endif()
    file(REMOVE "${tmp}")
  endforeach()

  get_filename_component(dir "${name}" PATH)
  set(staged "${dir}/.ExternalData_${algo}_${hash}")

  if(found)
    file(RENAME "${tmp}" "${obj}")
    message(STATUS "Downloaded object: \"${obj}\"")
  elseif(EXISTS "${staged}")
    set(obj "${staged}")
    message(STATUS "Staged object: \"${obj}\"")
  else()
    message(FATAL_ERROR "Object ${algo}=${hash} not found at:${tried}")
  endif()

  set("${var_obj}" "${obj}" PARENT_SCOPE)
endfunction()

if("${ExternalData_ACTION}" STREQUAL "fetch")
  foreach(v ExternalData_OBJECT_STORES file name ext)
    if(NOT DEFINED "${v}")
      message(FATAL_ERROR "No \"-D${v}=\" value provided!")
    endif()
  endforeach()

  file(READ "${name}${ext}" hash)
  string(STRIP "${hash}" hash)

  if("${ext}" STREQUAL ".md5")
    set(algo "MD5")
  else()
    message(FATAL_ERROR "Unknown hash algorithm extension \"${ext}\"")
  endif()

  _ExternalData_download_object("${name}" "${hash}" "${algo}" obj)

  # Check if file already corresponds to the object.
  set(file_up_to_date 0)
  if(EXISTS "${file}" AND EXISTS "${file}${ext}")
    file(READ "${file}${ext}" f_hash)
    string(STRIP "${f_hash}" f_hash)
    if("${f_hash}" STREQUAL "${hash}")
      #message(STATUS "File already corresponds to object")
      set(file_up_to_date 1)
    endif()
  endif()

  if(file_up_to_date)
    # Touch the file to convince the build system it is up to date.
    execute_process(COMMAND "${CMAKE_COMMAND}" -E touch "${file}")
  else()
    _ExternalData_link_or_copy("${obj}" "${file}")
  endif()

  # Atomically update the hash/timestamp file to record the object referenced.
  _ExternalData_atomic_write("${file}${ext}" "${hash}\n")
elseif("${ExternalData_ACTION}" STREQUAL "local")
  foreach(v file name)
    if(NOT DEFINED "${v}")
      message(FATAL_ERROR "No \"-D${v}=\" value provided!")
    endif()
  endforeach()
  _ExternalData_link_or_copy("${name}" "${file}")
elseif("${ExternalData_ACTION}" STREQUAL "store")
  foreach(v dir file)
    if(NOT DEFINED "${v}")
      message(FATAL_ERROR "No \"-D${v}=\" value provided!")
    endif()
  endforeach()
  if(NOT DEFINED algo)
    set(algo "MD5")
  endif()
  _ExternalData_compute_hash(hash "${algo}" "${file}")
else()
  message(FATAL_ERROR "Unknown ExternalData_ACTION=[${ExternalData_ACTION}]")
endif()
