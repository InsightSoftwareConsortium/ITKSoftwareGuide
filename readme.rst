ITK Software Guide
==================

Software Guide for Insight Toolkit, ITK_.

Download instructions
---------------------

With version of Git (>= 1.6.5)::

  $ git clone --recursive git@github.com:InsightSoftwareConsortium/ITKSoftwareGuide.git


With older versions::

  $ git clone git@github.com:InsightSoftwareConsortium/ITKSoftwareGuide.git
  $ cd ITKSoftwareGuide
  $ git submodule update --init


Build instructions
------------------

Manual
^^^^^^

If you want to use local installations of some of the required tools, configure
and build ITKSoftwareGuide as a typical CMake_ project.

Features
--------

Implemented
^^^^^^^^^^^

- Stored and editable in Git_ version control.
- HTML output.
- CMake ExternalData for binary data storage.

Build dependencies
------------------

Required
^^^^^^^^

- CMake_
- Sphinx_

Development setup
------------------

Run the bash scipt SetupForDevelopment.sh::

  $ ./utilities/SetupForDevelopment.sh


.. _CMake: http://cmake.org/
.. _Git: http://git-scm.com/
.. _ITK: http://itk.org/
.. _Sphinx: http://sphinx.pocoo.org/
